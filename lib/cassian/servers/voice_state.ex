defmodule Cassian.Servers.VoiceState do
  @moduledoc """
  A GenServer representing the current voice state.
  """

  use GenServer

  @doc """
  Check is a VoiceState exists for a guild.
  """
  @spec exists?(guild_id :: Snowflake.t()) :: boolean()
  def exists?(guild_id) do
    !!Process.whereis(from_guild_id(guild_id))
  end

  @doc """
  Delete the queue.
  """
  @spec delete(guild_id :: Snowflake.t()) :: :ok
  def delete(guild_id) do
    if exists?(guild_id), do: GenServer.stop(from_guild_id(guild_id))
    :ok
  end

  # Private API

  @doc false
  def start(guild_id, links) do
    GenServer.start_link(__MODULE__, links, name: from_guild_id(guild_id))
  end

  @doc false
  def init(args) do
    {:ok, args}
  end

  @doc false
  defp from_guild_id(guild_id), do: "state_#{guild_id}" |> String.to_atom()
end
