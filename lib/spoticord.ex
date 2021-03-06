defmodule Spoticord do
  @command_prefix Application.get_env(:spoticord, :prefix)

  def command_prefix!(_server_id \\ nil) do
    @command_prefix |> to_string
  end
end
