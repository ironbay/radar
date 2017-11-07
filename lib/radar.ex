defmodule Radar do

  def whereis(name) do
    HashRing.Managed.key_to_node(:radar, name)
  end

  def execute(name, func) do
    node = whereis(name)
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
end
