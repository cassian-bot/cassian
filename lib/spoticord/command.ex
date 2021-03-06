defmodule Spoticord.Command do
  defmacro __using__(_) do
    quote do
      use Alchemy.Cogs
    end
  end
end