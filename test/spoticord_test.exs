defmodule CassianTest do
  use ExUnit.Case
  doctest Cassian

  test "greets the world" do
    assert Cassian.hello() == :world
  end
end
