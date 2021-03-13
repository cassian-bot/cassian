defmodule Cassian.Commands.List.Forward do
  use Cassian.Behaviours.Command

  alias Cassian.Managers.PlayManager

  @doc """
  List command sub-module. Play the list forward.
  """

  def example do
    "forward"
  end

  def short_desc do
    "Play the playlist forward."
  end

  def long_desc do
    "Play the playlist forward. This is the default setting for playlists."
  end

  def execute(message, _args) do
    PlayManager.change_direction_with_notification(message, false)
  end
end
