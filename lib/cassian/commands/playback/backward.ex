defmodule Cassian.Commands.Playback.Backward do
  use Cassian.Behaviours.Command

  alias Cassian.Managers.PlayManager

  @doc """
  Play the playlist backwards.
  """
  
  def application_command_definition() do
    %{
      name: "backward",
      description: "Play the playlist backwards."
    }
  end

  def execute(interaction) do
    {embed, flags} = PlayManager.change_direction_with_notification(interaction, true)
    
    %{type: 4, data: %{embeds: [embed], flags: flags}}
  end
end
