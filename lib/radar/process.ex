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
				|> Radar.which_node
				|> Radar.Dispatcher.call(__MODULE__, :get_local, [args])
			end

			@doc false
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
				|> Radar.which_node
				|> Radar.Dispatcher.call(__MODULE__, :call_local, [args, msg, timeout], timeout)
			end

			@doc false
			def call_local(args, msg, timeout) do
				args
				|> get_local
				|> GenServer.call(msg, timeout)
			end

			def cast(args, msg) do
				args
				|> name
				|> Radar.which_node
				|> Radar.Dispatcher.cast(__MODULE__, :cast_local, [args, msg])
			end

			@doc false
			def cast_local(args, msg) do
				args
				|> get_local
				|> GenServer.cast(msg)
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