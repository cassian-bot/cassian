defmodule ArtificerTest do
  use ExUnit.Case
  doctest Artificer

  test "greets the world" do
    assert Artificer.hello() == :world
  end
end
