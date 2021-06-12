defmodule Cassian.Structs.Metadata do
  defstruct [
    :title,
    :author,
    :provider,
    :link,
    :stream_link,
    :stream_method
  ]

  @type t() :: %__MODULE__{
          title: String.t(),
          author: String.t(),
          provider: String.t(),
          link: String.t(),
          stream_link: String.t(),
          stream_method: :url | :ytdl
        }

  @typedoc ""
  @type title :: String.t()

  @typedoc ""
  @type author :: String.t()

  @typedoc ""
  @type provider :: String.t()

  @typedoc ""
  @type link :: String.t()

  @typedoc ""
  @type stream_link :: String.t()

  @typedoc ""
  @type stream_method :: :url | :ytdl
end
