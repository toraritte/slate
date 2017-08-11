# TODO Examine `civicrm.mysql`'s contact table.
#      Maybe I am hyper-normalizing but they mix in demographic and other
#      data that I chose to extract to other tables. For example columns
#       * `do_not_{email,call,sms, etc}
#       * `{email,postal}_greeting_*`
#       * `preferred_{mail_format,comm_method,language}`

defmodule Slate.Entities.Contact do
  use Slate.Schema
  alias Slate.Entities.Contact.{PhoneNumber}
  alias Slate.Repo

  schema "contacts" do
    field :surnames,     :string
    field :given_names,  :string
    has_many :phone_numbers, PhoneNumber

    timestamps()
  end

  @required_fields [:surnames, :given_names]

  @doc false
  # TODO duplicate names (surnames + given_names) are possible which should
  #      be the case but it would be nice to warn the user: is she trying
  #      to enter a duplicate or this person coincidentally has the same name?

  #      DB unique constraint wouldn't allow duplicates so this should be
  #      addressed in the application logic, but where?
  def changeset(%Contact{} = contact, attrs) do
    contact
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
  end

  # TODO should this (and similar) functions go here or to the context
  #      main?

  # TODO how is this handled efficiently? a new changeset function for every
  #      scenario? or something along the lines of a configurable function?
  #      such as `add_contact([:phone_number, :email, ..., etc.)` ?
  def insert_new_contact_with_phone_number(%Contact{} = contact, attrs) do
    contact
    |> Repo.preload(:phone_numbers)
    |> changeset(attrs)
    |> cast_assoc(:phone_numbers)
  end
end

# test in IEx
# TODO: learn to write proper tests already...
#

# alias Slate.Entities.Contact
# alias Slate.Entities.Contact.PhoneNumber
# alias Slate.Repo
# import Ecto.Query

# Contact.changeset(%Contact{}, %{surnames: "lofa", given_names: "balabab"}) |> Repo.insert()

# # will be false
# PhoneNumber.changeset(%PhoneNumber{}, %{phone_number: "9168897510", type: "lofa"})
# # ok
# PhoneNumber.changeset(%PhoneNumber{}, %{phone_number: "9168897510", type: "work"})
# # ok
# PhoneNumber.changeset(%PhoneNumber{}, %{phone_number: "9168897510"})

# # ok
# Contact.insert_phone_numbers(%Contact{}, %{surnames: "mas", given_names: "vmi", phone_numbers: [ %{phone_number: "9"}, %{phone_number: "7", type: "work"}]}) |> Repo.insert()
