defmodule EnumX do
  @moduledoc ~S"""
  Some enumeration extensions.
  """

  @doc ~S"""
  Reduces the enumerable until `fun` returns `{:error, reason}`.

  The return value for `fun` is expected to be
    * `{:ok, acc}` to continue the reduction with `acc` as the new
      accumulator or
    * `{:error, acc}` to halt the reduction and return `acc` as the return
      value of this function

  ## Examples

  ```elixir
  iex> EnumX.reduce_while(1..100, 0, fn x, acc ->
  ...>   if x < 3, do: {:ok, acc + x}, else: {:error, acc}
  ...> end)
  {:error, 3}
  ```
  """
  @spec reduce_while(
          Enum.t(),
          any(),
          (Enum.element(), any() -> {:ok, any()} | {:error, any()})
        ) :: {:ok, any} | {:error, any}
  def reduce_while(enumerable, acc, fun) do
    enumerable
    |> Enumerable.reduce(
      {:cont, {:ok, acc}},
      fn e, {:ok, acc} ->
        case fun.(e, acc) do
          acc = {:ok, _} -> {:cont, acc}
          err = {:error, _} -> {:halt, err}
        end
      end
    )
    |> elem(1)
  end

  @doc ~S"""
  Returns a list where each item is the result of invoking
  `fun` on each corresponding item of `enumerable`.
  For maps, the function expects a key-value tuple.

  ## Examples
  ```elixir
  iex> EnumX.map([1, 2, 3], fn x -> {:ok, x * 2} end)
  {:ok, [2, 4, 6]}
  iex> EnumX.map([a: 1, b: 2], fn {k, v} -> {:ok, {k, -v}} end)
  {:ok, [a: -1, b: -2]}
  ```
  """
  @spec map(Enum.t(), (Enum.element() -> {:ok, any()} | {:error, any})) ::
          {:ok, list()} | {:error, any}
  def map(enumerable, fun) do
    with {:ok, enum} <-
           reduce_while(enumerable, [], fn elem, acc ->
             with({:ok, n} <- fun.(elem), do: {:ok, [n | acc]})
           end) do
      {:ok, :lists.reverse(enum)}
    end
  end
end
