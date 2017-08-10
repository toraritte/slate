defmodule Slate.Schema do
  @moduledoc ~S"""
  setting up `:binary_id` as default for any new schema. We'll see whether
  using UUIDs a good idea after all.
  """
  defmacro __using__(_) do
    quote location: :keep do
      use Ecto.Schema
      @primary_key {:id, :binary_id, autogenerate: true}
      @foreign_key_type :binary_id
    end
  end
end
