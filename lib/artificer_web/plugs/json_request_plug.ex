defmodule ArtificerWeb.Plugs.JsonRequestPlug do
  import Plug.Conn

  @moduledoc """
  Plug module which sets every request as an API one
  """

  def init(options), do: options

  def call(conn, _opts) do
    conn
    |> put_resp_content_type("application/json")
  end
end
