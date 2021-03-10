defmodule CassianWeb.Controllers.Api.Shields.System do
  use CassianWeb.Api.DataResponse

  def data do
    %{
      schemaVersion: 1,
      labelColor: "#9900ff",
      namedLogo: "Elixir",
      label: "Elixir",
      color: "#fff",
      style: "flat-square",
      message: System.version()
    }
  end
end
