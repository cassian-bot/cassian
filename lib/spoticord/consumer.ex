defmodule Spoticord.Consumer do
  use Nostrum.Consumer

  def start_link do
    Consumer.start_link(__MODULE__)
  end

  def handle_event({:MESSAGE_CREATE, message, _ws_state}) do
    IO.inspect message.content
  end

  def handle_event({:READY, _, _}) do
    Nostrum.Api.update_status("Spotify", "spotify music", 1)
  end

  def handle_event(_event) do
    :noop
  end
end