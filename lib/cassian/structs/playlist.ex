defmodule Cassian.Structs.Playlist do
  @moduledoc """
  A struct representing a playlist and its' options.
  """

  alias Cassian.Servers.Playlist
  alias Cassian.Structs.Metadata

  defstruct [
    shuffle: false,
    reverse: false,
    elements: [],
    index: 0
  ]

  @type t() :: %__MODULE__{
          shuffle: boolean(),
          reverse: boolean(),
          elements: list({%Metadata{}, integer() | nil}),
          index: integer(),
        }

  @typedoc "A boolean representing whether it is shuffling."
  @type shuffle :: boolean()

  @typedoc """
  Elements in the playlist. Is a list of the `{%Metadata{}, integer()}` tuple.
  The first element is the metadata of the song while the other is the index
  when shuffling.
  """
  @type elements :: list({%Metadata{}, integer()})

  @typedoc """
  The current index in the playlist.
  """
  @type index :: integer()

  @typedoc """
  Should the playlist be played in reverse.
  """
  @type reverse :: boolean()

  defdelegate exists?(guild_id), to: Playlist
  defdelegate show(guild_id), to: Playlist
  defdelegate insert!(guild_id, metadata), to: Playlist
  defdelegate delete(guild_id), to: Playlist
  defdelegate shuffle(guild_id), to: Playlist
  defdelegate unshuffle(guild_id), to: Playlist

  @doc """
  Order the playlist. Returns the ordered list with the index of the current song.
  It doesn't reverse the list. Reversing has to be handled on the usage side.
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

    {playlist.index, sorted}
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
