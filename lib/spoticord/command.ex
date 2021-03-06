defmodule Spoticord.Command do
  defmacro __using__(_) do
    quote do
      def handle_command(message, args), do: on_command(message, args)
      @callback on_command(message :: Nostrum.Struct.Message.t(), args :: List.t()) :: :ok
    end
  end

  def handle_message(message) do
    {command, args} =
      message.content
      |> String.trim_leading()
      |> String.downcase
      |> String.split(" ")
      |> List.pop_at(0)
      |> filter_command(Spoticord.command_prefix!)

    commands = get_command_names()

    if Map.has_key?(commands, command), do:
      Map.fetch!(commands, command).on_command(message, args)
  end

  defp filter_command({command, args}, prefix) do
    {String.replace_leading(command, prefix, ""), args} 
  end

  # Everything regarding command names

  def get_command_names() do
    {:ok, modules} = :application.get_key(:spoticord, :modules)
    modules
    |> Enum.map(fn module -> {to_string(module), module} end)
    |> Enum.filter(fn {name, _module} -> String.contains?(name, "Commands") end)
    |> Enum.reduce(%{}, &module_to_map/2)
  end

  defp name_to_command(name), do: name |> String.split(".") |> List.last |> String.downcase

  def module_to_map({name, module}, acc) do
    acc
    |> Map.put(name_to_command(name), module)
  end
end
