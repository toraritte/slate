defmodule Slate.Repo.Migrations.AddAddressesToEntities do
  use Ecto.Migration

  def change do
    create table(:addresses, primary_key: false) do

      add :id, :binary_id, primary_key: true, null: false,
          comment: "PK"

      add :entity_id,
          references(:entities, [type: :binary_id]),
          null: false,
          # TODO test ON DELETE somehow because it does not show with
          #      `\d+ phone_numbers` in `psql`
          on_delete: :delete_all,
          comment:   "FK to ENTITIES table"

      timestamps()
    end

    execute "COMMENT ON TABLE addresses IS "                             <>
            "'(ENTITIES |---1:N--<| ADDRESSES) Addresses associated" <>
            " with a specific entity'"

  end
end
