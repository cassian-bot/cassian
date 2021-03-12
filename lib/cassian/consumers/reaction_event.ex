defmodule Cassian.Consumers.ReactionEvent do
  require Logger

  alias Cassian.Managers.PlayManager

  @backwards "⬅️"
  @previous "⏮️"
  @play_pause "⏯️"
  @stop "⏹️"
  @next "⏭️"
  @shuffle "🔀"
  @repeat "🔁"
  @repeat_one "🔂"
  @forwards "➡️"

  @reactions [
    @backwards,
    @previous,
    @play_pause,
    @stop,
    @next,
    @shuffle,
    @repeat,
    @repeat_one,
    @forwards
  ]

  # Handlers as the consumers

  def handle_event(%{emoji: %{name: emoji}} = data) when emoji in @reactions do
    unless data.user_id == Cassian.own_id() do
      try do
        message = Nostrum.Api.get_channel_message!(data.channel_id, data.message_id)
        guild_id = Nostrum.Api.get_channel!(data.channel_id).guild_id

        if message.author.id == Cassian.own_id(),
          do: handle_emoji(emoji, Map.put(message, :guild_id, guild_id))
      rescue
        Nostrum.Error.ApiError ->
          nil
      end
    end
  end

  def handle_event(_) do
    :noop
  end

  # Emoji action handlers

  defp handle_emoji(@backwards, message) do
    PlayManager.change_direction_with_notification(message, true)
  end

  defp handle_emoji(@previous, message) do
    PlayManager.switch_song_with_notification(message, false)
  end

  defp handle_emoji(@play_pause, _message) do
    Logger.info("Play/Pause")
  end

  defp handle_emoji(@stop, _message) do
    Logger.info("Stopping music")
  end

  defp handle_emoji(@next, message) do
    PlayManager.switch_song_with_notification(message, true)
  end

  defp handle_emoji(@shuffle, _message) do
    Logger.info("Shufling / Disabling shuffle")
  end

  defp handle_emoji(@repeat, message) do
    PlayManager.change_repeat_with_notification(message, :all)
  end

  defp handle_emoji(@repeat_one, message) do
    PlayManager.change_repeat_with_notification(message, :one)
  end

  defp handle_emoji(@forwards, message) do
    PlayManager.change_direction_with_notification(message, false)
  end
end
