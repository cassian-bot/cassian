defmodule Cassian.Consumers.VoiceEvent do
  @moduledoc """
  Main consumer module for voice events. Play music from queues, delete queues, etc.
  """

  alias Nostrum.Struct.Event.SpeakingUpdate

  alias Cassian.Structs.VoiceState
  alias Cassian.Servers.VoiceState, as: VoiceServer

  alias Cassian.Managers.QueueManager

  require Logger

  # For voice speaking

  @doc """
  Handle the :VOICE_SPEAKING_UPDATE event. Pattern match when the bot
  stops speaking to delete the queue.
  """
  def voice_speaking_update(_)

  def voice_speaking_update(%SpeakingUpdate{guild_id: guild_id, speaking: false}) do
    VoiceState.get!(guild_id)
      |> Map.put(:status, :noop)
      |> Map.put(:metadata, %Cassian.Structs.Metadata{})
      |> VoiceServer.put()

    QueueManager.play_if_needed(guild_id)
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
    if user_id == Cassian.own_id() do
      Cassian.Servers.Queue.delete(guild_id)
      VoiceServer.delete(guild_id)
    end
    :ok
  end

  @doc false
  def voice_state_update(_) do
    :noop
  end
end
