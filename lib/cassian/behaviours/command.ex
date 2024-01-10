defmodule Cassian.Behaviours.Command do
  @moduledoc """
  The general comand behaviour. Don't use `@behaviour` but rather `use` this module
  in other commands. It will implement the behaviour by itself.
  """

  @doc """
  The function which is called that does all of the stuff needed in the command.
  """
  @callback execute(interaction :: Nostrum.Struct.Interaction.t()) :: :ok
  
  @doc """
  The definition as a Discord application command.
  """
  @callback application_command_definition() :: %{}

  defmacro __using__(_) do
    quote do
      @behaviour Cassian.Behaviours.Command
      import Bitwise
      alias Cassian.Utils.Embed, as: EmbedUtils
    end
  end
end
