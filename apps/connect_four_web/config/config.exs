# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :connect_four_web,
  namespace: ConnectFour.Web

# Configures the endpoint
config :connect_four_web, ConnectFour.Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "jJVrU8KpOsMkrkH6zckCEz0iNzFezFC/+DTY3kzoWploQDYSlbKy+/O2ZaTcPCXt",
  render_errors: [view: ConnectFour.Web.ErrorView, accepts: ~w(html json)],
  pubsub: [name: ConnectFour.Web.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
