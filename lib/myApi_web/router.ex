defmodule MyApiWeb.Router do
  use MyApiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", MyApiWeb do
    pipe_through :api
  end
end
