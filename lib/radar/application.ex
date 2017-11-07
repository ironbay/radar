defmodule Radar.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    {:ok, _pid} = HashRing.Managed.new(:radar, monitor_nodes: true)
    # List all child processes to be supervised
    children = [
      {Registry, [keys: :unique, partitions: System.schedulers_online, name: Radar.Registry]},
      {Registry, [keys: :duplicate, partitions: System.schedulers_online, name: Radar.Group]},
      {Radar.Dispatcher.Supervisor, []},
      Radar.Example.supervisor_spec(),
    ]
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Radar.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
