defmodule Cassian.Consumers.Command do
  @moduledoc """
  Main consumer for the command event of the bot. Redirects it to other commands.
  """

  @doc """
  Handle the mssage. A message has been filtered which is for the bot.
  Dynamically find which module should be used for the command and continue on with that.
  """
  @spec handle_message(message :: Nostrum.Struct.Message) :: :ok | :noop
  def handle_message(message) do
    {command, args} =
      message.content
      |> String.trim_leading()
      |> String.split(" ")
      |> List.pop_at(0)
      |> filter_command()

    case associated_module(command) do
      nil ->
        :noop

      module ->
        module.execute(message, args)
        :ok
    end
  end

    # Filter the prefix from the command in the tuple.
    @spec filter_command({command :: String.t(), args :: list(String.t())}) ::
      {command :: String.t(), args :: list(String.t())}
    defp filter_command({command, args}),
    do:
    {String.replace_leading(command, Cassian.command_prefix!(), "") |> String.downcase(), args}

  defp associated_module(command) do
    alias Cassian.Commands

    case command do
      "help" ->
        #Commands.Bot.Help
        nil

      "ping" ->
        Commands.Bot.Ping

      "backward" ->
        Commands.Music.Playlist.Backward

      "forward" ->
        Commands.Music.Playlist.Forward

      "next" ->
        Commands.Music.Playlist.Next

      "playlist" ->
        Commands.Music.Playlist.Playlist

      "repeat" ->
        Commands.Music.Playlist.Repeat

      "shuffle" ->
        Commands.Music.Playlist.Shuffle

      "unshuffle" ->
        Commands.Music.Playlist.Unshuffle

      "play" ->
        Commands.Music.Play

      "stop" ->
        Commands.Music.Stop

      _ ->
        nil
    end
  end
end
