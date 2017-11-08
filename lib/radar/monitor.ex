defmodule Radar.Monitor do

	@callback handle_change(:node_up | :node_down) :: any

	defmacro __using__(_opts) do
		quote do
			use GenServer
			@behaviour Radar.Monitor

			def start_link(_) do
				GenServer.start_link(__MODULE__, [])
			end

			def init(_) do
				:ok = :net_kernel.monitor_nodes(true, node_type: :all) |> IO.inspect
				{:ok, {}}
			end

			def handle_info({status, node, _info}, state) do
				handle_change(status)
				{:noreply, state}
			end
		end
	end
end