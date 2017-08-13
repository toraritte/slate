use Mix.Config

config :slate, ecto_repos: [Slate.Repo]

import_config "#{Mix.env}.exs"
