defmodule ElixirCourse.MixProject do
  use Mix.Project

  def project do
    [
      app: :elixir_ourse,
      version: "0.1.0",
      elixir: "~> 1.11",
      deps: deps()
    ]
  end

  def application do

  end

  defp deps do
    [
      {:credo, "~> 1.5",  runtime: false}
    ]
  end
end
