defmodule Pan.Episode do
  use Pan.Web, :model
  alias Pan.Repo
  alias Pan.Like
  alias Pan.Episode
  alias Pan.Gig

  schema "episodes" do
    field :title, :string
    field :link, :string
    field :publishing_date, Ecto.DateTime
    field :guid, :string
    field :description, :string
    field :shownotes, :string
    field :payment_link_title, :string
    field :payment_link_url, :string
    field :deep_link, :string
    field :duration, :string
    field :subtitle, :string
    field :summary, :string
    timestamps()

    belongs_to :podcast, Pan.Podcast

    has_many :chapters, Pan.Chapter, on_delete: :delete_all
    has_many :enclosures, Pan.Enclosure, on_delete: :delete_all
    has_many :recommendations, Pan.Recommendation, on_delete: :delete_all

    has_many :gigs, Pan.Gig
    many_to_many :contributors, Pan.Persona, join_through: "gigs", on_delete: :delete_all
  end


  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:title, :link, :publishing_date, :description, :shownotes, :duration,
                     :payment_link_title, :payment_link_url, :deep_link, :subtitle, :summary,
                     :guid])
    |> validate_required([:title, :link, :publishing_date, :description, :shownotes, :duration])
    |> unique_constraint(:guid)
  end


  def like(episode_id, user_id) do
    case Repo.get_by(Like, enjoyer_id: user_id,
                           episode_id: episode_id) do
      nil ->
        episode = Repo.get(Episode, episode_id)
        %Like{enjoyer_id: user_id, episode_id: episode_id,
              podcast_id: episode.podcast_id}
        |> Repo.insert
      like ->
        Repo.delete!(like)
    end
  end

  def likes(id) do
    from(l in Like, where: l.episode_id == ^id)
    |> Repo.aggregate(:count, :id)
    |> Integer.to_string
  end


  def latest do
    from(e in Pan.Episode, order_by: [desc: :publishing_date],
                           join: p in assoc(e, :podcast),
                           where: is_nil(p.blocked) or p.blocked == false,
                           preload: :podcast,
                           limit: 5)
    |> Repo.all()
  end


  def author(episode) do
    gig = from(Gig, where: [role: "author",
                            episode_id: ^episode.id],
                    preload: :persona)
    |> Repo.one()

    if gig, do: gig.persona
  end
end
