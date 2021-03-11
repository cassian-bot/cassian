defmodule Cassian.Servers.Playlist do
  @moduledoc """
  A GenServer representing a playlist for a guild.
  """

  use GenServer

  alias Cassian.Structs.{Metadata, Playlist}

  @doc """
  Check is a playlist exists for a guild.
  """
  @spec exists?(guild_id :: Snowflake.t()) :: boolean()
  def exists?(guild_id) do
    !!Process.whereis(from_guild_id(guild_id))
  end

  @doc """
  Insert metadata into a playlist, won't work if the playlist doesn't
  exist.
  """
  @spec insert(guild_id :: Snowflake.t(), metadata :: %Metadata{}) :: :ok
  def insert(guild_id, metadata) do
    GenServer.cast(from_guild_id(guild_id), {:insert, {metadata, nil}})
  end

  @doc """
  Insert a metdata into a playlist. If the queue doesn't exist, start it.
  """
  @spec insert!(guild_id :: Snowflake.t(), metadata :: %Metadata{}) :: :ok
  def insert!(guild_id, metadata) do
    unless exists?(guild_id) do
      start(guild_id, metadata)
    else
      insert(guild_id, metadata)
    end
  end

  @doc """
  Pop a metadata out of the queue.
  """
  @spec pop!(guild_id :: Snowflake.t()) :: %Metadata{}
  def pop!(guild_id) do
    GenServer.call(from_guild_id(guild_id), {:pop})
  end

  @doc """
  Remove a metadata out of the queue.
  """
  @spec remove!(guild_id :: Snowflake.t(), metadata :: %Metadata{}) :: :ok
  def remove!(guild_id, link) do
    GenServer.cast(from_guild_id(guild_id), {:remove, [link]})
  end

  @doc """
  Show all of the metadatas in the queue.
  """
  @spec show(guild_id :: Snowflake.t()) :: list(%Metadata{})
  def show(guild_id) do
    GenServer.call(from_guild_id(guild_id), {:show})
  end

  @doc """
  Delete the queue.
  """
  @spec delete(guild_id :: Snowflake.t()) :: :ok
  def delete(guild_id) do
    if exists?(guild_id), do: GenServer.stop(from_guild_id(guild_id))
    :ok
  end

  @doc """
  Check whether the queue is empty.
  """
  @spec empty?(guild_id :: Snowflake.t()) :: boolean()
  def empty?(guild_id) do
    Enum.empty?(show(guild_id))
  end

  # Private API

  @doc false
  def handle_call({:show}, _from, state) do
    {:reply, state, state}
  end

  @doc false
  def handle_call({:pop}, _from, state) do
    {metadata, state} = List.pop_at(state, 0)
    {:reply, metadata, state}
  end

  @doc false
  def handle_cast({:remove, metadata}, state) do
    state = state -- [metadata]
    {:noreply, state}
  end

  @doc false
  def handle_cast({:insert, metadata}, state) do
    state = state ++ [metadata]
    {:noreply, state}
  end

  @doc false
  def start(guild_id, metadata) do
    GenServer.start_link(__MODULE__, [metadata], name: from_guild_id(guild_id))
  end

  @doc false
  def init(args) do
    {:ok, args}
  end

  @doc false
  defp from_guild_id(guild_id), do: "queue_#{guild_id}" |> String.to_atom()
end
