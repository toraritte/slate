defmodule Slate.Entities.Contact do
  use Slate.Schema
  import Ecto.Changeset
  alias Slate.Entities.Contact

  schema "contacts" do
    field :surnames, :string
    field :given_names, :string

    timestamps()
  end

  @required_fields [:surnames, :given_names]

  @doc false
  def changeset(%Contact{} = contact, attrs) do
    contact
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
  end
end
