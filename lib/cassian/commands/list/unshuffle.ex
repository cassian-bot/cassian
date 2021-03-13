defmodule Cassian.Commands.List.Unshuffle do
  use Cassian.Behaviours.Command

  alias Cassian.Managers.PlayManager

  def ship?, do: true
  def caller, do: "list:unshuffle"
  def desc, do: "Play the playlst in forward order!"
  def example, do: "list:unshuffle"

  def execute(message, _args) do
    PlayManager.unshuffle_and_notify(message)
  end
end
