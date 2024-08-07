defmodule HelloWeb.Router do
  use HelloWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {HelloWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
	plug HelloWeb.Plugs.Locale, "en"
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", HelloWeb do
    pipe_through :browser

    get "/", PageController, :index
	
	resources "/users", UserController do
		resources "/posts", PostController
	end

	resources "/posts", PostController, only: [:index, :show]
	resources "/comments", CommentController, except: [:delete]
    get "/hello", HelloController, :index
    get "/hello/:messenger", HelloController, :show

	resources "/reviews", ReviewController
  end

  scope "/admin", HelloWeb.Admin, as: :admin do
	pipe_through :browser

	resources "/images", ImageController
	resources "/reviews", ReviewController
	resources "/users", UserController
  end

  scope "/api", HelloWeb.Api, as: :api do
	pipe_through :api

	scope "/v1", V1, as: :v1 do
		resources "/images", ImageController
		resources "/reviews", ReviewController
		resources "/users", UserController
	end
  end

  # Custom pipeline
  pipeline :review_checks do
	plug :browser
	# plug :ensure_authenticated_user
	# plug :ensure_user_owns_review
  end

  # Sample of what if we need to pipe requests through 
  # both :browser and more custom pipelines.
  scope "/reviews", HelloWeb do
	pipe_through :review_checks # :review_checks has invoked in its statement

	resources "/", ReviewController # Only reviews' resources routes will pipe through the `:review_checks`.
  end

  # Example of `Forward`
  scope "/" do
	# pipe_through [:authenticate_user, :ensure_admin]
	forward "/jobs", BackgroundJob.Plug, name: "Hello Phoenix"
  end

  # Other scopes may use custom stacks.
  # scope "/api", HelloWeb do
  #   pipe_through :api
  # end

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
      pipe_through :browser

      live_dashboard "/dashboard", metrics: HelloWeb.Telemetry
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
