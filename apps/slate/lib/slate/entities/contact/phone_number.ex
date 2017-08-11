defmodule Slate.Entities.Contact.PhoneNumber do
  use Slate.Schema
  alias Slate.Entities.Contact

  schema "phone_numbers" do
    field :phone_number
    field :preferred, :boolean, default: false
    # TODO `:type` is `:string` for now but it may be prudent to replace the
    #      simple SO solution below with an explicit custom Ecto enum type
    #      to eliminate future guesswork.
    #
    #      On the other hand, the use of `validate_inclusion/3` makes it
    #      explicit. Think about it.
    #
    # https://stackoverflow.com/questions/35245859/how-to-use-postgres-enumerated-type-with-ecto
    field :type
    belongs_to :contact, Contact
  end

  @required_fields [:phone_number]
  @allowed_fields  @required_fields ++ [:preferred, :type]

  @phone_types ["mobile", "home/landline", "work", "company main", "work fax",
                "home fax", "company main fax","pager", "car", "MMS", "radio",
                "assistant"]

  @doc false
  def changeset(phone_number, attrs) do
      phone_number
      |> cast(attrs, @allowed_fields)
      |> validate_required(@required_fields)
      # would the changeset be still valid if this field is missing? it should
      |> validate_inclusion(:type, @phone_types)
  end
end
