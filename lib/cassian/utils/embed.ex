defmodule Cassian.Utils.Embed do
  alias Nostrum.Struct.Embed

  import Embed

  @doc """
  Add a color on an embed. The `color` params ia a hex string value of the color.
  It will be automaically converted to something Discord can use.
  """
  @spec put_color_on_embed(embed :: Embed, color :: String.t()) :: Embed
  def put_color_on_embed(embed, color \\ "#6996ff") do
    {color, _} =
      color
      |> String.replace_leading("#", "")
      |> Integer.parse(16)

    put_color(embed, color)
  end

  def put_error_color_on_embed(embed) do
    put_color(embed, 16711731)
  end

  @doc """
  Create an empty embed. It has the default color of the bot.
  """
  @spec create_empty_embed!() :: Embed
  def create_empty_embed!() do
    %Nostrum.Struct.Embed{}
    |> put_color_on_embed()
  end
end
