defmodule MyApiWeb.Router do
  use MyApiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :api_auth do
    
  end

  scope "/api/v1", MyApiWeb do
    pipe_through :api

    post "/sign_in", UserController, :sign_in
    resources "/users", UserController, only: [:create, :show]
  end

  scope "/api/v1", MyApiWeb do
    pipe_through [:api, :api_auth]

    resources "/users", UserController, only: [:update, :show]
  end

end
