defmodule Radar do

  def which_node(name) do
    HashRing.Managed.key_to_node(:radar, name)
  end

  def execute(name, func) do
    name
    |> which_node
    |> execute_node(func)
  end

  defp execute_node(node, func) do
    cond do
      node === Node.self -> func.()
      true ->
        s = self()
        Node.spawn_link(node, fn ->
          reply = func.()
          send(s, reply)
        end)
        receive do
          result -> result
        end
    end
  end

  # Pub Sub
  def join(group) do
    Registry.register(Radar.Group, group, 1)
  end

  def broadcast(group, msg) do
    [Node.self() | Node.list]
    |> Task.async_stream(&execute_node(&1, fn -> broadcast_local(group, msg) end))
    |> Enum.to_list
  end

  defp broadcast_local(group, msg) do
    Radar.Group
    |> Registry.dispatch(group, fn entries ->
      for {pid, _} <- entries, do: GenServer.cast(pid, msg)
    end)
  end
end
