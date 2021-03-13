defmodule Cassian.Behaviours.Command do
  @moduledoc """
  The general comand behaviour. Don't use `@behaviour` but rather `use` this module
  in other commands. It will implement the behaviour by itself.
  """

  @doc """
  The function which is called that does all of the stuff needed in the command.
  """
  @callback execute(message :: Nostrum.Struct.Message.t(), args :: List.t()) :: :ok

  @doc """
  Used to show a small example for the command.
  """
  @callback example :: String.t()

  @doc """
  Write a short description of the command.
  """
  @callback short_desc :: String.t()

  @doc """
  @rite a long description of the command.
  """
  @callback long_desc :: String.t()

  defmacro __using__(_) do
    quote do
      defmacro handle_command(message, args), do: execute(message, args)
      @behaviour Cassian.Behaviours.Command
    end
  end
end
