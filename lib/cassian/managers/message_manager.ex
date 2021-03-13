defmodule Cassian.Managers.MessageManager do
  @timeout 1_500

  alias Nostrum.Struct.Embed
  alias Nostrum.Struct.Message
  alias Cassian.Utils.Embed, as: EmbedUtils

  require Logger

  @moduledoc """
  Manager for messages and disapperaring messages.
  """

  @doc """
  Disable embed for a link. It's still a WIP.
  """
  @spec disable_embed(message :: %Message{}) :: :ok | :noop
  def disable_embed(message) do
    case Nostrum.Api.edit_message(message, embed: nil) do
      {:ok, _message} ->
        :ok

      {:error, error} ->
        Logger.warn(error |> Poison.encode!())
        :nnop
    end
  end

  @doc """
  Safely send a message embed to a channel.
  """
  @spec send_embed(embed :: %Embed{}, channel_id :: Snowflake.t()) ::
          {:ok, %Message{}} | {:error, any()}
  def send_embed(embed, channel_id) do
    Nostrum.Api.create_message(channel_id, embed: embed)
  end

  @doc """
  Safely send a disapearring message. Starts a non-blocking delayed task
  to dissaper the mssage.
  """
  @spec send_dissapearing_embed(embed :: %Embed{}, channel_id :: Snowflake.t()) :: :ok | :noop
  def send_dissapearing_embed(embed, channel_id) do
    case Nostrum.Api.create_message(channel_id, embed: embed) do
      {:ok, message} ->
        spawn(fn -> dissapear(message) end)
        :ok

      _ ->
        :noop
    end
  end

  # Delete a message after `@timeout`.
  defp dissapear(message) do
    :timer.sleep(@timeout)
    Nostrum.Api.delete_message(message)
  end
end
