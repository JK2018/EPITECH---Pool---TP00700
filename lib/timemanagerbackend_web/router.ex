defmodule TimemanagerbackendWeb.Router do
  use TimemanagerbackendWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :cors_pipe do
    plug(CORSPlug, origin: "http://localhost:8080/")
    plug(:accepts, ["json"])
  end

  pipeline :authenticate do
    plug(TimemanagerbackendWeb.Plugs.Authenticate)
  end

  scope "/" do
    pipe_through(:cors_pipe)

    scope "/sessions" do
      post("/sign_up", TimemanagerbackendWeb.SessionsController, :sign_up)
      post("/sign_in", TimemanagerbackendWeb.SessionsController, :sign_in)
      # delete("/sign_out", TimemanagerbackendWeb.SessionsController, :sign_out)
    end

    scope "/api", TimemanagerbackendWeb do
      pipe_through(:authenticate)

      # scope "/test" do
      get("/test", TestController, :index)
      get("/test/roles", TestController, :roles)
      # end

      resources("/users", UserController, except: [:new])
      # more routes

      resources("/workingtimes", WorkingTimeController,
        only: [:show, :edit, :create, :update, :delete]
      )

      get("/clock/:id", ClockController, :show)
      post("/clock/:id", ClockController, :toggle)

      # resources("/teams", TeamController, only: [:show, :create])
    end
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through(:browser)
      live_dashboard("/dashboard", metrics: TimemanagerbackendWeb.Telemetry)
    end
  end
end
