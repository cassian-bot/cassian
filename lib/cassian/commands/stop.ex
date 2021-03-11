defmodule Cassian.Commands.Stop do
  use Cassian.Behaviours.Command
  alias Cassian.Managers.{QueueManager, MessageManager}
  alias Cassian.Structs.{Metadata, VoiceState}
  alias Cassian.Utils.Embed, as: EmbedUtils
  alias Nostrum.Struct.Embed

  def caller, do: "stop"
  def desc, do: "Stop the musing playing."
  def ship?, do: true

  def execute(message, _args) do
    case VoiceState.get(message.guild_id) do
      {:ok, state} ->
        QueueManager.clear!(message.guild_id)

        state
        |> Map.put(:metadata, %Metadata{})
        |> VoiceState.put()

        Nostrum.Voice.stop(message.guild_id)

        notify_stopped(message)
      {:error, :noop} ->
        notify_not_playing(message)
    end
  end

  def notify_stopped(message) do
    EmbedUtils.create_empty_embed!()
    |> Embed.put_title("Stopped music.")
    |> Embed.put_description("The music has been stopeed.")
    |> MessageManager.send_dissapearing_embed(message.channel_id)
  end

  def notify_not_playing(message) do
    EmbedUtils.create_empty_embed!()
    |> Embed.put_title("Music is not playing.")
    |> Embed.put_description("I can't stop music if I don't have any playing...")
    |> MessageManager.send_dissapearing_embed(message.channel_id)
  end
end
