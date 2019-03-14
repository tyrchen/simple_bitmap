defmodule SimpleBitmap.MixProject do
  use Mix.Project

  @top Path.join(File.cwd!(), ".")
  @version @top |> Path.join("version") |> File.read!() |> String.trim()
  @elixir_version @top |> Path.join(".elixir_version") |> File.read!() |> String.trim()

  def project do
    [
      app: :simple_bitmap,
      version: @version,
      elixir: @elixir_version,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: [ignore_warnings: ".dialyzer_ignore.exs", plt_add_apps: []],
      description: description(),
      package: package(),
      # Docs
      name: "Simple Bitmap",
      source_url: "https://github.com/tyrchen/simple_bitmap",
      homepage_url: "https://github.com/tyrchen/simple_bitmap",
      docs: [
        main: "SimpleBitmap",
        extras: ["README.md"]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      # dev and test
      {:credo, "~> 1.0.0", only: [:dev, :test]},
      {:dialyxir, "~> 1.0.0-rc.4", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.19.0", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.10", only: [:test]},
      {:pre_commit_hook, "~> 1.2", only: [:dev, :test], runtime: false}
    ]
  end

  defp description do
    """
    Simple bitmap support.
    """
  end

  defp package do
    [
      files: [
        "config",
        "lib",
        "mix.exs",
        "README*",
        "version",
        ".elixir_version"
      ],
      licenses: ["Apache 2.0"],
      maintainers: ["tyr.chen@gmail.com"],
      links: %{
        "GitHub" => "https://github.com/tyrchen/simple_bitmap",
        "Docs" => "https://hexdocs.pm/simple_bitmap"
      }
    ]
  end
end
