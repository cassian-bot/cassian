defmodule Spoticord.Commands.Ping do
  use Spoticord.Command

  def on_command(_message, _args) do
    :ok
  end
end