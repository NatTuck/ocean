
alias DemoSteno.Token

{:ok, token, _} = Token.generate_and_sign(%{})

url = "http://localhost:4000/api/jobs"
hdrs = [
  {"Accept", "application/json; charset=utf-8"},
  {"Content-Type", "application/json"},
  {"Authorization", "Bearer #{token}"},
]

job = %{
  key: "55",
  pri: 10,
  container: %{
    dockerfile: "http://localhost:8001/Dockerfile",
    size_limit: "10M",
  },
  driver: %{
    script: "classic",
    sub_url: "http://localhost:8001/sub.tar.gz",
    gra_url: "http://localhost:8001/gra.tar.gz",
  }
}

body = Jason.encode!(%{job: job})

resp = HTTPoison.post!(url, body, hdrs)
IO.inspect(resp)
