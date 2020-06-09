defmodule DemoSteno.Token do
  use Joken.Config

  @impl true
  def token_config do
    default_claims(skip: [:iat, :nbf, :iss, :aud])
  end
end
