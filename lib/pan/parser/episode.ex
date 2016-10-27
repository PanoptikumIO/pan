defmodule Pan.Parser.Episode do
  use Pan.Web, :controller

  def find_or_create(episode_map, podcast_id) do
    Map.put_new(episode_map, :guid, episode_map[:link])

    case Repo.get_by(Pan.Episode, guid: episode_map[:guid],
                                  link: episode_map[:link]) do
      nil ->
        %Pan.Episode{podcast_id: podcast_id}
        |> Map.merge(episode_map)
        |> Repo.insert()
      episode ->
        {:ok, episode}
    end
  end


  def persist_many(episodes_map, podcast) do
    for {_, episode_map} <- episodes_map do
      plain_episode_map = Map.drop(episode_map, [:chapters, :enclosures, :contributors])
      {:ok, episode} = find_or_create(plain_episode_map, podcast.id)

      for {_, chapter_map} <- episode_map[:chapters] do
        Pan.Parser.Chapter.find_or_create(chapter_map, episode.id)
      end

      for {_, enclosure_map} <- episode_map[:enclosures] do
        Pan.Parser.Enclosure.find_or_create(enclosure_map, episode.id)
      end

      Pan.Parser.Contributor.persist_many(episode_map[:contributors], episode)
    end
  end
end