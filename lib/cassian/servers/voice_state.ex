defmodule Cassian.Servers.VoiceState do
  @moduledoc """
  A GenServer representing the current voice state.
  """

  alias Cassian.Structs.VoiceState

  require Logger

  @timeout 60_000

  use GenServer

  @doc """
  Check is a VoiceState exists for a guild.
  """
  @spec exists?(guild_id :: Snowflake.t()) :: boolean()
  def exists?(guild_id) do
    !!Process.whereis(from_guild_id(guild_id))
  end

  @doc """
  Delete the VoiceState.
  """
  @spec delete(guild_id :: Snowflake.t()) :: :ok
  def delete(guild_id) do
    if exists?(guild_id), do: GenServer.stop(from_guild_id(guild_id))
    :ok
  end

  @doc """
  Get the `VoiceState` from voice. Returns an existing or creates and stores in the GenServer.
  """
  @spec get!(guild_id :: Snowflake.t()) :: %VoiceState{}
  def get!(guild_id) do
    if exists?(guild_id) do
      GenServer.call(from_guild_id(guild_id), {:get})
    else
      state = VoiceState.create!(guild_id)
      start(guild_id, state)
      state
    end
  end

  @doc """
  Put the `VoiceState`.
  """
  @spec put(state :: %VoiceState{}) :: :ok
  def put(state) do
    GenServer.cast(from_guild_id(state.guild_id), {:put, state})
  end

  # Private API

  @doc false
  def handle_call({:get}, _from, state) do
    {:reply, state, state, @timeout}
  end

  @doc false
  def handle_cast({:put, new}, _state) do
    Logger.debug("Putting new value #{Poison.encode!(new)}")
    {:noreply, new, @timeout}
  end

  @doc false
  def handle_info(:timeout, %VoiceState{status: :noop} = state) do
    Logger.debug("Matched #{Poison.encode!(state)}")
    {:stop, {:shutdown, :afk}, state}
  end

  @doc false
  def handle_info(:timeout, state) do
    Logger.debug("Not matched #{Poison.encode!(state)}")
    {:noreply, state, @timeout}
  end

  @doc false
  def init(state) do
    {:ok, state, @timeout}
  end

  def terminate({:shutdown, :afk}, state) do
    Logger.debug("Clossing #{Poison.encode!(state)}")
    Cassian.Utils.Voice.join_or_switch_voice(state.guild_id, nil)
    {:shutdown, :afk}
  end

  def terminate(:normal, _) do
    :normal
  end

  @doc false
  def start(guild_id, state) do
    GenServer.start(__MODULE__, state, name: from_guild_id(guild_id))
  end

  @doc false
  defp from_guild_id(guild_id), do: "voice_state_#{guild_id}" |> String.to_atom()
end
