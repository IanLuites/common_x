defmodule CommonX.MixProject do
  use Mix.Project

  def project do
    [
      app: :common_x,
      version: "0.0.4",
      description: "Extension of common Elixir modules.",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),

      # Testing
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      dialyzer: [ignore_warnings: ".dialyzer", plt_add_deps: true],

      # Docs
      name: "CommonX",
      source_url: "https://github.com/IanLuites/common_x",
      homepage_url: "https://github.com/IanLuites/common_x",
      docs: [
        main: "readme",
        extras: ["README.md"]
      ]
    ]
  end

  def package do
    [
      name: :common_x,
      maintainers: ["Ian Luites"],
      licenses: ["MIT"],
      files: [
        # Elixir
        "lib/common_x",
        "lib/common_x.ex",
        ".formatter.exs",
        "mix.exs",
        "README*",
        "LICENSE*"
      ],
      links: %{
        "GitHub" => "https://github.com/IanLuites/common_x"
      }
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:analyze, "~> 0.1.3", optional: true, runtime: false, only: [:dev, :test]},
      {:dialyxir, "~> 1.0.0-rc.4", optional: true, runtime: false, only: [:dev, :test]}
    ]
  end
end
