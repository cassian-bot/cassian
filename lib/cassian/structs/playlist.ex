defmodule Cassian.Structs.Playlist do
  @moduledoc """
  A struct representing a playlist and its' options.
  """

  alias Cassian.Servers.Playlist
  alias Cassian.Structs.Metadata

  defstruct [
    :guild_id,
    shuffle: false,
    reverse: false,
    elements: [],
    shuffle_indexes: [],
    index: 0,
    repeat: :none
  ]

  @type t() :: %__MODULE__{
          shuffle: boolean(),
          reverse: boolean(),
          elements: list(%Metadata{}),
          index: integer(),
          guild_id: Snowflake.t(),
          repeat: :none | :one | :all,
          shuffle_indexes: list(integer())
        }

  @typedoc "A boolean representing whether it is shuffling."
  @type shuffle :: boolean()

  @typedoc """
  Elements in the playlist.
  """
  @type elements :: list(%Metadata{})

  @typedoc """
  The current index in the playlist.
  """
  @type index :: integer()

  @typedoc """
  Should the playlist be played in reverse.
  """
  @type reverse :: boolean()

  @typedoc """
  The ID of the associated guild.
  """
  @type guild_id :: Snowflake.t()

  @typedoc """
  Set whether the playlist should repeat or not.
  """
  @type repeat :: :one | :none | :all

  @typedoc """
  The indexes of the songs in shuffled regime
  """
  @type shuffle_indexes :: list(integer())

  defdelegate exists?(guild_id), to: Playlist
  defdelegate show(guild_id), to: Playlist
  defdelegate insert!(guild_id, metadata), to: Playlist
  defdelegate delete(guild_id), to: Playlist
  defdelegate shuffle(guild_id), to: Playlist
  defdelegate unshuffle(guild_id), to: Playlist
  defdelegate put(playlist), to: Playlist

  defp reverse_magick(%__MODULE__{reverse: false, index: index}, sorted) do
    {index, sorted}
  end

  defp reverse_magick(%__MODULE__{index: index}, sorted) do
    sorted = Enum.reverse(sorted)
    index = length(sorted) - 1 - index
    {index, sorted}
  end

  @doc """
  Order the playlist. Returns the ordered list with the index of the current song.
  It doesn't reverse the list.
  """
  @spec order_playlist(playlist :: %__MODULE__{}) :: {integer(), list(%Metadata{})}
  def order_playlist(playlist),
    do: indexed_sorted(playlist)

  @doc false
  defp indexed_sorted(playlist) do
    sorted =
      if playlist.shuffle do
        shuffle_sort(playlist)
      else
        extract_metadatas_ordered(playlist.elements)
      end

    reverse_magick(playlist, sorted)
  end

  @doc """
  Sort the playlist to how it should play when it is being shuffled.
  """
  @spec shuffle_sort(playlist :: %__MODULE__{}) :: list(%Metadata{})
  def shuffle_sort(playlist) do
    Enum.sort_by(playlist.elements, fn {_metadata, index} -> index end)
    |> extract_metadatas_ordered()
  end

  @doc """
  Extract the metadatas from an already-ordered list.
  """
  def extract_metadatas_ordered(elements) do
    Enum.reduce(elements, [], fn {metadata, _index}, acc -> acc ++ [metadata] end)
  end
end
