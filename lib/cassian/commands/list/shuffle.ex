defmodule Cassian.Commands.List.Shuffle do
  use Cassian.Behaviours.Command

  alias Cassian.Managers.PlayManager

  def ship?, do: true
  def caller, do: "list:shuffle"
  def desc, do: "Play the playlst in forward order!"
  def example, do: "list:shuffle"

  def execute(message, _args) do
    PlayManager.shuffle_and_notify(message)
  end
end
