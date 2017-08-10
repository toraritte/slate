defmodule Slate.Repo.Migrations.AddPhoneNumbersTableToContacts do
  use Slate.Migration

  def change do
    create_table_with_binary_id_as_primary_key(:phone_numbers) do
      add :somefield, :text
    end
  end
end
