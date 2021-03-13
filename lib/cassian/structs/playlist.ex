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

  @doc """
  Order the playlist. Returns the ordered list with the index of the current song.
  """
  @spec order_playlist(playlist :: %__MODULE__{}) :: {integer(), list(%Metadata{})}
  def order_playlist(playlist) do
    index = playlist.index

    sorted =
      if playlist.shuffle do
        Enum.map(playlist.shuffle_indexes, fn index -> Enum.at(playlist.elements, index) end)
      else
        playlist.elements
      end

    reverse_magick(index, sorted, playlist.reverse)
  end

  defp reverse_magick(index, sorted, false) do
    {index, sorted}
  end

  defp reverse_magick(index, sorted, _) do
    sorted = Enum.reverse(sorted)
    index = length(sorted) - 1 - index
    {index, sorted}
  end
end
