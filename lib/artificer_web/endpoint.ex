defmodule ArtificerWeb.Endpoint do
  use Plug.Router

  @moduledoc """
  Current endpoint for this bot. It's minimalistic and will be removed soon.
  """

  # Using Plug.Loader for logging request informaiton
  plug(Plug.Logger)
  # Resonsible for endpoint mattching
  plug(:match)
  # JSON parse library
  plug(Plug.Parsers, parsers: [:json], json_decoder: Poison)
  # Set every response to be `application/json`
  plug(ArtificerWeb.Plugs.JsonRequestPlug)
  # Responsible for dispatching responses
  plug(:dispatch)

  get "/guilds" do
    apply(ArtificerWeb.Controllers.Guilds, :show, [conn])
  end

  get "/system" do
    apply(ArtificerWeb.Controllers.Elixir, :show, [conn])
  end

  match _ do
    send_resp(conn, 404, "{\"error\": \"Path Undefined\"}")
  end
end
