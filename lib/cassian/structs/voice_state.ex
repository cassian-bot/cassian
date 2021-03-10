defmodule Cassian.Structs.VoiceState do
  defstruct [
    :guild_id,
    :metadata,
    :status,
    :pause_seconds
  ]

  @type t() :: %__MODULE__{
          guild_id: Snowflake.t(),
          metadata: %{} | nil,
          status: :playing | :paused | :noop,
          pause_seconds: integer()
        }

  @typedoc "The snowflake for the guild in question"
  @type guild_id :: Snowflake.t()

  @typedoc "Map containing metadata for the currently playing song"
  @type metadata :: %{}

  @typedoc "Atom regarding the status of playing"
  @type status :: :playing | :paused | :noop

  @typedoc "Integer representing at how many seconds a song was paused at"
  @type pause_seconds :: integer()

  @spec create!(guild_id :: Snowflake.t(), metadata :: Map) :: __MODULE__.t()
  def create!(guild_id, metadata \\ %{}) do
    %__MODULE__{
      guild_id: guild_id,
      metadata: metadata,
      status: :noop,
      pause_seconds: 0
    }
  end

  alias Cassian.Servers.VoiceState

  defdelegate get!(guild_id), to: VoiceState

  def play_and_save!(state) do
    state |> Map.put(:status, :playing) |> VoiceState.put()
  end
end
