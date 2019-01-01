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
    {:common_x, "~> 0.0.1"}
  ]
end
```

The docs can be found at [https://hexdocs.pm/common_x](https://hexdocs.pm/common_x).

## Extensions

The following modules have extension:

 - `EnumX` (`Enum` extension)
 - `MapX` (`Map` extension)
 - `Macro` (`Macro` extension)

## Changelog

### 2019-01-01 (v0.0.2)

- Add `MacroX` extension with the following methods:
  - `camalize/1` proper camelCase for `string` and `atom`.
  - `pascalize/1` proper PascalCase for `string` and `atom`.
  - `snakize/1` proper snake_case for `string` and `atom`.
  - `underscore/1` alias for `snakize`.
