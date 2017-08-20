defmodule Slate.Repo.Migrations.CreateEntityDemographics do
  use Ecto.Migration

  # NOTE This is where "is_homeless" (or similar) should be recorded that
  #      would play a big role with OIB intake and would be used with
  #      with address relationships (LIVING_ARRANGEMENTS) such as
  #
  #      * (is_homeless=TRUE && uses_address_of) etc
  def change do

  end
end
