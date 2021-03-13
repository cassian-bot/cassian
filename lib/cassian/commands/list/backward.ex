defmodule Cassian.Commands.List.Backward do
  use Cassian.Behaviours.Command

  alias Cassian.Managers.PlayManager

  @doc """
  List command sub-module. Play the list backwards.
  """

  def example do
    "list backwards"
  end

  def short_desc do
    "Play the list backwards."
  end

  def long_desc do
    "Play the list backwards. Newly added songs will play first."
  end

  def execute(message, _args) do
    PlayManager.change_direction_with_notification(message, true)
  end
end
