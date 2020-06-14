defmodule Steno.Postback do
  alias Steno.Token
  alias Steno.Job

  def postback(%Job{} = job) do
    {:ok, token, _} = Token.gen(job.tag)
    hdrs = [
      {"Accept", "application/json; charset=utf-8"},
      {"Content-Type", "application/json"},
      {"Authorization", "Bearer #{token}"},
    ]

    view = Job.postback_view(job)
    body = Jason.encode!(%{job: view})

    HTTPoison.post!(job.postback, body, hdrs)
  end
end
