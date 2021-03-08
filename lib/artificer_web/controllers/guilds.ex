defmodule ArtificerWeb.Controllers.Guilds do
  import Plug.Conn

  def show(conn) do
    conn
    |> send_resp(200, guilds())
  end

  def guilds do
    %{guilds: []}
    |> Poison.encode!()
  end
end
