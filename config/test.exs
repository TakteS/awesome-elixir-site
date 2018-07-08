use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :awesome_elixir, AwesomeElixirWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :awesome_elixir, AwesomeElixir.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "awesome_elixir_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :awesome_elixir, :github,
  api_url: "https://api.github.com",
  client_id: "client_id",
  client_secret: "client_secret"
