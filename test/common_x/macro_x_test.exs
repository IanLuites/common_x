defmodule MacroXTest do
  use ExUnit.Case, async: true
  doctest MacroX

  describe "camelize/1" do
    test "remove extra underscores", do: assert(MacroX.camelize("hello__world_") == "helloWorld")
    test "handles numbers", do: assert(MacroX.camelize("world_10") == "world10")
  end

  describe "snakize/1" do
    test "doesn't add extra underscores",
      do: assert(MacroX.snakize("Hello_WorldK") == "hello__world_k")

    test "handles numbers",
      do: assert(MacroX.snakize("10Hello") == "10_hello")
  end
end
