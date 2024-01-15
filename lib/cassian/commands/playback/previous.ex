defmodule Cassian.Commands.Playback.Previous do
  use Cassian.Behaviours.Command
  
  alias Cassian.Managers.PlayManager
  alias Nostrum.Struct.Embed\
  
  def application_command_definition() do
    %{
      name: "previous",
      description: "Play the previous song."
    }
  end

  @doc """
  Play the previous song.
  """

  def execute(interaction) do
    PlayManager.switch_song_with_notification(interaction, false)
    
    {embed, flags} =
      {
        EmbedUtils.create_empty_embed!()
        |> Embed.put_title("Changing to previous song.")
        |> Embed.put_description("It'll start playing soon."),
        1 <<< 6
      }
      
      %{type: 4, data: %{embeds: [embed], flags: flags}}
  end
end
