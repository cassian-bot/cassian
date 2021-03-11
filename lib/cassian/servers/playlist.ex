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
  Safely return the current playlist.
  """
  @spec show(guild_id :: Snowflake.t()) :: {:ok, %Playlist{}} | {:error, :noop}
  def show(guild_id) do
    if exists?(guild_id),
    do: {:ok, GenServer.call(from_guild_id(guild_id), :show)},
    else: {:error, :noop}
  end

  @doc """
  Insert a metdata into a playlist. If the playlist doesn't exist, start it.
  """
  @spec insert!(guild_id :: Snowflake.t(), metadata :: %Metadata{}) :: :ok
  def insert!(guild_id, metadata) do
    unless exists?(guild_id) do
      start(guild_id, metadata)
    else
      GenServer.cast(from_guild_id(guild_id), {:insert, metadata})
    end
  end

  @doc """
  Delete the playlist. Ignores if it doesn't exist
  """
  @spec delete(guild_id :: Snowflake.t()) :: :ok
  def delete(guild_id) do
    if exists?(guild_id), do: GenServer.stop(from_guild_id(guild_id))
    :ok
  end

  @doc """
  Shuffle the playlist. Returns `:error` if the playlist doesn't exist.
  """
  @spec shuffle(guild_id :: Snowflake.t()) :: :ok | :error
  def shuffle(guild_id) do
    if exists?(guild_id) do
      GenServer.cast(from_guild_id(guild_id), :shuffle)
      :ok
    else
      :error
    end
  end

  @doc """
  Unshuffle the playlist. Returns `:error` if the playlist doesn't exist.
  """
  @spec unshuffle(guild_id :: Snowflake.t()) :: :ok | :error
  def unshuffle(guild_id) do
    if exists?(guild_id) do
      GenServer.cast(from_guild_id(guild_id), :unshuffle)
      :ok
    else
      :error
    end
  end

  @doc """
  Safe get the ordered list from the current GenServer state.
  """
  @spec get_ordered_playlist(guild_id :: Snowflake.t()) :: {:ok, {integer(), list(%Metadata{})}} | {:error, :noop}
  def get_ordered_playlist(guild_id) do
    case show(guild_id) do
      {:error, :noop} ->
        {:error, :noop}

      {:ok, playlist} ->
        {:ok, Playlist.order_playlist(playlist)}
    end
  end

  @doc """
  Put the new playlist.
  """
  @spec put(playlist :: %Playlist{}) :: :ok | :noop
  def put(playlist) do
    if exists?(playlist.guild_id) do
      GenServer.cast(from_guild_id(playlist.guild_id), {:put, playlist})
      :ok
    else
      :error
    end
  end

  # Private API

  @doc false
  def handle_call(:show, _from, state) do
    {:reply, state, state}
  end

  @doc false
  def handle_cast({:put, playlist}, _state) do
    {:noreply, playlist}
  end

  @doc false
  def handle_cast({:insert, metadata}, state) do
    state =
      state
      |> Map.put(:elements, state.elements ++ [{metadata, nil}])

    {:noreply, state}
  end

  @doc false
  def handle_cast(:shuffle, state) do
    size = length(state.elements) - 1

    # Generating indexes for the new shuffle

    shuffled_indexes =
      0..(size)
      |> Enum.to_list()
      |> Enum.shuffle()

    # Update all of the elements with a new shuffle index

    new_elements =
      0..(size)
      |> Enum.map(&extract_reshuffled(&1, state, shuffled_indexes))

    # Extract the new index of the current song playing

    {_metadata, new_index} = Enum.at(new_elements, state.index)

    # Set the current index to the new shuflfed one
    # Set all of the elements to the new ones

    state =
      state
      |> Map.put(:index, new_index)
      |> Map.put(:elements, new_elements)
      |> Map.put(:shuffle, true)

    {:noreply, state}
  end

  def handle_cast(:unshuffle, state) do
    current_meta_index =
      state.elements
      |> Enum.find_index(fn {_meta, index} -> index == state.index end)

    state =
      state
      |> Map.put(:shuffle, false)
      |> Map.put(:index, current_meta_index)

    {:noreply, state}
  end

  defp extract_reshuffled(index, state, shuffled_indexes) do
    {metadata, _index} = Enum.at(state.elements, index)
    {metadata, Enum.at(shuffled_indexes, index)}
  end

  @doc false
  def start(guild_id, metadata) do
    GenServer.start(__MODULE__, %Playlist{elements: [{metadata, nil}], guild_id: guild_id}, name: from_guild_id(guild_id))
  end

  @doc false
  def init(args) do
    {:ok, args}
  end

  @doc false
  defp from_guild_id(guild_id), do: "playlist_#{guild_id}" |> String.to_atom()
end
