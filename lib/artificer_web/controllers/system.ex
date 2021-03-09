defmodule ArtificerWeb.Controllers.Elixir do
  import Plug.Conn

  def show(conn) do
    conn
    |> send_resp(200, guilds())
  end

  def guilds do
    %{
      schemaVersion: 1,
      labelColor: "#9900ff",
      namedLogo: "Elixir",
      label: "Elixir",
      color: "#fff",
      message: System.version
    }
    |> Poison.encode!()
  end
end
