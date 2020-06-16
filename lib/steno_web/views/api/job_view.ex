defmodule StenoWeb.Api.JobView do
  use StenoWeb, :view
  alias StenoWeb.Api.JobView

  def render("index.json", %{jobs: jobs}) do
    %{data: render_many(jobs, JobView, "job.json")}
  end

  def render("show.json", %{job: job}) do
    %{data: render_one(job, JobView, "job.json")}
  end

  def render("job.json", %{job: job}) do
    %{
      key: job.key,
      pri: job.pri,
    }
  end
end
