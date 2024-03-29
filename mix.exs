defmodule ExUnitAbsinthe.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_unit_absinthe,
      version: "0.1.1",
      elixir: "~> 1.8",
      description: description(),
      package: package(),
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:absinthe, "~> 1.4"},
      {:recase, "~> 0.6"},
    ]
  end

  defp description() do
    "Helpers for Absinthe GraphQL tests"
  end

  defp package() do
    [
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/futpib/ex_unit_absinthe"}
    ]
  end
end
