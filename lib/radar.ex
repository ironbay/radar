defmodule Radar do
  @moduledoc """
  Documentation for Radar.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Radar.hello
      :world

  """
  def call(name, req, timeout \\ 5000) do
    node = HashRing.Managed.key_to_node(:radar, name)
    self = self()
    Node.spawn_link
  end

  def whereis(key) do
    
  end
end
