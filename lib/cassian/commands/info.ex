defmodule Cassian.Commands.Show do
  use Cassian.Behaviours.Command
  alias Cassian.Structs.VoiceState
  alias Cassian.Utils.Embed, as: EmbedUtils
  alias Nostrum.Struct.Embed
  alias Cassian.Managers.{MessageManager, QueueManager}

  def ship?, do: true
  def caller, do: "info"
  def desc, do: "Information the current song and some of the others in the playlist."

  def execute(message, _args) do
    case VoiceState.get(message.guild_id) do
      {:ok, state} ->
        if state.metadata do
          send_metadata(message, state)
        else
          send_not_playing(message)
        end

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

  def send_metadata(message, state) do
    embed =
      EmbedUtils.create_empty_embed!()
      |> EmbedUtils.put_color_on_embed(state.metadata.provider_color)
      |> Embed.put_title("Currenly playing: #{state.metadata.title}")
      |> Embed.put_url(state.metadata.youtube_link)

    queue =
      QueueManager.show(message.guild_id)
      |> Enum.reduce([], fn metadata, acc -> acc ++ [metadata.title] end)
      |> Enum.join("\n")

    embed
    |> Embed.put_description(queue)
    |> MessageManager.send_embed(message.channel_id)
  end
end
