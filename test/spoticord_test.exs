defmodule SpoticordTest do
  use ExUnit.Case
  doctest Spoticord

  test "greets the world" do
    assert Spoticord.hello() == :world
  end
end
