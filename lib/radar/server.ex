defmodule Radar.Server do
	defmacro __using__(_opts) do
		quote do
			use GenServer

			def start_link(args) do
				GenServer.start_link(__MODULE__, args, name: via(args))
			end

			def via(args) do
				{:via, Registry, {Radar.Registry, name(args)}}
			end

			def name(args) do
				{__MODULE__, args}
			end

		end
	end
end

defmodule Radar.Example do
	use Radar.Server

	def init(args) do
		{:ok, %{}}
	end
end