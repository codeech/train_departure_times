# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :traindepartures, Traindepartures.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "YCWZZR1wInO1id+0dX3xFfJImZ2Ou1zkpqOjNTSOvvbSflDY9gFC8L7gro7RbRDO",
  render_errors: [view: Traindepartures.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Traindepartures.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
