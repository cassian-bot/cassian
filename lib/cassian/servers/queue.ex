defmodule Cassian.Servers.Queue do
  @moduledoc """
  A GenServer representing a queue for a guild.
  """

  use GenServer

  @doc """
  Check is a Queue exists for a guild.
  """
  @spec exists?(guild_id :: Snowflake.t()) :: boolean()
  def exists?(guild_id) do
    !!Process.whereis(from_guild_id(guild_id))
  end

  @doc """
  Insert link into a queue, won't work if the Queue doesn't
  exist.
  """
  @spec insert(guild_id :: Snowflake.t(), link :: String.t()) :: :ok
  def insert(guild_id, link) do
    GenServer.cast(from_guild_id(guild_id), {:insert, [link]})
  end

  @doc """
  Insert a link into a queue. If the queue doesn't exist, start it.
  """
  @spec insert!(guild_id :: Snowflake.t(), link :: String.t()) :: :ok
  def insert!(guild_id, link) do
    unless exists?(guild_id) do
      start(guild_id, [link])
    else
      insert(guild_id, link)
    end
  end

  @doc """
  Pop a link out of the queue.
  """
  @spec pop!(guild_id :: Snowflake.t()) :: String.t()
  def pop!(guild_id) do
    GenServer.call(from_guild_id(guild_id), {:pop})
  end

  @doc """
  Remove a specific link out of the queue.
  """
  @spec remove!(guild_id :: Snowflake.t(), link :: String.t()) :: :ok
  def remove!(guild_id, link) do
    GenServer.cast(from_guild_id(guild_id), {:remove, [link]})
  end

  @doc """
  Show all of the songs in the queue.
  """
  @spec show(guild_id :: Snowflake.t()) :: list(String.t())
  def show(guild_id) do
    GenServer.call(from_guild_id(guild_id), {:show})
  end

  @doc """
  Delete the queue.
  """
  @spec delete(guild_id :: Snowflake.t()) :: :ok
  def delete(guild_id) do
    GenServer.stop(from_guild_id(guild_id))
  end

  @doc """
  Delete the queue of the queue is empty.
  """
  @spec delete_if_empty(guild_id :: Snowflake.t()) :: :ok | :noop
  def delete_if_empty(guild_id) do
    if exists?(guild_id) do
      GenServer.stop(from_guild_id(guild_id))
    else
      :noop
    end
  end

  # Private API

  def handle_call({:show}, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:pop}, _from, state) do
    {element, state} = List.pop_at(state, 0)
    {:reply, element, state}
  end

  @doc false
  def handle_cast({:remove, link}, state) do
    state = state -- link
    {:noreply, state}
  end

  @doc false
  def handle_cast({:insert, link}, state) do
    state = state ++ link
    {:noreply, state}
  end

  @doc false
  def start(guild_id, links) do
    GenServer.start_link(__MODULE__, links, name: from_guild_id(guild_id))
  end

  @doc false
  def init(args) do
    {:ok, args}
  end

  @doc false
  defp from_guild_id(guild_id), do: "queue_#{guild_id}" |> String.to_atom()
end
