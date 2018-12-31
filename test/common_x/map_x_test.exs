defmodule MapXTest do
  use ExUnit.Case, async: true
  import MapX

  doctest MapX

  describe "merge/1" do
    test "merges with function" do
      assert merge(%{a: 5}, %{a: 5, b: 5}, fn _, x, y -> {:ok, x * y} end) ==
               {:ok, %{a: 25, b: 5}}
    end

    test "error out" do
      error = {:error, :mocked_to_fail}
      assert merge(%{a: 5}, %{a: 5, b: 5}, fn _, _, _ -> error end) == error
      assert merge(%{a: 5, b: 5}, %{a: 5}, fn _, _, _ -> error end) == error
    end
  end

  describe "get/3" do
    test "atom" do
      assert get(%{a: 5, b: 6}, :a) == 5
      assert get(%{a: 5, b: 6}, :a, 7) == 5
    end

    test "string" do
      assert get(%{"a" => 5, "b" => 6}, :a) == 5
      assert get(%{"a" => 5, "b" => 6}, :a, 7) == 5
    end

    test "missing key goes default" do
      assert get(%{a: 5, b: 6}, :c) == nil
      assert get(%{a: 5, b: 6}, :c, 7) == 7
      assert get(%{"a" => 5, "b" => 6}, :c) == nil
      assert get(%{"a" => 5, "b" => 6}, :c, 7) == 7
    end
  end

  describe "delete/2" do
    test "atom" do
      assert delete(%{a: 5, b: 6}, :a) == %{b: 6}
      assert delete(%{a: 5, b: 6}, :c) == %{a: 5, b: 6}
    end

    test "string" do
      assert delete(%{"a" => 5, "b" => 6}, :a) == %{"b" => 6}
      assert delete(%{"a" => 5, "b" => 6}, :c) == %{"a" => 5, "b" => 6}
    end
  end

  describe "stringify/1" do
    test "merge" do
      assert stringify(%{a: [%{a: 6}]}) == %{"a" => [%{"a" => 6}]}
    end
  end
end
