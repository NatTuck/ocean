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
    %{id: job.id,
      key: job.key,
      user: job.user,
      desc: job.desc,
      sbx_cfg: job.sbx_cfg,
      sub_url: job.sub_url,
      gra_url: job.gra_url,
      meta: job.meta,
      output: job.output}
  end
end
