defmodule Cassian.Utils.Voice do
  alias Nostrum.{Snowflake, Api, ConsumerGroup}
  alias Nostrum.Cache.GuildCache
  alias Cassian.Structs.Metadata
  
  require Logger

  @doc """
  Join or switch from the voice channel. Set the channel to nil to
  leave it. It can take up to one second to get the correct event from discord
  or fail with `{:error, :failed_to_join}` tuple.
  """
  @spec join_or_switch_voice(guild_id :: Snowflake.t(), channel_id :: Snowflake.t() | nil) :: {:ok, :joined} | {:ok, :present} | {:error, :failed_to_join}
  def join_or_switch_voice(guild_id, channel_id) do
    guild_id
    |> Api.update_voice_state(channel_id, false, true)
    
    if Nostrum.Voice.ready?(guild_id) do
      {:ok, :present}
    else
      ConsumerGroup.join()
      receive do
        {:event, {:VOICE_STATE_UPDATE, %Nostrum.Struct.Event.VoiceState{}, _socket}} ->
          Logger.info("Joined voice chat on guild_id: #{inspect(guild_id)}")
          {:ok, :joined}
      after
        1_000 ->
          Logger.error("Failed to join voice chat on guild: #{guild_id}.")
          {:error, :failed_to_join}
      end
    end
  end

  @doc """
  Leave the voice channel on the guild.
  """
  @spec leave_voice(guild_id :: Snowflake.t()) :: :ok
  def leave_voice(guild_id) do
    guild_id
    |> Api.update_voice_state(nil)
  end

  defguard positive_integer(value) when is_integer(value) and value > 0

  @doc """
  Play the music with a max retry amount. If the retry amount is less than zero it will just fail automatically.
  Every retry approx lasts for approx one second.
  """
  @spec play_when_ready(metadata :: %Metadata{}, guild_id :: Snowflake.t(), max_retries :: integer()) ::
          {:ok, :ok | any()} | {:error, :failed_max} | {:error, :failed_to_get_stream}
  def play_when_ready(metadata, guild_id, max_retries)
      when is_integer(max_retries) and max_retries > 0 do
        
    Logger.info("play_when_ready/3 on guild_id: #{inspect(guild_id)} failed. Trying #{inspect(max_retries)} more tries.")
    Logger.debug("Trying to play song from metadata: #{inspect(metadata)} in guild id: #{guild_id}. Remaining retries: #{max_retries}.")
        
    if Nostrum.Voice.ready?(guild_id) do
      Logger.info("Joined voice chat on guild_id: #{inspect(guild_id)}.")
      Logger.debug("Voice is ready. Streaming audiosource: #{inspect(metadata.stream_link)}")
      {:ok, Nostrum.Voice.play(guild_id, metadata.stream_link, metadata.stream_method)}
    else
      :timer.sleep(1000)
      play_when_ready(metadata, guild_id, max_retries - 1)
    end
  end

  def play_when_ready(_, guild_id, _) do
    Logger.error("Failed to join voice chat on guild_id: #{inspect(guild_id)}.")
    {:error, :failed_max}
  end

  @doc """
  Safely the current voice id in which the user is. Also returns the guild id.
  """
  @spec sender_voice_id(interaction :: Nostrum.Struct.Interaction.t()) ::
          {:ok, {guild_id :: Snowflake.t(), channel_id :: Snowflake.t()}} | {:error, :not_in_voice}
  def sender_voice_id(interaction) do
    voice_id =
      GuildCache.get!(interaction.guild_id)
      |> Map.fetch!(:voice_states)
      |> Enum.filter(fn state -> state.user_id == interaction.user.id end)
      |> List.first()
      |> extract_id()

    if voice_id do
      {:ok, {interaction.guild_id, voice_id}}
    else
      {:error, :not_in_voice}
    end
  end

  defp extract_id(channel) do
    channel[:channel_id]
  end
end
