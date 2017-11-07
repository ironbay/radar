defmodule Radar.Dispatcher do
	use GenServer

	def start_link do
		GenServer.start_link(__MODULE__, {})
	end

	def init(_args) do
		:pg2.join(Node.self(), self())
		{:ok, {}}
	end

	def handle_call({:dispatch, mod, fun, args}, _from, state) do
		result = apply(mod, fun, args)
		{:reply, result, state}
	end

	def handle_cast({:dispatch, mod, fun, args}, state) do
		apply(mod, fun, args)
		{:noreply, state}
	end

	def call(node, mod, fun, args, timeout \\ 5000) do
		node
		|> pool
		|> GenServer.call({:dispatch, mod, fun, args}, timeout)
	end

	def cast(node, mod, fun, args) do
		node
		|> pool
		|> GenServer.cast({:dispatch, mod, fun, args})
	end

	defp pool(node) do
		node
		|> :pg2.get_members
		|> Enum.random
	end
end

defmodule Radar.Dispatcher.Supervisor do
	use Supervisor

	def start_link(_) do
		Supervisor.start_link(__MODULE__, {})
	end

	def init(_) do
		:pg2.create(Node.self())
		children =
			(1..System.schedulers_online)
			|> Enum.map(fn index -> %{
				id: index,
				start: {Radar.Dispatcher, :start_link, []},
				restart: :permanent,
				shutdown: 5000,
				type: :worker,
			} end)
		Supervisor.init(children, strategy: :one_for_one)
	end
end