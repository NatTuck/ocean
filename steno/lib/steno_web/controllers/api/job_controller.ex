defmodule StenoWeb.Api.JobController do
  use StenoWeb, :controller

  alias Steno.Job
  alias Steno.Jobs

  alias Steno.Queue

  alias StenoWeb.Plugs
  plug Plugs.RequireSecret

  action_fallback StenoWeb.FallbackController

  def index(conn, _params) do
    jobs = Jobs.list_jobs()
    render(conn, "index.json", jobs: jobs)
  end

  def create(conn, %{"job" => job_params}) do
    job0 = Job.new(job_params)
    with {:ok, job} <- Queue.add(job0) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.job_path(conn, :show, job))
      |> render("show.json", job: job)
    end
  end

  def show(conn, %{"id" => id}) do
    job = Jobs.get_job!(id)
    render(conn, "show.json", job: job)
  end

  def update(conn, %{"id" => id, "job" => job_params}) do
    job = Jobs.get_job!(id)

    with {:ok, job} <- Jobs.update_job(job, job_params) do
      render(conn, "show.json", job: job)
    end
  end

  def delete(conn, %{"id" => id}) do
    job = Jobs.get_job!(id)

    with {:ok, _} <- Jobs.delete_job(job) do
      send_resp(conn, :no_content, "")
    end
  end
end
