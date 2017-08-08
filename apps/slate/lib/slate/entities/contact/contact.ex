defmodule Slate.Entities.Contact do
  use Slate.Schema
  import Ecto.Changeset
  alias Slate.Entities.Contact

  schema "contacts" do
    field :surnames, :string
    field :given_names, :string

    timestamps()
  end

  @doc false
  def changeset(
end
