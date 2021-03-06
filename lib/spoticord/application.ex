defmodule Spoticord.Application do
  use Application
  
  @token Application.get_env(:nostrum, :token)

  def start(_type, _args) do
    IO.puts "Spoticord bot is starting... with token #{@token}"

    # Using a dynamic supervisor here so I can add children
    # later as well!
    result = DynamicSupervisor.start_link(name: Spoticord.Supervisor, strategy: :one_for_one)
    add_children()
    result
  end

  def add_children() do
    alias Spoticord.Consumer

    children = [
      %{
        id: Consumer,
        start: {Consumer, :start_link, []}
      }
    ]

    children
    |> Enum.each(fn child -> DynamicSupervisor.start_child(Spoticord.Supervisor, child) end)
  end
end
