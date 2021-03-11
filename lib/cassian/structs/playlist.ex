defmodule Cassian.Structs.Playlist do
  @moduledoc """
  A struct representing a playlist and its' options.
  """

  alias Cassian.Structs.Metadata

  defstruct [
    shuffle: false,
    elements: []
  ]

  @type t() :: %__MODULE__{
          shuffle: boolean(),
          elements: list({%Metadata{}, integer() | nil})
        }

  @typedoc "A boolean representing whether it is shuffling."
  @type shuffle :: boolean()

  @typedoc """
  Elements in the playlist. Is a list of the `{%Metadata{}, integer()}` tuple.
  The first element is the metadata of the song while the other is the index
  when shuffling.
  """
  @type elements :: list({%Metadata{}, integer()})
end
