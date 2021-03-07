defmodule Spoticord.Utils.Permissions do
  alias Nostrum.Cache.{GuildCache, ChannelCache}
  use Bitwise

  @moduledoc """
  Util module for building permissions for the bot.
  """

  @doc """
  Get the channel permission for the bot. Doesn't give a struct but rather a flag-number
  which can be later used to extract the permissions bits from (is a bit really because it's hexadecimal but okay)
  """
  @spec channel_permissions(user :: Nostrum.Struct.User, guild_id :: Snowflake.t(), channel_id :: Snowflake.t()) :: integer()
  def channel_permissions(user, guild_id, channel_id) do
    user_id = user.id
    roles = GuildCache.get!(guild_id).members[user_id].roles

    overs =
      ChannelCache.get!(channel_id)
      |> Map.get(:permission_overwrites)
      |> Enum.filter(&connected?(&1, roles, user_id))
      |> Enum.reduce(%{allows: [], denies: []}, &accumulate_overs/2)

    perms =
      Enum.reduce(overs.denies, server_permissions(guild_id), fn deny, perms -> perms &&& (~~~deny) end)

    Enum.reduce(overs.allows, perms, fn allow, perms -> perms ||| allow end)
  end

  defp accumulate_overs(over, acc) do
    %{allows: acc.allows ++ [over.allow], denies: acc.denies ++ [over.deny]}
  end

  defp connected?(overwrite, roles, user_id) do
    case overwrite.type do
      :role ->
        overwrite.id in roles
      :member ->
        overwrite.id == user_id
    end
  end

  @doc """
  Get the permissoin of the server for the role name
  """
  @spec server_permissions(guild_id :: Snowflake.t(), name :: String.t()) :: integer()
  def server_permissions(guild_id, name \\ "@everyone") do
    GuildCache.get!(guild_id).roles
    |> Enum.reduce([], fn {_, role}, acc -> acc ++ [role] end)
    |> Enum.filter(fn role -> role.name == name end)
    |> List.first()
    |> Map.get(:permissions)
  end

  @doc """
  Check whether the integer has a permission.
  """
  @spec has_perm(value :: integer(), perm :: integer()) :: boolean()
  def has_perm(value, perm) do
    (value &&& perm) == perm
  end

  @doc """
  Check whether the value has the `connect` permission.
  """
  @spec connect?(value :: integer()) :: boolean()
  def connect?(value) do
    has_perm(value, 0x00100000)
  end

  @doc """
  Check whether the value has the `admin` permission.
  """
  @spec admin?(value :: integer()) :: boolean()
  def admin?(value) do
    has_perm(value, 0x00000008)
  end

  @doc """
  Check whether the value has the `view_channel` permission.
  """
  @spec view_channel?(value :: integer()) :: boolean()
  def view_channel?(value) do
    has_perm(value, 0x00000400)
  end

  @doc """
  Check whether the value has the `view_channel` permission.
  """
  @spec view_channel?(value :: integer()) :: boolean()
  def speak?(value) do
    has_perm(value, 0x00200000)
  end
end
