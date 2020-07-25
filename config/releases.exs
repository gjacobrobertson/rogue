import Config

host = System.fetch_env!("HOST")
port = System.fetch_env!("PORT") |> String.to_integer()
secret_key_base = System.fetch_env!("SECRET_KEY_BASE")

config :rogue, RogueWeb.Endpoint,
  url: [host: nil, port: 443],
  http: [port: {:system, "PORT"}]
  secret_key_base: secret_key_base
