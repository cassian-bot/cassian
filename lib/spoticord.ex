defmodule Spoticord do

  @moduledoc """
  General module for the bot. Has all high-level API calls
  which might as well be used from external apps.
  """

  alias Nostrum.Cache.Me

  @default_command_prefix Application.get_env(:spoticord, :prefix)

  def get_own_avatar(), do: Spoticord.Utils.user_avatar(Me.get)

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
end
