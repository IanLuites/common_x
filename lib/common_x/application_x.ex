defmodule ApplicationX do
  @moduledoc ~S"""
  Application module extended functions.
  """
  alias Mix.Project
  import Mix.Task, only: [run: 2]
  @ignore [:kernel, :stdlib, :elixir, :logger]
  @load_error 'no such file or directory'

  main_project =
    if p = Process.whereis(Mix.TasksServer) do
      module =
        p
        |> Agent.get(&Map.keys/1)
        |> Enum.find_value(false, fn
          {:task, task, m} when task in ~W(app.start deps.loadpaths) -> m
          _ -> false
        end)

      if module, do: module.project()
    end

  main_app =
    if main_project do
      main_project[:app]
    else
      [
        Path.join(File.cwd!(), "../../mix.exs"),
        Path.join(File.cwd!(), "mix.exs"),
        Path.join(__DIR__, "../../../../mix.exs"),
        Path.join(__DIR__, "../../mix.exs")
      ]
      |> Enum.find_value("", fn file ->
        case File.read(file) do
          {:ok, d} -> d
          _ -> false
        end
      end)
      |> (fn v ->
            ~r/app:\W*:(?<app>[a-z\_]+)/
            |> Regex.named_captures(v)
            |> Kernel.||(%{})
            |> Map.get("app", to_string(Mix.Project.config()[:app]))
          end).()
      |> String.to_atom()
    end

  @doc ~S"""
  The atom of the current main application.

  For example take an application called `:my_app`,
  which includes the `:my_dep` dependencies,
  which has `:common_x` as dependency.

  So:
  ```
  :my_app
  ├── ...
  └── :my_dep
      ├── ...
      └── :common_x
  ```

  In that scenario calling `ApplicationX.main` will return `:my_app`
  both for code in `:my_app` and `:my_dep`.

  ## Examples

  ```elixir
  iex> ApplicationX.main
  :common_x
  ```
  """
  @spec main :: atom
  def main, do: unquote(main_app)

  @doc ~S"""
  The mix configuration of the current main application.

  For example take an application called `:my_app`,
  which includes the `:my_dep` dependencies,
  which has `:common_x` as dependency.

  So:
  ```
  :my_app
  ├── ...
  └── :my_dep
      ├── ...
      └── :common_x
  ```

  In that scenario calling `ApplicationX.main` will return
  the mix config of `:my_app` both for code in `:my_app` and `:my_dep`.

  ## Examples

  ```elixir
  iex> config = ApplicationX.main_project
  iex> config[:app]
  :common_x
  iex> config[:description]
  "Extension of common Elixir modules."
  ```
  """
  @spec main_project :: Keyword.t()
  def main_project, do: unquote(Macro.escape(main_project || []))

  @test_tasks ~W(test coveralls coveralls.html coveralls.json)

  env =
    cond do
      e = System.get_env("MIX_ENV") ->
        String.to_existing_atom(e)

      p = Process.whereis(Mix.TasksServer) ->
        tasks =
          p
          |> Agent.get(&Map.keys(&1))
          |> Enum.map(&elem(&1, 1))
          |> Enum.uniq()

        cond do
          "run" in tasks -> :dev
          Enum.any?(@test_tasks, &(&1 in tasks)) -> :test
          :default -> :prod
        end

      :default ->
        :prod
    end

  @doc ~S"""
  Get the current Mix environment.

  ## Example

  ```elixir
  iex> ApplicationX.mix_env
  :test
  ```
  """
  @spec mix_env :: atom
  def mix_env, do: unquote(env)

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
    app = if(Process.whereis(Mix.ProjectStack), do: Project.config()[:app])

    if app do
      with {:error, {@load_error, _}} <- :application.load(app), do: run("loadpaths", [])
      gather_applications([app])
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
  [ApplicationX, CodeX, CommonX, EnumX, MacroX, MapX]
  ```
  """
  @spec modules :: [module]
  def modules do
    app = if(Process.whereis(Mix.ProjectStack), do: Project.config()[:app])

    if app do
      with {:error, {@load_error, _}} <- :application.load(app), do: run("loadpaths", [])
      modules(app)
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
    Logger.Config, Logger.Counter, Logger.Filter, Logger.Formatter, Logger.Handler,
    Logger.Translator, Logger.Utils, Logger.Watcher]
  ```

  Duplicate applications are ignored:
  ```elixir
  iex> ApplicationX.modules([:logger, :logger])
  [Logger, Logger.App, Logger.BackendSupervisor, Logger.Backends.Console,
    Logger.Config, Logger.Counter, Logger.Filter, Logger.Formatter, Logger.Handler,
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
