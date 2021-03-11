defmodule Cassian.Structs.Playlist do
  @moduledoc """
  A struct representing a playlist and its' options.
  """

  alias Cassian.Servers.Playlist
  alias Cassian.Structs.Metadata

  defstruct [
    shuffle: false,
    elements: [],
    index: 0
  ]

  @type t() :: %__MODULE__{
          shuffle: boolean(),
          elements: list({%Metadata{}, integer() | nil}),
          index: integer()
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

  defdelegate exists?(guild_id), to: Playlist
  defdelegate show(guild_id), to: Playlist
  defdelegate insert!(guild_id, metadata), to: Playlist
  defdelegate delete(guild_id), to: Playlist
  defdelegate shuffle(guild_id), to: Playlist
end
