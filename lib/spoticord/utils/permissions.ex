defmodule Spoticord.Utils.Permissions do
  alias Nostrum.Cache.{GuildCache, ChannelCache}
  use Bitwise

  def channel_permissions(user, guild_id, channel_id) do
    user_id = user.id
    roles = GuildCache.get!(guild_id).members[user_id].roles

    overs =
      ChannelCache.get!(channel_id)
      |> Map.get(:permission_overwrites)
      |> Enum.filter(&connected?(&1, roles, user_id))
      |> Enum.reduce(%{allows: [], denies: []}, &accumulate_overs/2)

    perms =
      Enum.reduce(overs.denies, base_permissions(guild_id), fn deny, perms -> perms &&& (~~~deny) end)

    Enum.reduce(overs.allows, perms, fn allow, perms -> perms ||| allow end)
  end

  def accumulate_overs(over, acc) do
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

  def base_permissions(guild_id, name \\ "@everyone") do
    GuildCache.get!(guild_id).roles
    |> Enum.reduce([], fn {_, role}, acc -> acc ++ [role] end)
    |> Enum.filter(fn role -> role.name == name end)
    |> List.first()
    |> Map.get(:permissions)
  end

  def has_perm(value, perm) do
    (value &&& perm) == perm
  end

  def connect?(value) do
    has_perm(value, 0x00100000)
  end

  def admin?(value) do
    has_perm(value, 0x00000008)
  end

  def view_channel?(value) do
    has_perm(value, 0x00000400)
  end

  def speak?(value) do
    has_perm(value, 0x00200000)
  end
end
