# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :slate_web,
  namespace: SlateWeb,
  ecto_repos: [Slate.Repo],
  generators: [binary_id: true]

# Configures the endpoint
config :slate_web, SlateWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "sQ+YxsuTBGGoM0hL4HFPM0amjFNgIdh+SeNH4RIPhXqkMhfNqa9139oG5vQVfSVc",
  render_errors: [view: SlateWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: SlateWeb.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :slate_web, :generators,
  context_app: :slate

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
