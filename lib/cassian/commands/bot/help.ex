defmodule Cassian.Commands.Bot.Help do
  use Cassian.Behaviours.Command

  @moduledoc """
  The help command. Shows a menu of commands.
  """
  
  def application_command_definition() do
    %{
      name: "help",
      description: "Get the list of all commands from Cassian"
    }
  end

  def execute(_interaction) do
    %{type: 4, data: %{embeds: [generate_help_embed!()], flags: 1 <<< 6}}
  end

  import Cassian.Utils.Embed
  alias Nostrum.Struct.Embed

  defp generate_help_embed!() do
    create_empty_embed!()
    |> Embed.put_title("Yo! Thanks for adding me to the server!")
    |> Embed.put_description(
      "I currently don't have a propper help command as I'm a WIP. Though once it has been created it will be linked here so " <>
        "you can see all of my commands. Although you can start playing music with `/play`."
    )
    |> Embed.put_thumbnail(Cassian.get_own_avatar())
  end
end
