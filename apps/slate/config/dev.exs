use Mix.Config

# Configure your database
config :slate, Slate.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "slate_dev",
  hostname: "localhost",
  pool_size: 10
