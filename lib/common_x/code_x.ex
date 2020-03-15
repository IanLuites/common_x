defmodule CodeX do
  @moduledoc ~S"""
  Code module extended functions.
  """
  import :code, only: [ensure_loaded: 1]
  import Code, only: [ensure_compiled: 1]

  @doc ~S"""
  Ensures the given module is compiled.

  Similar to `Code.ensure_compiled/1`, but returns `true` if the module
  is already loaded or was successfully compiled. Returns `false`
  otherwise.

  ## Examples

  ```elixir
  iex> CodeX.ensure_compiled?(Atom)
  true
  ```
  """
  @spec ensure_compiled?(module) :: boolean
  def ensure_compiled?(module), do: match?({:module, ^module}, ensure_compiled(module))

  @doc ~S"""
  Ensures the given module is loaded.

  Similar to `Code.ensure_loaded/1`, but returns `true` if the module
  is already loaded or was successfully loaded. Returns `false`
  otherwise.

  ## Examples

  ```elixir
  iex> CodeX.ensure_loaded?(Atom)
  true
  ```
  """
  @spec ensure_loaded?(module) :: boolean
  def ensure_loaded?(module), do: match?({:module, ^module}, ensure_loaded(module))
end
