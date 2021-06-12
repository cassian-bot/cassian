defmodule Cassian.Structs.Metadata do
  defstruct [
    :title,
    :author,
    :provider,
    :link,
    :thumbnail_url,
    :stream_link,
    :stream_method
  ]

  @type t() :: %__MODULE__{
          title: String.t(),
          author: String.t(),
          provider: String.t(),
          link: String.t(),
          thumbnail_url: String.t(),
          stream_link: String.t(),
          stream_method: :url | :ytdl
        }

  @typedoc "The title of the song."
  @type title :: String.t()

  @typedoc "The name of the song author."
  @type author :: String.t()

  @typedoc "The provider for the song."
  @type provider :: String.t()

  @typedoc "The original link for the song."
  @type link :: String.t()

  @typedoc "The thumbnail for the song."
  @type thumbnail_url :: String.t()

  @typedoc "The link for the song stream."
  @type stream_link :: String.t()

  @typedoc "Streaming method for the song."
  @type stream_method :: :url | :ytdl
end
