defmodule Slate.Repo.Migrations.AddContactsTable do
  use Slate.Migration

  def change do
    # TODO clean up this mess so that the lessons learned are extracted
    # # Preserved this block to keep the "todo".
    # # create table(:contacts, primary_key: false) do
    # #   # "todo" figure out where this `:binary_id` is defined
    # #   #      The docs are clear about how to use it but OCD.
    # create_table_with_binary_id_as_primary_key(:contacts) do
    # # # add :id,          :binary_id, primary_key: true
    #   add :surnames,    :text, null: false,
    #       comment: "Surnames separated by space"

    #   add :given_names, :text, null: false,
    #       comment: "Given names separated by space"

    #   timestamps()
    # end

    create_table_with_binary_id_as_primary_key(:contacts) do
      add :name, :text,
          comment: "Contact name, format depends on type. " <>
            "E.g., type: [:individual, :CORE, :client] " <>
                   "=> surnames: ..., :given_names: ..."

      timestamps()
    end

    execute "COMMENT ON TABLE contacts IS " <>
            "'Application-global contact list. Most tables will reference this.'"
  end
end
