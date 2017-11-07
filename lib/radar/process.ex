defmodule Radar.Process do
	defmacro __using__(_opts) do
		quote do
			use GenServer

			def start_link(args) do
				GenServer.start_link(__MODULE__, args, name: via(args))
			end

			def via(args) do
				args
				|> name
				|> Radar.Process.via
			end

			def name(args) do
				{__MODULE__, args}
			end

			def get(args) do
				args
				|> name
				|> Radar.execute(fn -> get_local(args) end)
			end

			def get_local(args) do
				{Radar.Registry, name(args)}
				|> Registry.whereis_name
				|> case do
					:undefined ->
						{:ok, pid} = Radar.Supervisor.start_child(__MODULE__, args)
						pid
					pid -> pid
				end
			end

			def call(args, msg, timeout \\ 5000) do
				args
				|> name
				|> Radar.execute(fn ->
					args
					|> get_local
					|> GenServer.call(msg, timeout)
				end)
			end

			def cast(args, msg) do
				args
				|> name
				|> Radar.execute(fn ->
					args
					|> get_local
					|> GenServer.cast(msg)
				end)
			end

			def supervisor_spec do
				import Supervisor.Spec
				supervisor(Radar.Supervisor, [__MODULE__], id: __MODULE__)
			end

		end
	end

	def via(name) do
		{:via, Registry, {Radar.Registry, name}}
	end
end

defmodule Radar.Example do
	use Radar.Process

	def init(args) do
		IO.puts("Starting #{__MODULE__}")
		Radar.join(:a)
		|> IO.inspect
		{:ok, %{}}
	end

	def handle_call(:hello, _from, state) do
		{:reply, :hi, state}
	end
end