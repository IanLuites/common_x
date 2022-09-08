# CommonX

[![Hex.pm](https://img.shields.io/hexpm/v/common_x.svg "Hex")](https://hex.pm/packages/common_x)
[![Build Status](https://travis-ci.org/IanLuites/common_x.svg?branch=master)](https://travis-ci.org/IanLuites/common_x)
[![Coverage Status](https://coveralls.io/repos/github/IanLuites/common_x/badge.svg?branch=master)](https://coveralls.io/github/IanLuites/common_x?branch=master)
[![Hex.pm](https://img.shields.io/hexpm/l/common_x.svg "License")](LICENSE)

Extension of common Elixir modules.

## Installation

The package can be installed by adding `common_x` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:common_x, "~> 0.5"}
  ]
end
```

The docs can be found at [https://hexdocs.pm/common_x](https://hexdocs.pm/common_x).

## Extensions

The following modules have extension:

- `ApplicationX` (`Application` extension)
- `CodeX` (`Code` extension)
- `EnumX` (`Enum` extension)
- `MapX` (`Map` extension)
- `Macro` (`Macro` extension)

## Changelog

### 2022-09-08 (v0.5.9)

- Support Elixir 1.14 changes.

### 2022-09-07 (v0.5.7 / v0.5.8)

- Recompile when mix.exs changes.

### 2020-08-12 (v0.5.6)

- Fix project detection when installed inside a Elixir script with [`Mix.install/2`](https://hexdocs.pm/mix/Mix.html#install/2).

### 2020-11-08 (v0.5.5)

- Small fix detecting compile environment in custom commands and Elixir >= 1.11.

### 2020-10-08 (v0.5.4)

- Small fix detecting compile environment.

### 2020-07-02 (v0.5.3)

- Compile warning fix.

### 2020-05-13 (v0.5.2)

- Improve `ApplicationX.mix_env/0` for newer OTP/Elixir versions.

### 2020-04-05 (v0.5.1)

- Add `ApplicationX.mix_env/0`, which returns the current Mix environment.

### 2020-03-15 (v0.5.0)

- Add `CodeX.ensure_compiled?/1`, which returns `true` if the module is already compiled or was successfully compiled.
- Add `CodeX.ensure_loaded?/1`, which returns `true` if the module is already loaded or was successfully loaded.

### 2020-03-08 (v0.4.1)

- Add `ApplicationX.main_project/0`, which returns the mix project config of the main application, even when called from dependencies.

### 2020-03-07 (v0.4.0)

- Add `ApplicationX.main/0`, which returns the atom of the main application, even when called from dependencies.

### 2020-01-15 (v0.3.0)

- Add `MapX.update_if_exists/3` to update map values, only if the key exists.

### 2019-12-23 (v0.2.3)

- Fix `MapX.new/2` spec.

### 2019-10-12 (v0.2.0)

- Add `ApplicationX` extension with the following methods:
  - `applications/0` list all applications, without starting.
  - `applications/1` list all dependencies, without starting.
  - `modules/0` list all modules, without starting applications.
  - `modules/1` list all modules in given applications, without starting them.

### 2019-01-01 (v0.0.2)

- Add `MacroX` extension with the following methods:
  - `camalize/1` proper camelCase for `string` and `atom`.
  - `pascalize/1` proper PascalCase for `string` and `atom`.
  - `snakize/1` proper snake_case for `string` and `atom`.
  - `underscore/1` alias for `snakize`.
