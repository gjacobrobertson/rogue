defmodule Rogue.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      RogueWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Rogue.PubSub},
      {Registry, keys: :unique, name: Rogue.RoomRegistry},
      {DynamicSupervisor, strategy: :one_for_one, name: Rogue.RoomSupervisor},
      # Start the Endpoint (http/https)
      RogueWeb.Endpoint
      # Start a worker by calling: Rogue.Worker.start_link(arg)
      # {Rogue.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Rogue.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    RogueWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
