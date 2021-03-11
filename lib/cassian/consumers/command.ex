defmodule Cassian.Consumers.Command do
  @moduledoc """
  Main consumer for the command event of the bot. Redirects it to other commands.
  """

  import Cassian.Managers.CommandManager

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
      {:ok, module} ->
        module.execute(message, args)
        :ok

      _ ->
        :noop
    end
  end

  # Filter the prefix from the command in the tuple.
  @spec filter_command({command :: String.t(), args :: list(String.t())}) ::
          {command :: String.t(), args :: list(String.t())}
  defp filter_command({command, args}),
    do:
      {String.replace_leading(command, Cassian.command_prefix!(), "") |> String.downcase(), args}
end
