defmodule Traindepartures.Router do
  use Traindepartures.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Traindepartures do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/departureinfoupdate", PageController, :departureinfoupdate
  end

  # Other scopes may use custom stacks.
  # scope "/api", Traindepartures do
  #   pipe_through :api
  # end
end
