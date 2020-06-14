defmodule StenoWeb.Api.JobController do
  use StenoWeb, :controller

  alias Steno.Job

  alias Steno.Queue

  alias StenoWeb.Plugs
  plug Plugs.RequireSecret

  action_fallback StenoWeb.FallbackController

  def index(conn, _params) do
    jobs = Queue.list()
    render(conn, "index.json", jobs: jobs)
  end

  def create(conn, %{"job" => job_params}) do
    job_params = job_params
    |> Map.put("tag", conn.assigns[:auth_tag])

    job0 = Job.new(job_params)
    with {:ok, job} <- Queue.add(job0) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.job_path(conn, :show, job))
      |> render("show.json", job: job)
    end
  end

  def show(conn, %{"key" => key}) do
    job = Queue.get(key)
    render(conn, "show.json", job: job)
  end

  def delete(conn, %{"key" => key}) do
    with {:ok, _} <- Queue.cancel(key) do
      send_resp(conn, :no_content, "")
    end
  end
end
