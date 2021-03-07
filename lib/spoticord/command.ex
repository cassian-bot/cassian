defmodule Spoticord.Command do

  @moduledoc """
  The general comand module. It can be used by commands under the
  `Spoticord.Commands` modue path.
  """

  defmacro __using__(_) do
    quote do
      def handle_command(message, args), do: execute(message, args)

      @callback execute(message :: Nostrum.Struct.Message.t(), args :: List.t()) :: :ok
    end
  end

  @doc """
  Handle the mssage. A message has been filtered which is for the bot.

  Dynamically find which module should be used for the command and continue on with that.
  """
  @spec handle_message(message :: Nostrum.Struct.Message) :: :ok | :noop
  def handle_message(message) do
    {command, args} =
      message.content
      |> String.trim_leading()
      |> String.downcase
      |> String.split(" ")
      |> List.pop_at(0)
      |> filter_command()

    commands = get_command_names()

    if Map.has_key?(commands, command), do:
      Map.fetch!(commands, command).execute(message, args)

    :noop
  end

  # Filter the prefix from the command in the tuple.
  @spec filter_command({command :: String.t(), args :: list(String.t())}) :: {command :: String.t(), args :: list(String.t())}
  defp filter_command({command, args}) do
    {String.replace_leading(command, Spoticord.command_prefix!, ""), args}
  end

  # Everything regarding command names

  # Okay so this was a bit hacky. Basically the file structure is that every
  # module under `Spoticord.Commands` is a command itself and after the `Commands` part
  # is the real name of the commend. This will dynamically load the name of the modues and
  # generate a hash which contains the command callers and the module themselves.
  @spec get_command_names() :: %{String.t() => Module}
  defp get_command_names() do
    {:ok, modules} = :application.get_key(:spoticord, :modules)
    modules
    |> Enum.map(fn module -> {to_string(module), module} end)
    |> Enum.filter(fn {name, _module} -> String.contains?(name, "Commands") end)
    |> Enum.reduce(%{}, &module_to_map/2)
  end

  # Takes the module name and extracts the command from itself.
  # `FOO.BAR.PING` => `ping`
  @spec name_to_command(name :: String.t()) :: String.t()
  defp name_to_command(name), do: name |> String.split(".") |> List.last |> String.downcase

  @spec module_to_map({name :: String.t(), module :: Module}, acc :: Map) :: %{String.t() => Module}
  defp module_to_map({name, module}, acc) do
    acc
    |> Map.put(name_to_command(name), module)
  end
end
