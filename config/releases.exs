import Config

host = System.fetch_env!("HOST")
port = System.fetch_env!("PORT") |> String.to_integer()
secret_key_base = System.fetch_env!("SECRET_KEY_BASE")

config :rogue, RogueWeb.Endpoint,
  url: [host: host, port: port],
  secret_key_base: secret_key_base
