defmodule Radar.Supervisor do
	def start_link(module) do
		result = Supervisor.start_link(__MODULE__, [module], name: module)
		module.supervisor_start()
		result
	end

	def init([module]) do
		IO.puts("Starting #{module} Supervisor")
		import Supervisor.Spec
		children = [
			worker(module, [], restart: :transient)
		]
		supervise(children, strategy: :simple_one_for_one)
	end

	def start_child(module, args) do
		{:ok, _} = Supervisor.start_child(module, [args])
	end

	def stop(module, reason \\ :normal) do
		Supervisor.stop(module, reason)
	end

end