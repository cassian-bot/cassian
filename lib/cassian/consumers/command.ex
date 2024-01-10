defmodule Cassian.Consumers.Command do
  @moduledoc """
  Main consumer for the command event of the bot. Redirects it to other commands.
  """
  
  alias Nostrum.Api
  
  alias Cassian.Commands.{Bot, Playback}

  @doc """
  Handle the user interaction.
  """
  @spec handle_interaction(interaction :: Nostrum.Struct.Interaction) :: :ok | :noop
  def handle_interaction(interaction) do
    case associated_module(interaction.data.name) do
      nil ->
        :noop

      module ->
        interaction
        |> module.execute()
        |> (&Api.create_interaction_response(interaction, &1)).()
        :ok
    end
  end
  
  @doc """
  Generate the Discord interaction commands for each guild.
  """
  @spec generate_commands(Nostrum.Struct.Guild.UnavailableGuild.t()) :: :ok
  def generate_commands(%Nostrum.Struct.Guild.UnavailableGuild{id: guild_id}) do
    Nostrum.Api.create_guild_application_command(guild_id, Bot.Help.application_command_definition())
    Nostrum.Api.create_guild_application_command(guild_id, Playback.Backward.application_command_definition())
    Nostrum.Api.create_guild_application_command(guild_id, Playback.Forward.application_command_definition())
    Nostrum.Api.create_guild_application_command(guild_id, Playback.Play.application_command_definition()) |> IO.inspect()
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
