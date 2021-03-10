defmodule Cassian.Consumers.VoiceEvent do
  @moduledoc """
  Main consumer module for voice events. Play music from queues, delete queues, etc.
  """

  alias Nostrum.Struct.Event.SpeakingUpdate

  # For voice speaking

  @doc """
  Handle the :VOICE_SPEAKING_UPDATE event. Pattern match when the bot
  stops speaking to delete the queue.
  """
  def voice_speaking_update(%SpeakingUpdate{guild_id: guild_id, speaking: false}) do
    if Cassian.Servers.Queue.exists?(guild_id),
      do: handle_queue(guild_id, Cassian.Servers.Queue.empty?(guild_id))

    :ok
  end

  @doc false
  def voice_speaking_update(_) do
    :noop
  end

  # For voice state

  @doc """
  Pattern match the current voice state.
  """
  def voice_state_update(%{channel_id: nil, guild_id: guild_id, user_id: user_id}) do
    if user_id == Cassian.own_id(), do: Cassian.Servers.Queue.delete(guild_id)
    :ok
  end

  @doc false
  def voice_state_update(_) do
    :noop
  end

  # General logic which is called by patterns

  defp handle_queue(guild_id, true), do: Cassian.Servers.Queue.delete(guild_id)

  defp handle_queue(guild_id, false) do
    link = Cassian.Servers.Queue.pop!(guild_id)
    Cassian.Utils.Voice.play_when_ready!(link, guild_id)
  end
end
