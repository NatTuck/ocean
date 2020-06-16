defmodule Steno.Token do
  use Joken.Config

  @impl true
  def token_config() do
    default_claims(skip: [:iat, :nbf, :iss, :aud])
  end

  def gen(tag, claims) do
    secret = get_secret(tag)
    signer = Joken.Signer.create("HS256", secret)
    generate_and_sign(claims, signer)
  end

  def get_secret(tag) do
    xs = Application.get_env(:steno, :shared_secrets)
    case Enum.find(xs, fn {tt, sec} -> tt == tag end) do
      {^tag, sec} -> sec
      _else -> nil
    end
  end
end
