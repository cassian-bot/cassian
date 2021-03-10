defmodule Cassian do
  @moduledoc """
  General module for the bot. Has all high-level API calls
  which might as well be used from external apps.
  """

  alias Nostrum.Cache.Me

  @default_command_prefix Application.get_env(:cassian, :prefix)

  @doc """
  The a map containing all of the commands and their associated modules
  """
  @spec commands! :: %{String.t() => Module}
  def commands!, do: Cassian.Consumers.Command.commands!()

  @doc """
  Get the avatar of the bot itself.
  """
  @spec get_own_avatar() :: String.t()
  def get_own_avatar,
    do: Cassian.Utils.user_avatar(Me.get())

  @doc """
  Get the command prefix of the bot from a server. if no server
  is specific then the default prefix is taken.

  Currently this works only with the preset one as database has not yet
  been added.
  """
  @spec command_prefix!(server_id :: Nostrum.Struct.Guild.id() | nil) :: binary
  def command_prefix!(_server_id \\ nil) do
    @default_command_prefix
  end

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
