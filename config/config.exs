# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :awesome_elixir,
  ecto_repos: [AwesomeElixir.Repo]

# Configures the endpoint
config :awesome_elixir, AwesomeElixirWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "fgyHrzkWOa44LgqYkcedBdoOckYx4bZKcHQA1+zmxfMve8vIa4wqn6o+f49ymOga",
  render_errors: [view: AwesomeElixirWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: AwesomeElixir.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

config :phoenix, :template_engines,
  slim: PhoenixSlime.Engine,
  slime: PhoenixSlime.Engine

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
