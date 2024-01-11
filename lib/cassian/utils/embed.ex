defmodule Cassian.Utils.Embed do
  alias Nostrum.Struct.Embed

  import Embed

  @doc """
  Add a color on an embed. The `color` params ia a hex string value of the color.
  It will be automaically converted to something Discord can use.
  """
  @spec put_color_on_embed(embed :: Embed.t(), color :: String.t()) :: Embed.t()
  def put_color_on_embed(embed, color \\ "#6996ff") do
    {color, _} =
      color
      |> String.replace_leading("#", "")
      |> Integer.parse(16)

    put_color(embed, color)
  end

  def put_error_color_on_embed(embed) do
    put_color(embed, 16_711_731)
  end

  @doc """
  Create an empty embed. It has the default color of the bot.
  """
  @spec create_empty_embed!() :: Embed.t()
  def create_empty_embed!() do
    %Nostrum.Struct.Embed{}
    |> put_color_on_embed()
  end

  def generate_error_embed(title, description) do
    create_empty_embed!()
    |> put_error_color_on_embed()
    |> Embed.put_title(title)
    |> Embed.put_description(description)
  end
end
