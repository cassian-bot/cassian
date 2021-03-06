defmodule Spoticord.Consumer do
  use Nostrum.Consumer

  def start_link do
    Consumer.start_link(__MODULE__)
  end

  def handle_event({:MESSAGE_CREATE, message, _ws_state}) do
    if (!message.author.bot and is_spoticord_command? message), do:
      Spoticord.Command.handle_message(message)
  end

  def handle_event({:READY, _, _}) do
    Nostrum.Api.update_status("Spotify", "spotify music", 1)
  end

  def handle_event(_event) do
    :noop
  end

  def is_spoticord_command?(message) do
    message.content
    |> String.trim_leading()
    |> String.downcase
    |> String.starts_with?(Spoticord.command_prefix!)
  end
end