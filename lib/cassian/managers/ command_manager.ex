defmodule Cassian.Managers.CommandManager do
  @moduledoc """
  Module for managing and caching commands.
  """

  @doc """
  Get the associated module for the command name. Has a safe tuple based return.
  """
  @spec associated_module(name :: String.t()) :: {:ok, Module} | {:error, :noop}
  def associated_module(name) do
    if(ConCache.get(:command_cache, :loaded_bot_commands) != nil) do
      module = ConCache.get(:command_cache, name)
      {if(module, do: :ok, else: :error), module || :noop}
    else
      load_modules_cache()
      associated_module(name)
    end
  end

  # Get all of the modules which implement Cassian.Command behaviour and store them in a ETS cache.
  defp load_modules_cache() do
    {_, modules} = :application.get_key(:cassian, :modules)

    name_modules_map =
      modules
      |> Enum.filter(fn module ->
        Cassian.Behaviours.Command in (module.module_info(:attributes)[:behaviour] || [])
      end)
      |> Enum.filter(fn module -> if Mix.env() == :prod, do: module.ship?, else: true end)
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
