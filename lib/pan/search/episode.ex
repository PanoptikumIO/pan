defmodule Pan.Search.Episode do
  import Ecto.Query, only: [from: 2]
  alias Pan.Repo
  alias PanWeb.Episode
  require Logger

  def batch_index do
    Pan.Search.batch_index(
      model: Episode,
      preloads: [podcast: [:languages, :categories]],
      selects: [
        :id,
        :title,
        :subtitle,
        :description,
        :summary,
        :shownotes,
        :inserted_at,
        :podcast_id,
        podcast: [:id, languages: :id, categories: :id]
      ],
      struct_function: &manticore_struct/1
    )
  end

  def manticore_struct(episode) do
    e = episode
    %{
      insert: %{
        index: "episodes",
        id: e.id,
        doc: %{
          title: e.title || "",
          subtitle: e.subtitle || "",
          description: e.description || "",
          summary: e.summary || "",
          shownotes: e.shownotes || "",
          inserted_at: to_unix(e.inserted_at),
          podcast_id: (e.podcast && e.podcast.id) || 0,
          language_ids: (e.podcast && Enum.map(e.podcast.languages, & &1.id)) || [],
          category_ids: (e.podcast && Enum.map(e.podcast.categories, & &1.id)) || []
        }
      }
    }
  end

  defp to_unix(naive) do
    {:ok, date_time} = DateTime.from_naive(naive, "Etc/UTC")
    DateTime.to_unix(date_time)
  end

  def batch_reset do
    Logger.info("=== full_text reset up to 10_000 episodes ===")

    episode_ids =
      from(e in Episode,
        where: e.full_text == true,
        select: e.id,
        limit: 10_000
      )
      |> Repo.all()

    from(e in Episode, where: e.id in ^episode_ids)
    |> Repo.update_all(set: [full_text: false])

    if length(episode_ids) > 0, do: batch_reset()
  end
end
