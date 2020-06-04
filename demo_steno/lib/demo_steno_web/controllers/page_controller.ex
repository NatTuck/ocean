defmodule DemoStenoWeb.PageController do
  use DemoStenoWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
