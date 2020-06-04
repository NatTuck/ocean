defmodule DemoSteno.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      DemoStenoWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: DemoSteno.PubSub},
      # Start the Endpoint (http/https)
      DemoStenoWeb.Endpoint
      # Start a worker by calling: DemoSteno.Worker.start_link(arg)
      # {DemoSteno.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: DemoSteno.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    DemoStenoWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
