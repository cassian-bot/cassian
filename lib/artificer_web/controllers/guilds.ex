defmodule ArtificerWeb.Controllers.Guilds do
  import Plug.Conn

  def show(conn) do
    conn
    |> send_resp(200, guilds())
  end

  def guilds do
    %{
      schemaVersion: 1,
      label: "Guilds",
      message: Nostrum.Cache.GuildCache.all() |> Enum.to_list() |> length() |> to_string,
      color: "#7289DA",
      namedLogo: "Discord",
      logoColor: "#fff"
    }
    |> Poison.encode!()
  end
end
