defmodule PanWeb.Category do
  use Pan.Web, :model
  alias Pan.Repo
  alias PanWeb.{Category, Follow, Like}

  schema "categories" do
    field(:title, :string)
    field(:elastic, :boolean)

    has_many(:children, PanWeb.Category, foreign_key: :parent_id)

    belongs_to(:parent, PanWeb.Category)

    many_to_many(:podcasts, PanWeb.Podcast,
      join_through: "categories_podcasts",
      on_replace: :delete
    )

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:title, :parent_id, :elastic])
    |> validate_required([:title])
  end

  def like(category_id, user_id) do
    like =
      Repo.get_by(Like,
        enjoyer_id: user_id,
        category_id: category_id
      )

    case like do
      nil ->
        %Like{enjoyer_id: user_id, category_id: category_id}
        |> Repo.insert()

      like ->
        {:ok, Repo.delete!(like)}
    end
  end

  def follow(category_id, user_id) do
    follow =
      Repo.get_by(Follow,
        follower_id: user_id,
        category_id: category_id
      )

    case follow do
      nil ->
        %Follow{follower_id: user_id, category_id: category_id}
        |> Repo.insert()

      follow ->
        {:ok, Repo.delete!(follow)}
    end
  end

  def follower_mailboxes(category_id) do
    from(l in Follow,
      where: l.category_id == ^category_id,
      select: [:follower_id]
    )
    |> Repo.all()
    |> Enum.map(fn user -> "mailboxes:" <> Integer.to_string(user.follower_id) end)
  end

  def likes(id) do
    from(l in Like, where: l.category_id == ^id)
    |> Repo.aggregate(:count)
    |> Integer.to_string()
  end

  def follows(id) do
    from(l in Follow, where: l.category_id == ^id)
    |> Repo.aggregate(:count)
    |> Integer.to_string()
  end

  def update_search_index(id) do
    category = Repo.get(Category, id)

    put(
      "/panoptikum_" <>
        Application.get_env(:pan, :environment) <>
        "/categories/" <> Integer.to_string(id),
      title: category.title,
      url: category_frontend_path(PanWeb.Endpoint, :show, id)
    )
  end

  def delete_search_index(id) do
    delete(
      "http://127.0.0.1:9200/panoptikum_" <>
        Application.get_env(:pan, :environment) <>
        "/categories/" <> Integer.to_string(id)
    )
  end

  def delete_search_index_orphans() do
    category_ids =
      from(c in Category, select: c.id)
      |> Repo.all()

    max_category_id = Enum.max(category_ids)

    all_ids =
      Range.new(1, max_category_id)
      |> Enum.to_list()

    deleted_ids = all_ids -- category_ids

    for deleted_id <- deleted_ids, do: delete_search_index(deleted_id)
  end
end
