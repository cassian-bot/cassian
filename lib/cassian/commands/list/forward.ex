defmodule Cassian.Commands.List.Forward do
  use Cassian.Behaviours.Command

  alias Cassian.Managers.PlayManager

  @doc """
  List command sub-module. Play the list forward.
  """

  def example do
    "list forward"
  end

  def short_desc do
    "Play the list forward."
  end

  def long_desc do
    "Play the list forward. This is the default setting for lists."
  end

  def execute(message, _args) do
    PlayManager.change_direction_with_notification(message, false)
  end
end
