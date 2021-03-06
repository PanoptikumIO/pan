defmodule PanWeb.EpisodeFrontendController do
  use Pan.Web, :controller
  alias PanWeb.{Chapter, Episode, Recommendation}

  def show(conn, %{"id" => id}) do
    episode =
      Repo.get!(Episode, id)
      |> Repo.preload([:podcast, :enclosures, gigs: :persona, recommendations: :user])
      |> Repo.preload(
        chapters:
          from(chapter in Chapter,
            order_by: chapter.start,
            preload: [recommendations: :user]
          )
      )

    changeset = Recommendation.changeset(%Recommendation{})
    # options for player: "podlove", "podigee"
    render(conn, "show.html",
      episode: episode,
      player: "podlove",
      changeset: changeset
    )
  end

  def player(conn, %{"id" => id}) do
    episode =
      Repo.get!(Episode, id)
      |> Repo.preload([:podcast, :enclosures, gigs: :persona, recommendations: :user])
      |> Repo.preload(chapters: from(chapter in Chapter, order_by: chapter.start))

    # options for player: "podlove", "podigee"
    conn
    |> put_layout("minimal.html")
    |> render("player.html",
      episode: episode,
      player: "podlove"
    )
  end

  def index(conn, params) do
    episode_ids =
      from(e in Episode,
        order_by: [desc: :id],
        select: e.id
      )
      |> Repo.paginate(
        page: params["page"],
        page_size: 10,
        options: [total_entries: total_estimated(Episode)]
      )

    episodes =
      from(e in Episode,
        join: p in assoc(e, :podcast),
        where:
          e.id in ^episode_ids.entries and
            not p.blocked,
        order_by: [desc: :id],
        preload: :podcast
      )
      |> Repo.all()

    render(conn, "index.html", episode_ids: episode_ids, episodes: episodes)
  end

  def silence(conn, _params) do
    # Just here to silence a weird request from the podlove webplayer
    text(conn, nil)
  end
end
