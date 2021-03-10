defmodule Cassian.Structs.Metadata do
  defstruct [
    :title,
    :author_name,
    :author_url,
    :provider_name,
    :provider_url,
    :provider_color,
    :link,
    :youtube_link
  ]

  @type t() :: %__MODULE__{
          title: String.t(),
          author_name: String.t(),
          author_url: String.t(),
          provider_name: String.t(),
          provider_url: String.t(),
          provider_color: String.t(),
          link: String.t(),
          youtube_link: String.t()
        }

  @typedoc "Permission whether the bot is an admin."
  @type administrator :: boolean()

  @typedoc "The title of the song."
  @type title :: String.t()

  @typedoc "The name of the author."
  @type author_name :: String.t()

  @typedoc "The URL of the author."
  @type author_url :: String.t()

  @typedoc "The name of the provider."
  @type provider_name :: String.t()

  @typedoc "The URL of the provider."
  @type provider_url :: String.t()

  @typedoc "The associated color of the provider in hex."
  @type provider_color :: String.t()

  @typedoc "The link of the song."
  @type link :: String.t()

  @typedoc "The youtube link of the song."
  @type youtube_link :: String.t()

  def from_youtube_hash(hash, link) do
    %__MODULE__{
      title: hash["title"],
      author_name: hash["author_name"],
      author_url: hash["author_url"],
      provider_name: hash["provider_name"],
      provider_url: hash["provider_url"],
      provider_color: "#ff0000",
      link: link,
      youtube_link: link
    }
  end
end
