defmodule Pan.MixProject do
  use Mix.Project

  def project do
    [
      app: :pan,
      version: "0.1.0",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Pan.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      # security-focused static analysis tool
      {:sobelow, "~> 0.8", only: :dev},
      # Code analysis
      {:credo, "~> 1.4", only: [:dev, :test], runtime: false},
      # web framework
      {:phoenix, "~> 1.5.7"},
      # PubSub messaging
      {:phoenix_pubsub, "~> 2.0"},
      # phoenix support for ecto
      {:phoenix_ecto, "~> 4.1"},
      # ecto sql adapter
      {:ecto_sql, "~> 3.4"},
      # database adapter
      {:postgrex, "~> 0.14"},
      # reactive view layer
      {:phoenix_live_view, "~> 0.15.0"},
      # HTML parser
      {:floki, ">= 0.27.0", only: :test},
      # classic view layer
      {:phoenix_html, "~> 2.11"},
      # live browser page reload on code changes
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      # live metrics dashboard
      {:phoenix_live_dashboard, "~> 0.4"},
      # telemetry_metrics
      {:telemetry_metrics, "~> 0.4"},
      # telemetry poller
      {:telemetry_poller, "~> 0.4"},
      # i18n library
      {:gettext, "~> 0.11"},
      # Json generation
      {:jason, "~> 1.0"},
      # web server plug
      {:plug_cowboy, "~> 2.0"},
      # algorithm used for comeonin
      {:bcrypt_elixir, "~> 2.1"},
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "cmd npm install --prefix assets"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"]
    ]
  end
end
