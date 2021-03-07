defmodule Spoticord.Structs.VoicePermissions do

  @moduledoc """
  Struct for the permissions of the bot. Generally this should be
  used per channel...
  """

  defstruct [
    :administrator,
    :view_channel,
    :connect,
    :speak
  ]

  @type t() :: %__MODULE__{
    administrator: boolean(),
    view_channel: boolean(),
    connect: boolean(),
    speak: boolean()
  }

  @typedoc "Permission whether the bot is an admin."
  @type administrator :: boolean()

  @typedoc "Permission whether the bot can view the channel."
  @type view_channel :: boolean()

  @typedoc "Permission whether the bot can connect to the channel."
  @type connect :: boolean()

  @typedoc "Permission whether the bot can speak in the channel"
  @type speak :: boolean()

  alias Spoticord.Utils.Permissions, as: Util

  @doc """
  Generate the struct from the perm number.
  """
  @spec from_number(value :: integer()) :: __MODULE__.t()
  def from_number(value) do
    %__MODULE__{
      administrator: Util.admin?(value),
      view_channel: Util.view_channel?(value),
      connect: Util.connect?(value),
      speak: Util.speak?(value)
    }
  end

  @doc """
  Get the base server permissions.
  """
  @spec base_server_permissions(guild_id :: Snowflake.t()) :: __MODULE__.t()
  def base_server_permissions(guild_id) do
    Util.server_permissions(guild_id)
    |> from_number()
  end

  @doc """
  Get the permission for a channel in a guild.
  """
  @spec channel_permission(user :: Nostrum.Struct.User, guild_id :: Snowflake.t(), channel_id :: Snowflake.t()) ::__MODULE__.t()
  def channel_permission(user, guild_id, channel_id) do
    Util.channel_permissions(user, guild_id, channel_id)
    |> from_number()
  end

  @doc """
  Get the permission for a channel in a guild for this bot.
  """
  @spec my_channel_permissions(guild_id :: Snowflake.t(), channel_id :: Snowflake.t()) ::__MODULE__.t()
  def my_channel_permissions(guild_id, channel_id), do:
    channel_permission(Nostrum.Cache.Me.get(), guild_id, channel_id)
end
