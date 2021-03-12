defmodule Cassian.Consumers.ReactionEvent do
  #alias Cassian.Structs.Playlist
  require Logger

  @backwards "⬅️"
  @previous "⏮️"
  @play_pause "⏯️"
  @stop "⏹️"
  @next "⏭️"
  @shuffle "🔀"
  @repeat "🔁"
  @repeat_one "🔂"
  @forwards "➡️"

  @reactions [@backwards, @previous, @play_pause, @stop, @next, @shuffle, @repeat, @repeat_one, @forwards]

  # Handlers as the consumers

  def handle_event(%{emoji: %{name: emoji}} = data) when emoji in @reactions do
    try do
      message = Nostrum.Api.get_channel_message!(data.channel_id, data.message_id)
      if message.author.id == Cassian.own_id(),
        do: handle_emoji(emoji, message)
    rescue
      Nostrum.Error.ApiError ->
        nil
    end
  end

  def handle_event(_) do
    :noop
  end

  # Emoji action handlers

  defp handle_emoji(@backwards, _message) do
    Logger.info("Playing backwards")
  end

  defp handle_emoji(@previous, _message) do
    Logger.info("Playing previous")
  end

  defp handle_emoji(@play_pause, _message) do
    Logger.info("Pllay/Pause")
  end

  defp handle_emoji(@stop, _message) do
    Logger.info("Stopping music")
  end

  defp handle_emoji(@next, _message) do
    Logger.info("Playing next")
  end

  defp handle_emoji(@shuffle, _message) do
    Logger.info("Shufling / Disabling shuffle")
  end

  defp handle_emoji(@repeat, _message) do
    Logger.info("Playing on repeat")
  end

  defp handle_emoji(@repeat_one, _message) do
    Logger.info("Repeating one")
  end

  defp handle_emoji(@forwards, _message) do
    Logger.info("Playing forwards")
  end

end
