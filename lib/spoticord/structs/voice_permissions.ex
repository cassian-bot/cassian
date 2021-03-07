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

  def from_number(value) do
    %__MODULE__{
      administrator: Util.admin?(value),
      view_channel: Util.view_channel?(value),
      connect: Util.connect?(value),
      speak: Util.speak?(value)
    }
  end

  def base_server_permissions(guild_id) do
    Util.base_permissions(guild_id)
    |> from_number()
  end

  def channel_permission(user, guild_id, channel_id) do
    Util.channel_permissions(user, guild_id, channel_id)
    |> from_number()
  end

  def my_channel_permissions(guild_id, channel_id), do:
    channel_permission(Nostrum.Cache.Me.get(), guild_id, channel_id)
end
