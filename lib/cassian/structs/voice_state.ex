defmodule Cassian.Structs.VoiceState do
  alias Cassian.Structs.Metadata

  defstruct [
    :guild_id,
    :metadata,
    :status,
    :pause_seconds
  ]

  @type t() :: %__MODULE__{
          guild_id: Snowflake.t(),
          metadata: Metadata.t(),
          status: :playing | :paused | :noop,
          pause_seconds: integer()
        }

  @typedoc "The snowflake for the guild in question"
  @type guild_id :: Snowflake.t()

  @typedoc "Map containing metadata for the currently playing song"
  @type metadata :: Metadata.t()

  @typedoc "Atom regarding the status of playing"
  @type status :: :playing | :paused | :noop

  @typedoc "Integer representing at how many seconds a song was paused at"
  @type pause_seconds :: integer()

  @doc """
  Create a Struct connecting to this module. Metada is optional, it will be used for pausing.
  """
  @spec create!(guild_id :: Snowflake.t(), metadata :: Metadata.t()) :: __MODULE__.t()
  def create!(guild_id, metadata \\ %Metadata{}) do
    %__MODULE__{
      guild_id: guild_id,
      metadata: metadata,
      status: :noop,
      pause_seconds: 0
    }
  end

  alias Cassian.Servers.VoiceState

  defdelegate get!(guild_id), to: VoiceState

  @doc """
  Update the status to playing and save.
  """
  @spec play_and_save!(state :: %__MODULE__{}) :: :ok
  def play_and_save!(state) do
    state |> Map.put(:status, :playing) |> VoiceState.put()
  end
end
