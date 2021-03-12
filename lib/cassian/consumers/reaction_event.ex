defmodule Cassian.Consumers.ReactionEvent do

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

  def handle_event(%{emoji: %{name: emoji}} = data) when emoji in @reactions do
    try do
      message = Nostrum.Api.get_channel_message!(data.channel_id, data.message_id)
      if message.author.id == Cassian.own_id() do
        case emoji do
          @backwards ->
            # Play backwards
            IO.inspect("Backwards")

          @previous ->
            # Play previous
            IO.inspect("Previous")

          @play_pause ->
            # Play or pause
            IO.inspect("Play pause")

          @stop ->
            # Stop
            IO.inspect("Stop")

          @next ->
            # Next
            IO.inspect("Next")

          @shuffle ->
            # Shuffle
            IO.inspect("Shuffle")

          @repeat ->
            # Repeat
            IO.inspect("Repeat")

          @repeat_one ->
            # Repeat one
            IO.inspect("Repeat one")

          @forwards ->
            # next
            IO.inspect("Forwards")

        end
      end
    rescue
      Nostrum.Error.ApiError ->
        nil
    end
  end

  def handle_event(_) do
    :noop
  end
end
