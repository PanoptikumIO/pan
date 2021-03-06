defmodule Pan.LikeControllerTest do
  use PanWeb.ConnCase

  describe "when user is logged in and is an admin" do
    setup do
      admin = insert_admin_user()
      conn = assign(build_conn(), :current_user, admin)
      {:ok, conn: conn}
    end

    alias PanWeb.Like
    @invalid_attrs %{}

    test "lists all entries on index", %{conn: conn} do
      conn = get(conn, like_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing likes"
    end

    test "renders form for new resources", %{conn: conn} do
      conn = get(conn, like_path(conn, :new))
      assert html_response(conn, 200) =~ "New like"
    end

    test "creates resource and redirects when data is valid", %{conn: conn} do
      enjoyer = insert_user()
      podcast = insert_podcast()

      conn =
        post(conn, like_path(conn, :create),
          like: %{enjoyer_id: enjoyer.id, podcast_id: podcast.id}
        )

      assert redirected_to(conn) == like_path(conn, :index)
      assert Repo.get_by(Like, %{enjoyer_id: enjoyer.id, podcast_id: podcast.id})
    end

    test "does not create resource and renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, like_path(conn, :create), like: @invalid_attrs)
      assert html_response(conn, 200) =~ "New like"
    end

    test "shows chosen resource", %{conn: conn} do
      like = Repo.insert!(%Like{})
      conn = get(conn, like_path(conn, :show, like))
      assert html_response(conn, 200) =~ "Show like"
    end

    test "renders page not found when id is nonexistent", %{conn: conn} do
      assert_error_sent(
        404,
        fn ->
          get(conn, like_path(conn, :show, -1))
        end
      )
    end

    test "renders form for editing chosen resource", %{conn: conn} do
      like = Repo.insert!(%Like{})
      conn = get(conn, like_path(conn, :edit, like))
      assert html_response(conn, 200) =~ "Edit like"
    end

    test "updates chosen resource and redirects when data is valid", %{conn: conn} do
      enjoyer = insert_user()
      podcast = insert_podcast()

      like = Repo.insert!(%Like{})

      conn =
        put(conn, like_path(conn, :update, like),
          like: %{enjoyer_id: enjoyer.id, podcast_id: podcast.id}
        )

      assert redirected_to(conn) == like_path(conn, :show, like)
      assert Repo.get_by(Like, %{enjoyer_id: enjoyer.id, podcast_id: podcast.id})
    end

    test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
      like = Repo.insert!(%Like{})
      conn = put(conn, like_path(conn, :update, like), like: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit like"
    end

    test "deletes chosen resource", %{conn: conn} do
      like = Repo.insert!(%Like{})
      conn = delete(conn, like_path(conn, :delete, like))
      assert redirected_to(conn) == like_path(conn, :index)
      refute Repo.get(Like, like.id)
    end
  end

  test "requires admin authentication on all actions", %{conn: conn} do
    Enum.each(
      [
        get(conn, like_path(conn, :new)),
        get(conn, like_path(conn, :index)),
        get(conn, like_path(conn, :show, "123")),
        get(conn, like_path(conn, :edit, "123")),
        put(conn, like_path(conn, :update, "123")),
        post(conn, like_path(conn, :create, %{})),
        delete(conn, like_path(conn, :delete, "123"))
      ],
      fn conn ->
        assert html_response(conn, 302)
        assert conn.halted
      end
    )
  end
end
