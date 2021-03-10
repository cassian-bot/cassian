defmodule Cassian.Managers.QueueManager do
  @moduledoc """
  Manager for queues.
  """

  alias Cassian.Servers.{Queue,VoiceState}
  alias Cassian.Utils.Voice

  defdelegate insert!(guild_id, metadata), to: Queue

  def play_if_needed(guild_id) do
    state = VoiceState.get!(guild_id)

    if state.status == :noop and Queue.exists?(guild_id) do
      unless Queue.show(guild_id) == [] do
        metadata = Queue.pop!(guild_id)
        Voice.play_when_ready!(metadata.youtube_link, guild_id)

        state
        |> Map.put(:metadata, metadata)
        |> Map.put(:status, :playing)
        |> VoiceState.put()
      else
        Queue.delete(guild_id)
      end
    end
  end
end
