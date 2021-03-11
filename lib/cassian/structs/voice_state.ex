defmodule Cassian.Structs.VoiceState do
  alias Cassian.Structs.Metadata

  defstruct [
    :guild_id,
    :metadata,
    :status,
    :pause_seconds,
    :channel_id
  ]

  @type t() :: %__MODULE__{
          guild_id: Snowflake.t(),
          metadata: Metadata.t(),
          status: :playing | :paused | :noop,
          pause_seconds: integer(),
          channel_id: Snowflake.t()
        }

  @typedoc "The snowflake for the guild in question."
  @type guild_id :: Snowflake.t()

  @typedoc "Map containing metadata for the currently playing song."
  @type metadata :: Metadata.t()

  @typedoc "Atom regarding the status of playing."
  @type status :: :playing | :paused | :noop

  @typedoc "Integer representing at how many seconds a song was paused at."
  @type pause_seconds :: integer()

  @typedoc "ID of the channel in which to send notifications."
  @type source_channel_id :: Snowflake.t()

  @doc """
  Create a Struct connecting to this module. Metada is optional, it will be used for pausing.
  """
  @spec create!(guild_id :: Snowflake.t(), channel_id :: Snowflake.t()) :: __MODULE__.t()
  def create!(guild_id, channel_id \\ nil) do
    %__MODULE__{
      guild_id: guild_id,
      status: :noop,
      pause_seconds: 0,
      channel_id: channel_id
    }
  end

  alias Cassian.Servers.VoiceState

  defdelegate get!(guild_id), to: VoiceState
  defdelegate get(guild_id), to: VoiceState
  defdelegate put(state), to: VoiceState
  defdelegate delete(guild_id), to: VoiceState
end
