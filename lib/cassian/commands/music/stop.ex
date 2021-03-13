defmodule Cassian.Commands.Music.Stop do
  use Cassian.Behaviours.Command
  alias Cassian.Managers.PlayManager

  def caller, do: "stop"
  def desc, do: "Stop the musing playing."
  def ship?, do: true

  def execute(message, _args) do
    PlayManager.stop_and_notify(message)
  end
end
