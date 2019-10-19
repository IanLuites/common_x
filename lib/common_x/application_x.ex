defmodule ApplicationX do
  @moduledoc ~S"""
  Application module extended functions.
  """
  alias Mix.Project
  import Mix.Task, only: [run: 2]
  @ignore [:kernel, :stdlib, :elixir, :logger]
  @load_error 'no such file or directory'

  @doc ~S"""
  List all available applications excluding system ones.

  This function is save to run in `Mix.Task`s.

  ## Example

  Since `:common_x` does not have any dependencies:
  ```elixir
  iex> ApplicationX.applications
  [:common_x]
  ```
  """
  @spec applications :: [atom]
  def applications do
    if main_app = Project.config()[:app] do
      with {:error, {@load_error, _}} <- :application.load(main_app), do: run("loadpaths", [])
      gather_applications([main_app])
    else
      :application.loaded_applications()
      |> Enum.map(&elem(&1, 0))
      |> Enum.reject(&(&1 in @ignore))
      |> gather_applications()
    end
  end

  @doc ~S"""
  List all dependant applications excluding system ones.
  Does includes the given application.

  This function is save to run in `Mix.Task`s.

  ## Example

  Since `:common_x` does not have any dependencies:
  ```elixir
  iex> ApplicationX.applications(:common_x)
  [:common_x]
  ```

  Duplicates are ignored and only returned once:
  ```elixir
  iex> ApplicationX.applications([:common_x, :common_x])
  [:common_x]
  ```

  Unknown applications are safe, but returned:
  ```elixir
  iex> ApplicationX.applications(:fake)
  [:fake]
  ```
  """
  @spec applications(atom | [atom]) :: [atom]
  def applications(app) when is_atom(app), do: gather_applications([app])
  def applications(apps), do: gather_applications(apps)

  @doc ~S"""
  List all available modules excluding system ones.

  This function is save to run in `Mix.Task`s.

  ## Example

  Since `:common_x` does not have any dependencies:
  ```elixir
  iex> ApplicationX.modules
  [ApplicationX, CommonX, EnumX, MacroX, MapX]
  ```
  """
  @spec modules :: [module]
  def modules do
    if main_app = Project.config()[:app] do
      with {:error, {@load_error, _}} <- :application.load(main_app), do: run("loadpaths", [])
      modules(main_app)
    else
      :application.loaded_applications()
      |> Enum.map(&elem(&1, 0))
      |> Enum.reject(&(&1 in @ignore))
      |> modules()
    end
  end

  @doc ~S"""
  List all available modules for the given app[s] and dependencies of those apps.
  This excludes system modules.

  This function is save to run in `Mix.Task`s.

  ## Example

  Normally system modules are excluded,
  but can be added by manually passing the respective system application:
  ```elixir
  iex> ApplicationX.modules(:logger)
  [Logger, Logger.App, Logger.BackendSupervisor, Logger.Backends.Console,
    Logger.Config, Logger.ErlangHandler, Logger.ErrorHandler, Logger.Formatter,
    Logger.Translator, Logger.Utils, Logger.Watcher]
  ```

  Duplicate applications are ignored:
  ```elixir
  iex> ApplicationX.modules([:logger, :logger])
  [Logger, Logger.App, Logger.BackendSupervisor, Logger.Backends.Console,
    Logger.Config, Logger.ErlangHandler, Logger.ErrorHandler, Logger.Formatter,
    Logger.Translator, Logger.Utils, Logger.Watcher]
  ```

  Unknown applications are safe to pass:
  ```elixir
  iex> ApplicationX.modules(:fake)
  []
  ```
  """
  @spec modules(atom | [atom]) :: [module]
  def modules(app) when is_atom(app), do: gather_modules([app])
  def modules(apps), do: gather_modules(apps)

  ### Helpers ###

  @spec gather_applications([atom], [atom]) :: [atom]
  defp gather_applications(apps, acc \\ [])
  defp gather_applications([], acc), do: acc

  defp gather_applications([app | t], acc) do
    if app in acc do
      gather_applications(t, acc)
    else
      :application.load(app)

      gather =
        case :application.get_all_key(app) do
          {:ok, data} -> t ++ ((data[:applications] || []) -- @ignore)
          _ -> t
        end

      gather_applications(gather, [app | acc])
    end
  end

  @spec gather_modules([atom], %{required(atom) => [module]}) :: [module]
  defp gather_modules(apps, acc \\ %{})
  defp gather_modules([], acc), do: acc |> Map.values() |> List.flatten()

  defp gather_modules([app | t], acc) do
    if Map.has_key?(acc, app) do
      gather_modules(t, acc)
    else
      :application.load(app)

      case :application.get_all_key(app) do
        {:ok, data} ->
          gather_modules(
            t ++ ((data[:applications] || []) -- @ignore),
            Map.put(acc, app, data[:modules] || [])
          )

        _ ->
          gather_modules(t, acc)
      end
    end
  end
end
