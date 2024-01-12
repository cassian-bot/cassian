defmodule Cassian do
  @moduledoc """
  General module for the bot. Has all high-level API calls
  which might as well be used from external apps.
  """

  alias Nostrum.Cache.Me

  @doc """
  Get the avatar of the bot itself.
  """
  @spec get_own_avatar() :: String.t()
  def get_own_avatar,
    do: Cassian.Utils.user_avatar(Me.get())

  @doc """
  Get the user name of bot account.
  """
  @spec username! :: String.t()
  def username! do
    Me.get().username
  end

  @doc """
  Get the username of the bot account.
  """
  @spec version! :: String.t()
  def version! do
    {:ok, vsn} = :application.get_key(:cassian, :vsn)
    List.to_string(vsn)
  end

  @spec own_id() :: Snowflake.t()
  def own_id, do: Me.get().id
end
