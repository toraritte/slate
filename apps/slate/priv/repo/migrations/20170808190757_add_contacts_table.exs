defmodule Slate.Repo.Migrations.AddContactsTable do
  use Slate.Migration

  def change do
    # Preserved this block to keep the TODO.
    # create table(:contacts, primary_key: false) do
    #   # TODO figure out where this `:binary_id` is defined
    #   #      The docs are clear about how to use it but OCD.
    create_table_with_binary_id_as_primary_key(:contacts) do
    # # add :id,          :binary_id, primary_key: true
      add :surnames,    :text, null: false
      add :given_names, :text, null: false

      timestamps()
    end
  end
end
