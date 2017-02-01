defmodule Pan.Mixfile do
  use Mix.Project

  def project do
    [app: :pan,
     version: "0.0.1",
     elixir: "~> 1.0",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases(),
     deps: deps()]
  end

  def application do
    [mod: {Pan, []},
     applications: [:phoenix, :phoenix_pubsub, :phoenix_html, :cowboy, :logger,
                    :gettext, :phoenix_ecto, :postgrex, :httpotion, :httpoison,
                    :comeonin, :sweet_xml, :timex, :earmark,
                    :font_awesome_phoenix, :quinn, :uuid, :html_sanitize_ex,
                    :crutches,:scrivener_ecto, :scrivener_html, :bamboo, :bamboo_smtp]]
  end

  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  defp deps do
    [{:phoenix, "~> 1.2.0"}, # wWeb framework
     {:phoenix_pubsub, "~> 1.0"}, # PubSub messaging
     {:postgrex, ">= 0.0.0"}, # database adapter
     {:phoenix_ecto, "~> 3.0-rc"}, # ORM (yes!)
     {:phoenix_html, "~> 2.4"}, # view layer
     {:phoenix_live_reload, "~> 1.0", only: :dev}, # live browser page reload on code changes
     {:gettext, "~> 0.9"}, # i18n and l10n
     {:cowboy, "~> 1.0"}, # web server
     {:comeonin, "~> 2.0"}, # password hashing library
     {:sweet_xml, "~> 0.6"}, # XML parser
     {:timex, "~> 3.1.8"}, # time conversion
     {:font_awesome_phoenix, "~> 1.0"}, # Font Awesome (just view helpers)
     {:httpoison, "~> 0.9.0"}, # http client
     {:httpotion, "~> 3.0.2"}, # http client (another one!)
     {:exrm, "~> 1.0" }, # release manager
     {:quinn, "~> 1.0.0"}, # XML parser (another one)
     {:uuid, "~> 1.1"}, # UUID creation
     {:html_sanitize_ex, "~> 1.0.0"}, # sanitizing html input (shownotes)
     {:crutches, "~> 1.0.0"}, # ActionSupport like view helpers
     {:scrivener_ecto, "~> 1.0"}, # pagination
     {:scrivener_html, "~> 1.1"}, # pagination view helper
     {:bamboo, "~> 0.8"}, # mailing
     {:bamboo_smtp, "~> 1.3"}, # mailing smtp adapter
     {:earmark, "~> 1.1.0"}] # Markdown parser
  end

  defp aliases do
    ["ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
     "ecto.reset": ["ecto.drop", "ecto.setup"],
     "test": ["ecto.create --quiet", "ecto.migrate", "test"]]
  end
end
