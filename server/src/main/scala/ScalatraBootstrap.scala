import javax.servlet.ServletContext

import org.scalatra.LifeCycle

import controllers.{ApiServlet}

class ScalatraBootstrap extends LifeCycle {
  override def init(context: ServletContext) {
    context.mount(new ApiServlet, "/api/*")
  }
}
