
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
    base: "debian:buster",
    packages: ["clang", "clang-tools", "valgrind"],
    user_commands: [
      "curl https://sh.rustup.rs -sSf | sh -s -- -y",
    ],
    size_limit: "10M",
  },
  driver: %{
    script: "classic",
    SUB: "http://icewing:8001/sub.tar.gz",
    GRA: "http://icewing:8001/gra.tar.gz",
  },
  postback: "http://icewing:8001/result",
}

body = Jason.encode!(%{job: job})

resp = HTTPoison.post!(url, body, hdrs)
IO.inspect(resp)
