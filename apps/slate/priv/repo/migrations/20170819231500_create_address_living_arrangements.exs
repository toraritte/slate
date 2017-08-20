defmodule Slate.Repo.Migrations.CreateLivingArrangements do
  use Ecto.Migration

  def change do
    create table(:living_arrangements, primary_key: false) do

      add :id, :binary_id, primary_key: true, null: false,
          comment: "PK"

      # TODO Explore how to create relationships. For example, a homeless in
      #      our case would usually live with someone or use their address.
      #      Or individuals living outside of the counties where we provide
      #      services, they would move in with family and/or use their address.
      add :type, :text, null: false,
          comment: "Initial choices: "                     <>
                       "homeless, "                        <>
                       "living with: "                     <>
                       "family (spouse, children, etc.), " <>
                       "caregiver, "                       <>
                       "friend."
    end

    execute "COMMENT ON TABLE living_arrangements IS "                       <>
            "'(ADDRESSES |>-<| LIVING_ARRANGEMENTS) Living arrangement tags" <>
            " associated with a specific address.'"

    create unique_index(
      :address_types,
      [:type],
      comment: "Don't allow duplicate address types")
  end
end
