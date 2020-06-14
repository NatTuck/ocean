defmodule StenoWeb.Plugs.RequireSecret do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    with {:ok, auth} <- get_auth(conn),
         {:ok, token} <- get_token(auth),
         {:ok, tag, jwt} <- verify(token)
    do
      # IO.inspect({:jwt, jwt})
      conn
      |> assign(:auth_token, jwt)
      |> assign(:auth_tag, tag)
      |> put_resp_header("x-valid-auth", inspect(jwt))
    else
      _ -> auth_failed(conn)
    end
  end

  def auth_failed(conn) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(401, ~s({"msg": "unauthorized"}))
    |> halt()
  end

  def get_auth(conn) do
    conn.req_headers
    |> Enum.into(%{})
    |> Map.fetch("authorization")
  end

  def get_token(auth) do
    case String.split(auth) do
      ["Bearer", token] -> {:ok, token}
      _other -> :error
    end
  end

  def verify(token) do
    Application.get_env(:steno, :shared_secrets)
    |> Stream.map(&(verify_one(&1, token)))
    |> Enum.find(&valid/1)
  end

  def verify_one({tag, secret}, token) do
    signer = Joken.Signer.create("HS256", secret)
    case Joken.Signer.verify(token, signer) do
      {:ok, token} -> {:ok, tag, token}
      _else -> :fail
    end
  end

  def valid({:ok, _, _}), do: true
  def valid(_), do: false
end
