defmodule TetrisWeb.Router do
  alias TetrisWeb.TetrisLive
  use TetrisWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {TetrisWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", TetrisWeb do
    pipe_through :browser

    get "/", PageController, :home

    live "/tetris", TetrisView
  end
end
