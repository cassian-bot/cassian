defmodule Cassian.Consumers.Command do
  @moduledoc """
  Main consumer for the command event of the bot. Redirects it to other commands.
  """
  
  require Logger
  alias Nostrum.Api
  
  alias Cassian.Commands.{Bot, Playback}

  @doc """
  Handle the user interaction.
  """
  @spec handle_interaction(interaction :: Nostrum.Struct.Interaction.t()) :: :ok | :noop
  def handle_interaction(interaction) do
    case associated_module(interaction.data.name) do
      nil ->
        :noop

      module ->
        api_response =
          interaction
          |> module.execute()
          |> (&send_response(interaction, &1)).()
          
        Logger.debug("API's response is: #{inspect(api_response)}.")
    end
  end
  
  # I know it looks ugly when called in the pipeline *but* it's consitent with
  # the library that itneraction should be first and then the response should be
  # something additional.
  defp send_response(interaction, response = %{edit: true}) do
    new_response = %{
      embeds: response.data.embeds,
      type: response.type,
      flags: response.data.flags
    }
    
    Logger.debug("Sending edit response: #{inspect(new_response)}")
    
    Api.edit_interaction_response(interaction, new_response)
  end
  
  defp send_response(interaction, response) do
    Logger.debug("Sending standard response: #{inspect(response)}")
    
    Api.create_interaction_response(interaction, response)
  end
  
  @doc """
  Generate the Discord interaction commands for each guild.
  """
  @spec generate_commands(Nostrum.Struct.Guild.UnavailableGuild.t()) :: no_return()
  def generate_commands(%Nostrum.Struct.Guild.UnavailableGuild{id: guild_id}) do
    Nostrum.Api.create_guild_application_command(guild_id, Bot.Help.application_command_definition())
    Nostrum.Api.create_guild_application_command(guild_id, Playback.Backward.application_command_definition())
    Nostrum.Api.create_guild_application_command(guild_id, Playback.Forward.application_command_definition())
    Nostrum.Api.create_guild_application_command(guild_id, Playback.Play.application_command_definition())
    Nostrum.Api.create_guild_application_command(guild_id, Playback.Previous.application_command_definition())
    Nostrum.Api.create_guild_application_command(guild_id, Playback.Next.application_command_definition())
    Nostrum.Api.create_guild_application_command(guild_id, Playback.Playlist.application_command_definition())
  end

  defp associated_module(command) do
    alias Cassian.Commands.{Bot, Playback}

    case command do
      "help" ->
        Bot.Help

      "backward" ->
        Playback.Backward

      "forward" ->
        Playback.Forward

      "next" ->
        Playback.Next

      "previous" ->
        Playback.Previous

      "playlist" ->
        Playback.Playlist

      "repeat" ->
        Playback.Repeat

      "shuffle" ->
        Playback.Shuffle

      "unshuffle" ->
        Playback.Unshuffle

      "play" ->
        Playback.Play

      "stop" ->
        Playback.Stop

      _ ->
        nil
    end
  end
end
