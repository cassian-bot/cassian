defmodule CassianWeb.Controllers.Api.Shields.Guilds do
  use CassianWeb.Api.DataResponse

  def data do
    %{
      schemaVersion: 1,
      label: "Guilds",
      message: Nostrum.Cache.GuildCache.all() |> Enum.count() |> to_string,
      color: "#7289DA",
      namedLogo: "Discord",
      style: "flat-square",
      logoColor: "#fff"
    }
  end

end
