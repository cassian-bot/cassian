defmodule Spoticord.Consumers.Command do
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

    case associated_module(command) do
      {:ok, module} ->
        module.execute(message, args)
        :ok
      _ ->
        :noop
    end
  end

  # Filter the prefix from the command in the tuple.
  @spec filter_command({command :: String.t(), args :: list(String.t())}) :: {command :: String.t(), args :: list(String.t())}
  defp filter_command({command, args}), do: {String.replace_leading(command, Spoticord.command_prefix!, ""), args}

  @doc """
  Get the associated module for the command name. Has a safe tuple based return.
  """
  @spec associated_module(name :: String.t()) :: {:ok, Module} | {:error, :noop}
  def associated_module(name) do
    if(ConCache.get(:command_cache, :loaded_bot_commands) != nil) do
      module = ConCache.get(:command_cache, name)
      {(if module, do: :ok, else: :error), module || :noop }
    else
      load_modules_cache()
      associated_module(name)
    end
  end

  # Get all of the modules which implement Spoticord.Command behaviour and store them in a ETS cache.
  defp load_modules_cache() do
    {_, modules} = :application.get_key(:spoticord, :modules)

    name_modules_map =
      modules
      |> Enum.filter(fn module -> Spoticord.Behaviours.Command in (module.module_info(:attributes)[:behaviour] || []) end)
      |> Enum.filter(fn module -> if Mix.env == :prod, do: module.ship?, else: true end)
      |> Enum.reduce(%{}, fn module, acc -> Map.merge(acc, %{module.caller => module}) end)

    name_modules_map
    |> Enum.each(fn {caller, module} -> ConCache.put(:command_cache, caller, module) end)

    ConCache.put(:command_cache, :loaded_bot_commands, name_modules_map)
  end

  @doc """
  List all of the commands for the bot.
  """
  def commands! do
    ConCache.get(:command_cache, :loaded_bot_commands)
  end
end
