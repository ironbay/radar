defmodule Radar.MixProject do
  use Mix.Project

  def project do
    [
      app: :radar,
      version: "0.1.0",
      elixir: "~> 1.5.2",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Radar.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:libring, "~> 1.0"}
    ]
  end
end
