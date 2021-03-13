defmodule Cassian.Commands.List.Forward do
  use Cassian.Behaviours.Command

  alias Cassian.Managers.PlayManager

  def ship?, do: true
  def caller, do: "list:forward"
  def desc, do: "Play the playlst in forward order!"
  def example, do: "list:forward"

  def execute(message, _args) do
    PlayManager.change_direction_with_notification(message, false)
  end
end
