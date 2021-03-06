defmodule Spoticord do
  def command_prefix!(_server_id) do
    Application.get_env(:spoticord, :prefix)
  end
end
