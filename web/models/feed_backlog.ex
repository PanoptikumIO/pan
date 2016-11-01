defmodule Pan.FeedBacklog do
  use Pan.Web, :model

  schema "backlog_feeds" do
    field :url, :string
    field :feed_generator, :string
    field :in_progress, :boolean, default: false
    belongs_to :user, Pan.User

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:url, :feed_generator, :in_progress])
    |> validate_required([:url, :in_progress])
  end
end
