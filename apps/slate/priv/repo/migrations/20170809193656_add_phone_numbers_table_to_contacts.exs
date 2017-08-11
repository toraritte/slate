defmodule Slate.Repo.Migrations.AddPhoneNumbersTableToContacts do
  use Slate.Migration

  def up do
    # https://stackoverflow.com/questions/35245859/how-to-use-postgres-enumerated-type-with-ecto
    # also, list stolen from Google's contact list entry template
    execute "CREATE TYPE phone_type AS ENUM" <>
            "('mobile', 'home/landline', 'work', 'company main'," <>
             "'work fax', 'home fax', 'company main fax'," <>
             "'pager', 'car', 'MMS', 'radio', 'assistant')"

    execute "COMMENT ON TYPE phone_type IS 'Type of device associated with the phone number'"

    create_table_with_binary_id_as_primary_key(:phone_numbers) do
      add :contact_id, references(:contacts, [type: :binary_id]),
        null: false,
        # TODO test ON DELETE somehow because it does not show with
        #      `\d+ phone_numbers` in `psql`
        on_delete: :delete_all,
        comment:   "FK to CONTACTS table"

      # https://dba.stackexchange.com/questions/164796/how-do-i-store-phone-numbers-in-postgresql
      # -> `pg_libphonenumber` looks interesting but would be an overkill
      # -> because we barely get phone numbers even outside Northern CA.
      #
      # Leaving it as `text` for now and just normalize input to US phone numbers
      # E.g., (555) 657-1234 -> "15556571234"
      add :phone_number,  :text,        null: false,
          comment: "Phone number in the format of \"9168897510\" as text"

      add :preferred,     :boolean,     null: false,
          comment: "Preferred phone number (ECTO default: FALSE)"

      add :type,          :phone_type,
          comment: "Type of phone number associated with the device. (May be NULL.)"

      timestamps()
    end

    execute "COMMENT ON TABLE phone_numbers IS " <>
            "'(CONTACTS |---1:N--<| PHONE_NUMBERS) Phone numbers associated to a specific contact'"

    # TODO test this
    #      CAVEAT multiple contacts with the same names are allowed
    #             so testing it with an "all" insert (contact + numbers)
    #             would result in the table below if a similar command
    #             is issued multiple times:

    # Contact.insert_phone_numbers(%Contact{}, %{surnames: "mas", given_names: "vmi", phone_numbers: [ %{phone_number: "9"}, %{phone_number: "7", type: "work"}]}) |> Repo.insert()

                      # id                  |              contact_id              | phone_number | preferred | type
    # --------------------------------------+--------------------------------------+--------------+-----------+------
     # 5c1b462a-bba4-4a14-bf8d-56a989354109 | 6ff5bb13-dbdb-455b-97a1-79cb40223d4b | 9            | f         |
     # 126d0bb3-8967-4bf7-bdaf-9f530ac535ec | 6ff5bb13-dbdb-455b-97a1-79cb40223d4b | 7            | f         | work
     # 1ddeb315-27c7-4b91-ac91-57de5a80131e | 9d1cac0a-29d2-4612-9165-c055987f4ad5 | 9            | f         |
     # 61530b7f-8129-44dd-84ac-a041f03de66f | 9d1cac0a-29d2-4612-9165-c055987f4ad5 | 7            | f         | work
     # 60442171-141c-4ecf-8405-e8157aa5f3a0 | 825cf0fb-c6d2-4a42-8047-d89403e90d97 | 9            | f         |
     # fe60a87b-5b39-4526-b1f7-342964aa2919 | 825cf0fb-c6d2-4a42-8047-d89403e90d97 | 7            | f         | work

     # (1) figure out how to add phone numbers separately to specific contacts
     # (2) test this
     # (2.5) learn how to write tests...
     # (3) write tests

    create unique_index(
      :phone_numbers,
      [:contact_id, :phone_number],
      comment: "UNIQUE constraint to ensure that CONTACTS don't have the " <>
               "same number multiple times"
    )
  end

  def down do
    execute "DROP TYPE phone_type"
    drop index(:phone_numbers, [:phone_number])
    drop table(:phone_numbers)
  end
end
