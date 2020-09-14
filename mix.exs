defmodule PushGatewayGenerator.MixProject do
  use Mix.Project

  def project do
    [
      app: :push_gateway_generator,
      version: "1.0.0-static",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      test_paths: test_paths(Mix.env())
    ]
  end

  def application do
    [
      mod: {PushGatewayGenerator.Application, []},
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:jason, "~> 1.1"},
      {:kitt, "~> 0.3.0"},
      {:distillery, "~> 2.1.1"},
      {:retry, "~> 0.13"},
      {:credo, "~> 1.1.5", only: :dev}
    ]
  end

  defp elixirc_paths(env) when env in [:test, :integration], do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
  defp test_paths(_), do: ["test/unit"]
end
