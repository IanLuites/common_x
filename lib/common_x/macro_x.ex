defmodule MacroX do
  @moduledoc ~S"""
  `Macro` extension module.
  """

  @doc ~S"""
  Converts the given atom or binary to snakize format.
  If an atom is given, it is assumed to be an Elixir module,
  so it is converted to a binary and then processed.
  This function was designed to snakize language identifiers/tokens,
  that's why it belongs to the `Macro` module. Do not use it as a general
  mechanism for underscoring strings as it does not support Unicode or
  characters that are not valid in Elixir identifiers.
  ## Examples

  ```elixir
  iex> MacroX.snakize("FooBar")
  "foo_bar"
  iex> MacroX.snakize("Foo.Bar")
  "foo/bar"
  iex> MacroX.snakize(Foo.Bar)
  "foo/bar"
  iex> MacroX.snakize(:FooBar)
  :foo_bar
  ```

  In general, `snakize` can be thought of as the reverse of
  `pascalize`, however, in some cases formatting may be lost:

  ```elixir
  iex> MacroX.snakize("SAPExample")
  "sap_example"
  iex> MacroX.pascalize("sap_example")
  "SapExample"
  iex> MacroX.pascalize("hello_10")
  "Hello10"
  ```
  """
  @spec snakize(String.t() | atom) :: String.t() | atom
  def snakize(atom) when is_atom(atom) do
    case Atom.to_string(atom) do
      "Elixir." <> rest -> snakize(rest)
      atomize -> atomize |> snakize() |> String.to_atom()
    end
  end

  def snakize(<<h, t::binary>>), do: <<to_lower_char(h)>> <> do_snakize(t, h)
  def snakize(""), do: ""

  defp do_snakize(<<h, t, rest::binary>>, _)
       when h >= ?A and h <= ?Z and not (t >= ?A and t <= ?Z) and t != ?. and t != ?_ do
    <<?_, to_lower_char(h), t>> <> do_snakize(rest, t)
  end

  defp do_snakize(<<h, t::binary>>, prev)
       when h >= ?A and h <= ?Z and not (prev >= ?A and prev <= ?Z) and prev != ?_ do
    <<?_, to_lower_char(h)>> <> do_snakize(t, h)
  end

  defp do_snakize(<<?., t::binary>>, _), do: <<?/>> <> snakize(t)
  defp do_snakize(<<h, t::binary>>, _), do: <<to_lower_char(h)>> <> do_snakize(t, h)
  defp do_snakize(<<>>, _), do: <<>>

  @doc ~S"""
  Alias for `snakize/1`.

  ## Example
  ```elixir
  iex> MacroX.underscore("PascalCase")
  "pascal_case"
  ```
  """
  @spec underscore(String.t() | atom) :: String.t() | atom
  def underscore(data), do: snakize(data)

  @doc ~S"""
  Converts the given string to PascalCase format.
  This function was designed to pascalize language identifiers/tokens,
  that's why it belongs to the `MacroX` module. Do not use it as a general
  mechanism for pascalizing strings as it does not support Unicode or
  characters that are not valid in Elixir identifiers.
  ## Examples

  ```elixir
  iex> MacroX.pascalize("foo_bar")
  "FooBar"
  iex> MacroX.pascalize(:foo_bar)
  FooBar
  ```

  If uppercase characters are present, they are not modified in any way
  as a mechanism to preserve acronyms:

  ```
  iex> MacroX.pascalize("API.V1")
  "API.V1"
  iex> MacroX.pascalize("API_SPEC")
  "API_SPEC"
  ```
  """
  @spec pascalize(String.t() | atom) :: String.t() | atom
  def pascalize(data) when is_atom(data),
    do: String.to_atom("Elixir." <> pascalize(to_string(data)))

  def pascalize(data), do: Macro.camelize(data)

  @doc ~S"""
  Properly converts atoms and strings to camelCase.
  Unlike `MacroX.camelize/1`, which converts only strings to PascalCase.

  ## Examples

  ```elixir
  iex> MacroX.camelize(:my_atom)
  :myAtom

  iex> MacroX.camelize("my_string")
  "myString"

  iex> MacroX.camelize("my_ip_address")
  "myIPAddress"
  ```
  """
  @spec camelize(atom | String.t()) :: atom | String.t()
  def camelize(h) when is_atom(h), do: String.to_atom(camelize(to_string(h)))
  def camelize(data), do: pre_camelize(Regex.replace(~r/(^|_)ip(_|$)/, data, "\\1IP\\2"))

  defp pre_camelize(<<h, t::binary>>), do: <<h>> <> do_camelize(t)

  defp do_camelize(<<?_, ?_, t::binary>>), do: do_camelize(<<?_, t::binary>>)

  defp do_camelize(<<?_, h, t::binary>>) when h >= ?a and h <= ?z,
    do: <<to_upper_char(h)>> <> do_camelize(t)

  defp do_camelize(<<?_>>), do: <<>>
  defp do_camelize(<<?_, t::binary>>), do: do_camelize(t)
  defp do_camelize(<<h, t::binary>>), do: <<h>> <> do_camelize(t)
  defp do_camelize(<<>>), do: <<>>

  defp to_upper_char(char) when char >= ?a and char <= ?z, do: char - 32
  # defp to_upper_char(char), do: char

  defp to_lower_char(char) when char >= ?A and char <= ?Z, do: char + 32
  defp to_lower_char(char), do: char
end
