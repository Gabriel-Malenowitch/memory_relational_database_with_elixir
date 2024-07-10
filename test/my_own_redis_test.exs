defmodule MyOwnRedisTest do
  use ExUnit.Case
  doctest MyOwnRedis

  test "greets the world" do
    assert MyOwnRedis.hello() == :world
  end
end
