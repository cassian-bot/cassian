defmodule Cassian.Commands.Playback.Forward do
  use Cassian.Behaviours.Command

  alias Cassian.Managers.PlayManager

  @doc """
  Play the playlist forward.
  """
  
  def application_command_definition() do
    %{
      name: "forward",
      description: "Play the playlist forward."
    }
  end

  def execute(interaction) do
    {embed, flags} = PlayManager.change_direction_with_notification(interaction, false)
    
    %{type: 4, data: %{embeds: [embed], flags: flags}}
  end
end
