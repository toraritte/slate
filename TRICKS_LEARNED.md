How to use pattern matching to ensure assignment of correct struct:
```elixir
# https://github.com/elixir-ecto/ecto/blob/v2.1.6/lib/ecto/migration.ex#L275
defmodule A, do: defstruct [:a_things]
defmodule B, do: defstruct [:b_things]

a_struct = %A{} = %A{a_things: "indeed"}
#=> %A{a_things: "indeed"}

b_struct = %B{} = a_struct
#!> ** (MatchError) no match of right hand side value: %A{a_things: "indeed"}
```

QUESTION:
  Why don't they use pattern matching on the
  `defp expand_create(->object<-, command, block)`
  line instead?
  (same with `defmacro alter(object...)`)

ANSWER:
  Because pattern matching doesn't work on macros.
```elixir
  defmacro __using__(_) do
    quote location: :keep do
      use Ecto.Migration
      import Slate.Migration
    end
  end
end

defmodule TestMacroPatternMatch do
  defmacro works?(%A{} = a_struct) do
    quote do
      the_struct = unquote(a_struct)
      the_struct
    end
  end
end

defmodule A, do: defstruct [:a_thing]

defmodule TrialModule do
  require TestMacroPatternMatch

  IO.inspect TestMacroPatternMatch.works?(%A{a_thing: "indeed"})
end

#!> ** (FunctionClauseError) no function clause matching in TestMacroPatternMatch.works?/1
#!> expanding macro: TestMacroPatternMatch.works?/1
#!> iex:11: TrialModule (module)
```

  But works just fine with the workaround:
```elixir
defmodule TestMacroPatternMatch do
  # defmacro works?(%A{} = a_struct) do
  defmacro works?(object) do
    quote do
  #   the_struct = unquote(a_struct)
      the_struct = %A{} = unquote(object)
      the_struct
    end
  end
end

defmodule A, do: defstruct [:a_thing]

defmodule TrialModule do
  require TestMacroPatternMatch

  IO.inspect TestMacroPatternMatch.works?(%A{a_thing: "indeed"})
end

#=> %A{a_thing: "indeed"}
```
---------------------------------------------------
Importing a function with the same and same arity:

```elixir
iex(11)> defmodule FirstImport do
...(11)>   def do_stuff, do: 7
...(11)> end
{:module, FirstImport,
 <<70, 79, 82, 49, 0, 0, 3, 204, 66, 69, 65, 77, 65, 116, 85, 56, 0, 0, 0, 93,
   0, 0, 0, 8, 18, 69, 108, 105, 120, 105, 114, 46, 70, 105, 114, 115, 116, 73,
   109, 112, 111, 114, 116, 8, 95, 95, 105, ...>>, {:do_stuff, 0}}
iex(12)> defmodule SecondImport do
...(12)>   def do_stuff, do: 27
...(12)> end
{:module, SecondImport,
 <<70, 79, 82, 49, 0, 0, 3, 208, 66, 69, 65, 77, 65, 116, 85, 56, 0, 0, 0, 94,
   0, 0, 0, 8, 19, 69, 108, 105, 120, 105, 114, 46, 83, 101, 99, 111, 110, 100,
   73, 109, 112, 111, 114, 116, 8, 95, 95, ...>>, {:do_stuff, 0}}
iex(13)> defmodule ImportHere do
...(13)>   import FirstImport
...(13)>   import SecondImport
...(13)>
...(13)>   def wonder_what, do: do_stuff
...(13)> end
** (CompileError) iex:17: function do_stuff/0 imported from both SecondImport and FirstImport, call is ambiguous
    (elixir) src/elixir_dispatch.erl:111: :elixir_dispatch.expand_import/6
    (elixir) src/elixir_dispatch.erl:81: :elixir_dispatch.dispatch_import/5
    iex:17: (module)
```
---------------------------------------------------
