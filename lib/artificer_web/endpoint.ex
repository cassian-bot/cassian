defmodule ArtificerWeb.Endpoint do
  use Plug.Router

  @moduledoc """
  Current endpoint for this bot. It's minimalistic and will be removed soon.
  """

  # Using Plug.Loader for logging request informaiton
  plug(Plug.Logger)
  # Forcing SSL on Gigalixir
  plug(Plug.SSL, rewrite_on: [:x_forwarded_proto], host: nil)
  # Resonsible for endpoint mattching
  plug(:match)
  # JSON parse library
  plug(Plug.Parsers, parsers: [:json], json_decoder: Poison)
  # Set every response to be `application/json`
  plug(ArtificerWeb.Plugs.JsonRequestPlug)
  # Responsible for dispatching responses
  plug(:dispatch)

  get "/api/shields/guilds" do
    apply(ArtificerWeb.Controllers.Api.Shields.Guilds, :show, [conn])
  end

  get "/api/shields/system" do
    apply(ArtificerWeb.Controllers.Api.Shields.System, :show, [conn])
  end

  match _ do
    send_resp(conn, 404, "{\"error\": \"Path Undefined\"}")
  end
end
