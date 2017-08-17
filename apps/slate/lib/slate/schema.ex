defmodule Slate.Schema do
  @moduledoc ~S"""
  Setting up `:binary_id` as default for any new schema. We'll see whether
  using UUIDs a good idea after all.
  """
  defmacro __using__(opts) do
    quote do
      use Ecto.Schema
      import Ecto.Changeset
      alias __MODULE__

      # TODO revisit the idea of importing a "context"
      #      (i.e., a normalized table with all its
      #       subtables)
      #      Example:
      #      `use Slate.Schema, context: Contact` and it
      #      would import Contact.PhoneNumber, Contact.Address etc.

      #      READINGS:
      #      http://theerlangelist.com/article/macros_5
      #      https://medium.com/elixirlabs/dynamically-loading-a-module-in-elixir-c00f2620e3ae

      # case opts do
      #   [context: context] ->

      @primary_key {:id, :binary_id, autogenerate: true}
      @foreign_key_type :binary_id
    end
  end
end

# defmodule A do
#   defmacro __using__(opts) do
#     quote do
#       mod =
#         case unquote(opts) do
#           [] -> __MODULE__
#           [context: context] -> context
#         end
#       import context
#     end
#   end
# end

# defmodule B do
#   def lofa, do: 27
# end

# defmodule C do
#   use A
# end
