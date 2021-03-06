defmodule Spoticord.Command do
  defmacro __using__(_) do
    quote do
      @prefix Application.get_env(:spoticord, :prefix)

      def handle_command(message, args), do: on_command(message, args)

      @callback on_command(message :: Nostrum.Struct.Message.t(), args :: List.t()) :: :ok
    end
  end
end