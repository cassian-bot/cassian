defmodule Cassian.Consumer do

  @moduledoc """
  The main consumer module. This handles all of the events
  from nostrum and redirects them to the modules which use them.
  """

  use Nostrum.Consumer

  def start_link do
    Consumer.start_link(__MODULE__)
  end

  @doc false
  def handle_event({:MESSAGE_CREATE, message, _ws_state}) do
    if (!message.author.bot and is_cassian_command? message), do:
      Cassian.Consumers.Command.handle_message(message)
  end

  @dialyzer {:no_return, {:update_status, 3}}

  @doc false
  def handle_event({:READY, _, _}) do
    Nostrum.Api.update_status("Spotify", "spotify music", 1)
  end

  @doc false
  def handle_event({:VOICE_SPEAKING_UPDATE, data, _}) do
    unless data.speaking, do:
      Cassian.Servers.Queue.delete_if_empty(data.guild_id)
  end

  @doc false
  def handle_event({:VOICE_STATE_UPDATE, data, _}) do
    if !data.channel_id and data.member.user_id == Cassian.own_id() do
      Cassian.Servers.Queue.delete(data.guild_id)
    end

    # TODO: Play next in queue.
  end

  @doc false
  def handle_event(_) do
    :noop
  end

  @doc """
  Checks whether the command is for this bot. Returns a boolean.
  """
  @spec is_cassian_command?(message :: Nostrum.Struct.Message) :: boolean()
  def is_cassian_command?(message) do
    message.content
    |> String.trim_leading()
    |> String.downcase
    |> String.starts_with?(Cassian.command_prefix!)
  end
end
