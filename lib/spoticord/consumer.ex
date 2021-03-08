defmodule Artificer.Consumer do

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
    if (!message.author.bot and is_artificer_command? message), do:
      Artificer.Consumers.Command.handle_message(message)
  end

  @dialyzer {:no_return, {:update_status, 3}}

  @doc false
  def handle_event({:READY, _, _}) do
    Nostrum.Api.update_status("Spotify", "spotify music", 1)
  end

  @doc false
  def handle_event(_event) do
    :noop
  end

  @doc """
  Checks whether the command is for this bot. Returns a boolean.
  """
  @spec is_artificer_command?(message :: Nostrum.Struct.Message) :: boolean()
  def is_artificer_command?(message) do
    message.content
    |> String.trim_leading()
    |> String.downcase
    |> String.starts_with?(Artificer.command_prefix!)
  end
end
