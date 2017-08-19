defmodule Slate.Repo.Migrations.CreateEntities do
  use Ecto.Migration

  def change do
    # TODO There is a lot of repetitive code in the migrations because of the
    #      use of binary_ids. (Time will tell if it was worth it.)
    #
    #      Examples of the repetition:
    #
    #      * for new REFERENCED (i.e., parent) tables:
    #
    #             create table(:entities, PRIMARY_KEY: FALSE) do
    #               ADD :ID, :BINARY_ID, PRIMARY_KEY: TRUE, NULL: FALSE,
    #                   COMMENT: "pk"
    #
    #      * for new REFERENCING (i.e., child) tables:
    #
    #             same as for the REFERENCED ones plus
    #
    #             ADD :ENTITY_ID, REFERENCES(:ENTITIES, [TYPE: :BINARY_ID]),
    #                 NULL: FALSE,
    #               ON_DELETE: :DELETE_ALL,
    #               COMMENT: "FK to ENTITIES table"
    #
    #      Ideas:
    #
    #      (1) Leave in the duplicated code in each migration file
    #          => clean, explicit table creation that could act as
    #             documentation
    #
    #          SOLUTION:
    #          Create a Mix task for generating Slate migration templates.
    #
    #      (2) Go down the macro rabbit hole.
    #          See `Slate.Migration.create_table_with_binary_id_as_primary_key/1`.
    #
    #          Looks messy. What works for Schemas, may be not be the best for 
    #          migrations.

    create table(:entities, primary_key: false) do

      add :id, :binary_id, primary_key: true, null: false,
          comment: "PK"

      # TODO change type to jsonb and figure out the convention for
      # different entities
      add :name, :text, null: false,
          # TODO this description is wrong but until this has been figured
          #      out, it stays
          comment: "entity name, format depends on type. "      <>
                   "E.g., type: [:individual, :CORE, :client] " <>
                   "=> surnames: ..., :given_names: ..."

      timestamps()
    end

    execute "COMMENT ON TABLE entities IS " <>
            "'Application-global contact list. Most tables will reference this.'"
  end
end
