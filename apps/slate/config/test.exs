use Mix.Config

# Configure your database
config :slate, Slate.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "slate_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
