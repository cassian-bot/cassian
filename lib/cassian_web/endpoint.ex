defmodule CassianWeb.Endpoint do
  use Plug.Router

  @moduledoc """
  Current endpoint for this bot. It's minimalistic and will be removed soon.
  """

  # Using Plug.Loader for logging request informaiton
  plug(Plug.Logger)

  # Forcing SSL on Gigalixir (for some reason I can't use a macro nor a function...)
  if Application.get_env(:cassian, :force_ssl) == "true" do
    plug(Plug.SSL, rewrite_on: [:x_forwarded_proto], host: nil)
  else
    nil
  end

  # Resonsible for endpoint mattching
  plug(:match)
  # JSON parse library
  plug(Plug.Parsers, parsers: [:json], json_decoder: Poison)
  # Set every response to be `application/json`
  plug(CassianWeb.Plugs.JsonRequestPlug)
  # Responsible for dispatching responses
  plug(:dispatch)

  get "/api/shields/guilds" do
    apply(CassianWeb.Controllers.Api.Shields.Guilds, :show, [conn])
  end

  get "/api/shields/system" do
    apply(CassianWeb.Controllers.Api.Shields.System, :show, [conn])
  end

  match _ do
    send_resp(conn, 404, "{\"error\": \"Path Undefined\"}")
  end
end
