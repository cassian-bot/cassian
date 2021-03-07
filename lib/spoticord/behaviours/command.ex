defmodule Spoticord.Behaviours.Command do
  @moduledoc """
  The general comand behaviour. Don't use `@behaviour` but rather `use` this module
  in other commands. It will implement the behaviour by itself.
  """

  @doc """
  Get the description of the command.
  """
  @callback desc() :: String.t()

  @doc """
  Get the caller for the command.
  """
  @callback caller() :: String.t()

  @doc """
  The function which is called that does all of the stuff needed in the command.
  """
  @callback execute(message :: Nostrum.Struct.Message.t(), args :: List.t()) :: :ok

  @doc """
  Should the command be shipped in production?
  """
  @callback ship? :: boolean()

  defmacro __using__(_) do
    quote do
      defmacro handle_command(message, args), do: execute(message, args)
      @behaviour Spoticord.Behaviours.Command
    end
  end
end
