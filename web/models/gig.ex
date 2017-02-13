defmodule Pan.Gig do
  use Pan.Web, :model

  schema "gigs" do
    field :from_in_s, :integer
    field :until_in_s, :integer
    field :comment, :string
    field :publishing_date, Ecto.DateTime
    field :role, :string
    belongs_to :persona, Pan.Persona
    belongs_to :episode, Pan.Episode

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:publishing_date, :role], [:from_in_s, :until_in_s, :comment])
    |> validate_required([:publishing_date, :role])
  end
end
