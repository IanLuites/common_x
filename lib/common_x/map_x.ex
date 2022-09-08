defmodule MapX do
  @moduledoc ~S"""
  Some map extensions.
  """
  import Map, only: [put: 3]
  @compile {:inline, get: 2, get: 3, delete: 2, fetch: 2}

  @doc ~S"""
  Merges two maps into one, resolving conflicts through the given `fun`.
  All keys in `map2` will be added to `map1`. The given function will be invoked
  when there are duplicate keys; its arguments are `key` (the duplicate key),
  `value1` (the value of `key` in `map1`), and `value2` (the value of `key` in
  `map2`). The value returned by `fun` is used as the value under `key` in
  the resulting map.

  ## Examples

  ```elixir
  iex> MapX.merge(%{a: 1, b: 2}, %{a: 3, d: 4}, fn _k, v1, v2 ->
  ...>   {:ok, v1 + v2}
  ...> end)
  {:ok, %{a: 4, b: 2, d: 4}}
  ```
  """
  @spec merge(
          map,
          map,
          (Map.key(), Map.value(), Map.value() -> {:ok, Map.value()} | {:error, any})
        ) :: {:ok, map} | {:error, any}
  def merge(map1, map2, fun) when is_function(fun, 3) do
    if map_size(map1) > map_size(map2) do
      EnumX.reduce_while(map2, map1, fn {key, val2}, acc ->
        case acc do
          %{^key => val1} -> with {:ok, v} <- fun.(key, val1, val2), do: {:ok, put(acc, key, v)}
          %{} -> {:ok, put(acc, key, val2)}
        end
      end)
    else
      EnumX.reduce_while(map1, map2, fn {key, val1}, acc ->
        case acc do
          %{^key => val2} -> with {:ok, v} <- fun.(key, val1, val2), do: {:ok, put(acc, key, v)}
          %{} -> {:ok, put(acc, key, val1)}
        end
      end)
    end
  end

  @doc ~S"""
  Deletes the entry in `map` for a specific `key`.

  If the `key` does not exist, returns `map` unchanged.

  Inlined by the compiler.

  ## Examples

  ```elixir
  iex> MapX.delete(%{a: 1, b: 2}, :a)
  %{b: 2}

  iex> MapX.delete(%{"a" => 1, "b" => 2}, :a)
  %{"b" => 2}

  iex> MapX.delete(%{b: 2}, :a)
  %{b: 2}
  ```
  """
  @spec delete(map, atom) :: map
  def delete(map, key), do: map |> Map.delete(key) |> Map.delete(to_string(key))

  @doc ~S"""
  Gets the value for a specific `key` in `map`.

  If `key` is present in `map` with value `value`, then `value` is
  returned. Otherwise, `default` is returned (which is `nil` unless
  specified otherwise).

  ## Examples

  ```elixir
  iex> MapX.get(%{}, :a)
  nil

  iex> MapX.get(%{a: 1}, :a)
  1

  iex> MapX.get(%{"a" => 1}, :a)
  1

  iex> MapX.get(%{a: 1}, :b)
  nil

  iex> MapX.get(%{a: 1}, :b, 3)
  3
  ```
  """
  @spec get(map, atom, Map.value()) :: Map.value()
  def get(map, key, default \\ nil) do
    Map.get_lazy(map, key, fn -> Map.get(map, to_string(key), default) end)
  end

  @doc ~S"""
  Fetches the value for a specific `key` in the given `map`.
  If `map` contains the given `key` with value `value`, then `{:ok, value}` is
  returned. If `map` doesn't contain `key`, `:error` is returned.
  Inlined by the compiler.

  ## Examples
  ```elixir
  iex> MapX.fetch(%{a: 1}, :a)
  {:ok, 1}
  iex> MapX.fetch(%{"a" => 1}, :a)
  {:ok, 1}
  iex> MapX.fetch(%{a: 1}, :b)
  :error
  ```
  """
  @spec fetch(map, atom) :: {:ok, Map.value()} | :error
  def fetch(map, key) do
    case :maps.find(key, map) do
      :error -> :maps.find(to_string(key), map)
      ok -> ok
    end
  end

  @doc ~S"""
  Creates a map from an `enumerable` via the given transformation function.
  Duplicated keys are removed; the latest one prevails.

  Returning `:skip` will skip to the next value.

  ## Examples

  ```elixir
  iex> MapX.new([:a, :b], fn x -> {:ok, x, x} end)
  {:ok, %{a: :a, b: :b}}
  ```

  ```elixir
  iex> MapX.new(1..5, &if(rem(&1, 2) == 0, do: :skip, else: {:ok, &1, &1}))
  {:ok, %{1 => 1, 3 => 3, 5 => 5}}
  ```
  """
  @spec new(Enumerable.t(), (term -> {:ok, Map.key(), Map.value()} | {:error, term}), module) ::
          {:ok, map} | {:error, term}
  def new(enumerable, transform, struct \\ nil) when is_function(transform, 1) do
    enumerable
    |> Enum.to_list()
    |> new_transform(transform, if(is_nil(struct), do: [], else: [__struct__: struct]))
  end

  defp new_transform([], _fun, acc) do
    {:ok,
     acc
     |> :lists.reverse()
     |> :maps.from_list()}
  end

  defp new_transform([item | rest], fun, acc) do
    case fun.(item) do
      :skip -> new_transform(rest, fun, acc)
      {:ok, key, value} -> new_transform(rest, fun, [{key, value} | acc])
      error -> error
    end
  end

  @doc ~S"""
  Updates the `key` in `map` with the given function.

  If `key` is present in `map` with value `value`, `fun` is invoked with
  argument `value` and its result is used as the new value of `key`.
  If `key` is not present in `map`, then the original `map` is returned.

  ## Examples

  ```elixir
  iex> MapX.update_if_exists(%{a: 1}, :a, &(&1 * 2))
  %{a: 2}
  iex> MapX.update_if_exists(%{a: 1}, :b, &(&1 * 2))
  %{a: 1}
  iex> MapX.update_if_exists([a: 5], :a, &(&1 * 2))
  ** (BadMapError) expected a map, got: [a: 5]
  ```
  """
  @spec update_if_exists(map, Map.key(), (Map.value() -> Map.value())) :: map
  def update_if_exists(map, key, fun) when is_function(fun, 1) do
    case map do
      %{^key => value} -> put(map, key, fun.(value))
      %{} -> map
      other -> :erlang.error({:badmap, other}, [map, key, fun])
    end
  end

  @doc ~S"""
  Transform the keys of a given map to atoms.

  ## Examples
  ```elixir
  iex> MapX.atomize(%{a: 5})
  %{a: 5}
  iex> MapX.atomize(%{"a" => 5})
  %{a: 5}
  ```
  """
  @spec atomize(%{optional(String.t()) => any}) :: %{optional(atom) => any}
  def atomize(map), do: transform_keys(map, &if(is_atom(&1), do: &1, else: String.to_atom(&1)))

  @doc ~S"""
  Transform the keys of a given map to atoms.

  ## Examples
  ```elixir
  iex> MapX.atomize!(%{a: 5})
  %{a: 5}
  iex> MapX.atomize!(%{"a" => 5})
  %{a: 5}
  iex> MapX.atomize!(%{"non existing" => 5})
  ** (ArgumentError) argument error
  ```
  """
  @spec atomize!(%{optional(String.t()) => any}) :: %{optional(atom) => any}
  def atomize!(map),
    do: transform_keys(map, &if(is_atom(&1), do: &1, else: String.to_existing_atom(&1)))

  @doc ~S"""
  Transform the keys of a given map to atoms.

  ## Examples
  ```elixir
  iex> MapX.stringify(%{a: 5})
  %{"a" => 5}
  iex> MapX.stringify(%{"a" => 5})
  %{"a" => 5}
  ```
  """
  @spec stringify(%{optional(atom) => any}) :: %{optional(String.t()) => any}
  def stringify(map), do: transform_keys(map, &if(is_binary(&1), do: &1, else: to_string(&1)))

  @spec transform_keys(term, (Map.key() -> Map.key())) :: term
  defp transform_keys(map, transformer) when is_map(map),
    do: Map.new(map, fn {k, v} -> {transformer.(k), transform_keys(v, transformer)} end)

  defp transform_keys(list, transformer) when is_list(list),
    do: Enum.map(list, &transform_keys(&1, transformer))

  defp transform_keys(value, _transformer), do: value
end
