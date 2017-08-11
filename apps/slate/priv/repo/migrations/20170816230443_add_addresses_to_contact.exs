defmodule Slate.Repo.Migrations.AddAddressesToContact do
  use Slate.Migration

  def change do
    create_table_with_binary_id_as_primary_key(:addresses)
  end
end
