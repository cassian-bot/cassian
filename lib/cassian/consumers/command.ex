defmodule Cassian.Consumers.Command do
  @moduledoc """
  Main consumer for the command event of the bot. Redirects it to other commands.
  """
  
  alias Nostrum.Api

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
