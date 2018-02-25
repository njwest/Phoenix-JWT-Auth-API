defmodule MyApiWeb.Router do
  use MyApiWeb, :router
  
  alias MyApi.Guardian

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :jwt_authenticated do
    plug Guardian.AuthPipeline
  end

  scope "/api/v1", MyApiWeb do
    pipe_through :api

    resources "/users", UserController, only: [:create]
    post "/sign_in", UserController, :sign_in
  end

  scope "/api/v1", MyApiWeb do
    pipe_through [:api, :jwt_authenticated]

    get "/my_user", UserController, :show
  end

end
