defmodule Pan.MaintenanceController do
  use Pan.Web, :controller
  alias Pan.CategoryPodcast
  alias Pan.Subscription
  alias Pan.Message
  alias Pan.Gig
  alias Pan.Engagement
  alias Pan.Podcast
  alias Pan.Persona
  alias Pan.Gig
  alias Pan.Episode

  def remove_duplicates(conn, _params) do
    duplicates = from(a in CategoryPodcast, group_by: [a.category_id, a.podcast_id],
                                            select: [a.category_id, a.podcast_id, count(a.podcast_id)],
                                            having: count(a.podcast_id) > 1)
                 |> Repo.all()

    for [category_id, podcast_id, _count] <- duplicates do
      from(a in CategoryPodcast, where: a.category_id == ^category_id and
                                        a.podcast_id == ^podcast_id)
      |> Repo.delete_all()

      Repo.insert!(%CategoryPodcast{podcast_id: podcast_id,
                                    category_id: category_id})
    end

    duplicates = from(a in Subscription, group_by: [a.user_id, a.podcast_id],
                                         select: [a.user_id, a.podcast_id, count(a.podcast_id)],
                                         having: count(a.podcast_id) > 1)
                 |> Repo.all()

    for [user_id, podcast_id, _count] <- duplicates do
      from(a in Subscription, where: a.user_id == ^user_id and
                                     a.podcast_id == ^podcast_id)
      |> Repo.delete_all()

      Repo.insert!(%Subscription{podcast_id: podcast_id,
                                 user_id: user_id})
    end

    render(conn, "remove_duplicates.html", %{})
  end


  def message_cleanup(conn, _params) do
    from(m in Message, where: m.event in ["follow", "subscribe"])
    |> Repo.delete_all()

    render(conn, "message_cleanup.html", %{})
  end


  def remove_duplicate_gigs(conn, _params) do
    duplicates = from(g in Gig, group_by: [g.role, g.episode_id, g.persona_id,],
                                select: [g.role, g.episode_id, g.persona_id, count(g.persona_id)],
                                having: count(g.persona_id) > 1)
                 |> Repo.all()

    for [role, episode_id, persona_id, count] <- duplicates do
      one_less = count - 1

      gig_ids = from(g in Gig, where: g.role == ^role and
                                      g.episode_id == ^episode_id and
                                      g.persona_id == ^persona_id,
                               limit: ^one_less,
                               order_by: [asc: g.inserted_at],
                               select: g.id)
                    |> Repo.all()

      from(g in Gig, where: g.id in ^gig_ids)
      |> Repo.delete_all()
    end

    render(conn, "remove_duplicates.html")
  end


  def convert_authors(conn, _params) do
    # eliminate Jane Doe
    from(e in Engagement, where: e.persona_id == 191)
    |> Repo.delete_all()

    from(g in Gig, where: g.persona_id == 191)
    |> Repo.delete_all()

    from(p in Persona, where: p.id == 191)
    |> Repo.delete_all()


    podcasts = Repo.all(Podcast)
    for podcast <- podcasts do
      Pan.Parser.Author.get_or_insert_into_podcast(podcast.author, podcast.id)
    end

    episodes = Repo.all(Episode)
               |> Repo.preload(:podcast)
    for episode <- episodes do
      Pan.Parser.Author.get_or_insert_into_episode(episode.author, episode, episode.podcast)
    end

    render(conn, "done.html")
  end
end
