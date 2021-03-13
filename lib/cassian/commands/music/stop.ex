defmodule Cassian.Commands.Music.Stop do
  use Cassian.Behaviours.Command
  alias Cassian.Managers.PlayManager

  def example, do: "stop"

  def long_desc do
    "Stop the playlist."
  end

  def short_desc do
    long_desc()
  end

  def execute(message, _args) do
    PlayManager.stop_and_notify(message)
  end
end
