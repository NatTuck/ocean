defmodule Steno.Postback do
  alias Steno.Token
  alias Steno.Job

  def postback(%Job{} = job) do
    claims = %{
      iss: "steno",
      aud: job.tag,
    }

    {:ok, token, _} = Token.gen(job.tag, claims)
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
