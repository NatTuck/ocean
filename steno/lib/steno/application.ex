defmodule Steno.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    {:ok, _} = Steno.Queue.start()

    children = [
      # Start the Telemetry supervisor
      StenoWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Steno.PubSub},
      # Start the Endpoint (http/https)
      StenoWeb.Endpoint,
      # Worker pulls jobs from queue and runs them
      Steno.Worker,
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Steno.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    StenoWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
