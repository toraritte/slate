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
[Can foreign key references contain NULL values in PostgreSQL?](https://stackoverflow.com/questions/28206232/can-foreign-key-references-contain-null-values-in-postgresql)

Yes. So if this is not desirable do
```elixir
create table(:blabla) do
  # The :binary_id is needed if the referenced table
  # has UUID as primary key
  add :contact_id, references(:contacts, [type: :binary_id]), null: false
end
```
---------------------------------------------------
[Beautiful SO answer on how to define foreign keys in PostgreSQL.](https://stackoverflow.com/questions/28558920/postgresql-foreign-key-syntax)
---------------------------------------------------
`Ecto.Migration.add/3` takes a column name, its type and arbitrary number of
options as list yet you don't see them supplied as lists. Why?

For example:
```elixir
  add :contact_id, references(:contacts, [type: :binary_id]),
    null: false,
    on_delete: :delete_all
```

The reason:
```elixir
iex(1)> defmodule ArgTest do
...(1)>   def rest(first, second, rest), do: rest
...(1)> end
iex(2)
iex(3)> ArgTest.rest(:lofa, 27, option1: :a, another: :b)

#=> [option1: :a, another: :b]
```
---------------------------------------------------
POSTGRES: How restrict ONE distinct value (e.g., `true`) for EACH entity in a table?

          For example, ADDRESSES table to CONTACTS where each contact has only 1
                       primary address, denoted by a boolean column that defaults
                       to `false`.

  (1) As an exotic solution you could add a `TrueRow` table such as
      PRIMARY_ADDRESSES outlined here:
      https://stackoverflow.com/questions/3228161/could-i-make-a-column-in-a-table-only-allows-one-true-value-and-all-other-rows¬

  (2) But why would you do it if you can resolve this conundrum with a
      partial constraint. Took this idea from
      https://dba.stackexchange.com/questions/4815/how-to-implement-a-default-flag-that-can-only-be-set-on-a-single-row
      https://stackoverflow.com/questions/28166915/postgresql-constraint-only-one-row-can-have-flag-set

      An example that worked in [SQL Fiddle](http://sqlfiddle.com/#!17/ac694/4):

        Schema:
        ```sql
        CREATE TABLE contacts
        (
          id serial NOT NULL,
          name text NOT NULL,
          CONSTRAINT my_table_pkey PRIMARY KEY (id)
        );

        CREATE TABLE phone_numbers
        (
          id serial NOT NULL,
          contact_id serial REFERENCES contacts(id),
          phone_number varchar(16) NOT NULL,
          is_preferred boolean DEFAULT false
        );

        CREATE UNIQUE INDEX ON phone_numbers (contact_id, is_preferred) 
          WHERE is_preferred = true;

        INSERT INTO contacts (name)
          VALUES
            ('lofa'),
            ('balabab'),
            ('vmi');

        INSERT INTO phone_numbers (contact_id, phone_number)
          VALUES
            ((SELECT id FROM contacts WHERE name='lofa'),'123'),
            ((SELECT id FROM contacts WHERE name='lofa'),'345'),
            ((SELECT id FROM contacts WHERE name='lofa'),'678');
        ```

        Adding conflicting entries:
        ```sql
        INSERT INTO phone_numbers (contact_id, phone_number, is_preferred)
          VALUES
            ((SELECT id FROM contacts WHERE name='lofa'),'777', true);

        INSERT INTO phone_numbers (contact_id, phone_number, is_preferred)
          VALUES
            ((SELECT id FROM contacts WHERE name='lofa'),'999', true);

        select * from phone_numbers;

        -- results in:
        -- ERROR: duplicate key value violates unique constraint "phone_numbers_contact_id_is_preferred_idx" Detail: Key (contact_id, is_preferred)=(1, t) already exists
        ```
---------------------------------------------------
