
# TODO Take a closer look at `civicrm_relationships` and
#      `civicrm_relationship_types` tables. Based on a quick glance
#      they look very solid.

defmodule Slate.Repo.Migrations.CreateLivingArrangements do
  use Ecto.Migration

  def change do
    #####################################################################
    ###                                                               ###
    ###  LIVING_RELATIONS |---| LIVING_ARRANGEMENTS                   ### 
    ###                                                               ###
    #####################################################################
    create table(:living_relations, primary_key: false) do

      add :id, :binary_id, primary_key: true, null: false,
          comment: "PK"

      add :label_a_b, :text, null: false,
          comment: "Label for address relationship from A to B " <>
                   "(arrow (a,b) of a directed graph)"

      add :label_b_a, :text,
          comment: "OPTIONAL Label for address relationship from " <>
                   "B to A in case of a mutuality "                <>
                   "(arrow (b,a) of a directed graph)"

      add :description, :text,
          comment: "OPTIONAL address relationship description."

      # NOTE Do we need "is_reserved" and "is_active"?
      #      See descriptions at `civicrm_relationship_types`
    end

    create unique_index(
      :living_relations,
      [:label_a_b],
      comment: "Don't allow duplicate address relationship labels (A->B)")

    create unique_index(
      :living_relations,
      [:label_b_a],
      comment: "Don't allow duplicate address relationship labels (B->A)")

    execute "COMMENT ON TABLE living_relations IS "                  <>
            "'(LIVING_ARRANGEMENTS |---| LIVING_RELATIONS) Types to" <>
            " describe entity <-> address relationships'"

    #####################################################################
    ###                                                               ###
    ###  ENTITIES |>-<| LIVING_ARRANGEMENTS                           ### 
    ###                                                               ###
    #####################################################################
    create table(:living_arrangements, primary_key: false) do

      add :id, :binary_id, primary_key: true, null: false,
          comment: "PK"

      add :living_relations_id,
          references(:living_relations, [type: :binary_id, on_delete: :nilify_all]),
          null:       false,
          comment:    "FK to LIVING_RELATIONS table"

      # NOTE Right now ON DELETE is CASCADE for both entity A and B which
      #      makes sense but how would one preserve the history of
      #      past relationships?
      add :a_entity_id,
          references(:entities, [type: :binary_id, on_delete: :delete_all]),
          null:       false,
          comment:    "FK to ENTITIES table for entity A (tail of arrow(a,b))"

      add :b_entity_id,
          references(:entities, [type: :binary_id, on_delete: :delete_all]),
          null:       false,
          comment:    "FK to ENTITIES table for entity B (head of arrow(a,b))"

      # TODO Explore how to create relationships. For example, a homeless in
      #      our case would usually live with someone or use their address.
      #      Or individuals living outside of the counties where we provide
      #      services, they would move in with family and/or use their address.
      #
      # NOTE The concept changed much in the last hour from above but global
      #      relationships are more ingrained now.
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
