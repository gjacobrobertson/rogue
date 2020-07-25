import Config

host = System.fetch_env!("HOST")
port = System.fetch_env!("PORT") |> String.to_integer()

config :rogue, RogueWeb.Endpoint,
  url: [host: nil, port: 443],
  http: [port: {:system, "PORT"}]
