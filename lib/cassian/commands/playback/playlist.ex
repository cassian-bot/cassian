defmodule Cassian.Commands.Playback.Playlist do
  use Cassian.Behaviours.Command
  alias Cassian.Structs.Playlist
  alias Cassian.Utils.Embed, as: EmbedUtils
  alias Nostrum.Struct.Embed
  alias Cassian.Managers.MessageManager

  @doc """
  Show info about the playlist.
  """

  def execute(message, _args) do
    case Playlist.show(message.guild_id) do
      {:ok, playlist} ->
        send_metadata(message, playlist)

      {:error, :noop} ->
        send_not_playing(message)
    end
  end

  def send_not_playing(message) do
    EmbedUtils.create_empty_embed!()
    |> EmbedUtils.put_error_color_on_embed()
    |> Embed.put_title("I don't have any songs in the playlist.")
    |> Embed.put_description("I just don't have them. Give me songs first.")
    |> MessageManager.send_dissapearing_embed(message.channel_id)
  end

  def send_metadata(message, playlist) do
    {index, sorted} =
      playlist
      |> Playlist.order_playlist()

    metadata = Enum.at(sorted, index)

    emojis =
      [if(playlist.reverse, do: ":arrow_backward:", else: ":arrow_forward:")] ++
        if(playlist.shuffle, do: [":twisted_rightwards_arrows:"], else: []) ++
        case playlist.repeat do
          :one ->
            [":repeat_one:"]

          :all ->
            [":repeat:"]

          :none ->
            []
        end

    emojis = "#{Enum.join(emojis, " ")}  "

    embed =
      EmbedUtils.create_empty_embed!()
      |> EmbedUtils.put_color_on_embed(metadata.provider_color)
      |> Embed.put_title("#{emojis}Showing the current playlist:")

    description =
      sorted
      |> Enum.with_index()
      |> Enum.reduce([], &filter(&1, &2, index))
      |> Enum.join("\n")

    embed
    |> Embed.put_description(description)
    |> MessageManager.send_embed(message.channel_id)
  end

  defp filter({metadata, current_index}, acc, index) do
    acc ++
      [
        "#{replace_playing(current_index, index)}#{current_index + 1}: #{metadata.title}#{
          replace_playing(current_index, index)
        }"
      ]
  end

  defp replace_playing(current_index, index) when current_index == index do
    "**"
  end

  defp replace_playing(_current_index, _index) do
    ""
  end
end
