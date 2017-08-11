defmodule Slate.Migration do
  @moduledoc ~S"""
  using to keep extra SLATE-related migration commands.
  """

  alias Ecto.Migration.{Table,Runner}

  @doc """
  Because of using `:binary_id`s by default, `:primary_key` needs to be unset
  every single time when creating a new table and set by adding an `id` field.

  Not very sophisticated but works: basically just copied the commands from
  `Ecto.Migration.create/2` macro. (Don't expect any further customizations).
  """
  defmacro create_table_with_binary_id_as_primary_key(table_name, do: block) do
    quote do
      table = struct(%Table{name: unquote(table_name)}, [primary_key: false])

      Runner.start_command({:create, Ecto.Migration.__prefix__(table)})

      add(:id, :binary_id, primary_key: true)
      unquote(block)

      Runner.end_command
      table
    end
  end

  # TODO create general macro to automatically create `references` with binary_id
  #      see phone_number migration

  defmacro __using__(_) do
    quote location: :keep do
      use Ecto.Migration

      # Import is not strictly needed but it is convenient so that the
      # `create_table_with_binary_id_as_primary_key/2` macro does not
      # need to be called explicitly from every migration file.
      import Slate.Migration
    end
  end
end
