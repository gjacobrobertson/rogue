import Config

host = System.fetch_env!("HOST")
port = System.fetch_env!("PORT")

secret_key_base =
  System.get_env("SECRET_KEY_BASE") ||
    raise """
    environment variable SECRET_KEY_BASE is missing.
    You can generate one by calling: mix phx.gen.secret
    """

config :rogue, RogueWeb.Endpoint,
  url: [host: host, port: String.to_integer(port)],
  http: [
    port: String.to_integer(port),
    transport_option: [socket_opts: [:inet6]]
  ],
  secret_key_base: secret_key_base
