defmodule StenoWeb.PageController do
  use StenoWeb, :controller

  def index(conn, _params) do
    jobs = Steno.Queue.list()
    render(conn, "index.html", jobs: jobs)
  end
end
