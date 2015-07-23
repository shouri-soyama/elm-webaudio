(function() { "use strict";
	var app = Elm.embed(Elm.Audio, document.getElementById("main"), {
		soundEncoded: []
	});
	var audioConf = {
		bufferSize: 16384,
		channels: 1,
		sampleRate: 8000
	};
	window.navigator.getUserMedia = window.navigator.getUserMedia || window.navigator.webkitGetUserMedia || window.navigator.mozGetUserMedia;
	var AudioContext = window.AudioContext || window.webkitAudioContext || window.msAudioContext;
	var ac = new AudioContext();
	var recordProcessor = ac.createScriptProcessor(audioConf.bufferSize, 1, 1);
	recordProcessor.onaudioprocess = function(e) {
		console.log("onaudioprocess");
		var data = e.inputBuffer.getChannelData(0);
		var conf = {
			channels: 1,
			sampleRate: 8000,
			bitrate: 8000
		};
		var OPUS_APPLICATION_VOIP = 2048;
		var OPUS_SET_BITRATE_REQUEST = 4002;
		OpusEncoder.prototype.setBitrate = function(bitrate) {
			var bitratePtr = allocate(4, 'i32', ALLOC_STACK);
			setValue(bitratePtr, bitrate, 'i32');
			var err = _opus_encoder_ctl(this.handle, OPUS_SET_BITRATE_REQUEST, bitratePtr);
			if (err != 0) {
				throw 'opus_encoder_ctl failed: ' + err;
			}
		}
		var toArray = function(xs) {
			var ret = new Array(xs.length);
			for (var i = 0; i < xs.length; i++) {
				ret[i] = xs[i];
			}
			return ret;
		};
		var encoder = new OpusEncoder(conf.sampleRate, conf.channels, OPUS_APPLICATION_VOIP, 20);
		encoder.setBitrate(conf.bitrate);

		var resampler = new SpeexResampler(conf.channels, ac.sampleRate, conf.sampleRate, 32, true);
		var resampleBuf = resampler.process_interleaved(data);
		var packets = encoder.encode_float(resampleBuf);
		var ret = packets.map(function(x) { return toArray(new Uint8Array(x)); });
		app.ports.soundEncoded.send(ret);
		console.log(ret);
		resampler.destroy();
	};
	window.navigator.getUserMedia({ video: false, audio: true }, function(stream) {
		var micSource = ac.createMediaStreamSource(stream);
		micSource.connect(recordProcessor);
	}, function(err) {
		console.log(err);
	});
	app.ports.startRec.subscribe(function() {
		console.log("startRec");
		recordProcessor.connect(ac.destination);
	});
	var decoder = new OpusDecoder(audioConf.sampleRate, audioConf.channels);
	var resampler = new SpeexResampler(audioConf.channels, audioConf.sampleRate, ac.sampleRate, 32, true);
	var playingTime = 0;
	var playAudio = function(buf) {
		buf.forEach(function(payload) {
			var decData = decoder.decode_float(new Uint8Array(payload));
			var resampleData = resampler.process_interleaved(decData.buffer);
			var buffer = ac.createBuffer(audioConf.channels, resampleData.length, ac.sampleRate);
			buffer.getChannelData(0).set(resampleData);
			var source = ac.createBufferSource();
			source.buffer = buffer;
			source.connect(ac.destination);
			var playTime = Math.max(ac.currentTime, playingTime);
			source.start(playTime);
			playingTime = playTime + buffer.duration;
		});
	};

	app.ports.playAudio.subscribe(function(buf) {
		console.log("playAudio");
		console.log(buf);
		recordProcessor.disconnect();
		playAudio(buf);
	});
})();
