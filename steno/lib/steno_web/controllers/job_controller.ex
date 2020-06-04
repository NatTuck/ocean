defmodule StenoWeb.JobController do
  use StenoWeb, :controller

  alias Steno.Jobs

  def index(conn, _params) do
    jobs = Jobs.list_jobs()
    render(conn, "index.html", jobs: jobs)
  end

  def show(conn, %{"id" => id}) do
    job = Jobs.get_job!(id)
    render(conn, "show.html", job: job)
  end

  def delete(conn, %{"id" => id}) do
    job = Jobs.get_job!(id)
    {:ok, _job} = Jobs.delete_job(job)

    conn
    |> put_flash(:info, "Job deleted successfully.")
    |> redirect(to: Routes.job_path(conn, :index))
  end
end
