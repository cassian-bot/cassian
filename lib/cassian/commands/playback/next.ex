defmodule Cassian.Commands.Playback.Next do
  use Cassian.Behaviours.Command

  alias Cassian.Managers.PlayManager
  
  alias Nostrum.Struct.Embed
  
  def application_command_definition() do
    %{
      name: "next",
      description: "Play the next song."
    }
  end

  @doc """
  Play the next song in the playlist.
  """

  def execute(interaction) do
    PlayManager.switch_song_with_notification(interaction, true)
    
    {embed, flags} =
      {
        EmbedUtils.create_empty_embed!()
        |> Embed.put_title("Changing to next song.")
        |> Embed.put_description("It'll start playing soon."),
        1 <<< 6
      }
      
      %{type: 4, data: %{embeds: [embed], flags: flags}}
  end
end
