defmodule Slate.Repo.Migrations.AddAddressTypesToMigration do
  use Ecto.Migration

  def change do
    # TODO initialize this field with values:
    #      * assisted living center (ALC)
    #        -> create relationship to ALC (e.g., "is_resident_of") and specific
    #           ALC will become a member of the ENTITIES table
    #      * commercial (office, depot etc.)
    #        -> This is probably an office for a firm, so see ALC comment above.
    #      * private residential
    #        -> Owned home or apartement but could be a rental that belongs to
    #           a firm or individual so see ALC above.
    #      * community residential (e.g., senior center, see ALC comment)
    #      * nursing home (see ALC comment)
    #      * homeless
    #        -> in short, see ALC comment with adding that these people could
    #           be referred by current clients/volunteers of SFTB and they share
    #           their homes.
    #
    #      --- BUT ---
    #
    #      Just talked to Pat so this simple type system will be escalated
    #      to a full blown tagging system because
    #      (1) see homeless above
    #      (2) people may provide multiple addresses that would be nice to
    #          keep track of.
    #          For example, we don't provide services for Lassen county, but
    #          people sometimes move in with their relatives in a county where
    #          we do, and they give that address. So how could this be done
    #          efficiently?
    create table(:address_types, primary_key: false) do

      # TODO This would be a good place to use natural PKs, right?
      # NOTE: probably only when this would be 1:1 but recent news above
      #           don't point that way.
      #       AND
      #       there is also that: https://stackoverflow.com/questions/590442/
      #
      #       Let's just leave the surrogate keys for now..
      add :id, :binary_id, primary_key: true, null: false,
          comment: "PK"

      # TODO seed this (https://hexdocs.pm/phoenix/seeding_data.html)
      add :type, :text, null: false,
          comment: "Current choices: "            <>
                       "assisted living center, " <>
                       "commercial, "             <>
                       "private residential, "    <>
                       "community residential, "  <>
                       "nursing home."
    end

    execute "COMMENT ON TABLE address_types IS "                        <>
            "'(ADDRESSES |---| ADDRESS_TYPES) Address types associated" <>
            " with a specific address'"

    create unique_index(
      :address_types,
      [:type],
      comment: "Don't allow duplicate address types")
  end
end
