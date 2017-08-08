defmodule Slate.Repo.Migrations.AddContactsTable do
  use Ecto.Migration

  def change do
    create table(:contacts, primary_key: false) do
      # TODO figure out where this `:binary_id` is defined
      #      The docs are clear about how to use it but OCD.
      add :id,          :binary_id, primary_key: true
      add :surnames,    :text
      add :given_names, :text

      timestamps()
    end
  end
end
