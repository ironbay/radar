defmodule Radar do

  def which_node(name) do
    HashRing.Managed.key_to_node(:radar, name)
  end

  # Pub Sub
  def join(group, pid \\ self()) do
    Registry.register_name({Radar.Group, group}, pid)
  end

  def broadcast(group, msg) do
    [Node.self() | Node.list]
    |> Task.async_stream(&Radar.Dispatcher.cast(&1, Radar, :broadcast_local, [group, msg]))
    |> Enum.to_list
  end

  def broadcast_local(group, msg) do
    Radar.Group
    |> Registry.dispatch(group, fn entries ->
      for {pid, _} <- entries, do: GenServer.cast(pid, msg)
    end, parallel: true)
  end
end
