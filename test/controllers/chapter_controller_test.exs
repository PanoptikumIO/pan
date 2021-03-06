defmodule Pan.ChapterControllerTest do
  use PanWeb.ConnCase

  describe "when user is logged in and is an admin" do
    setup do
      admin = insert_admin_user()
      conn = assign(build_conn(), :current_user, admin)
      {:ok, conn: conn}
    end

    alias PanWeb.Chapter
    @valid_attrs %{start: "some content", title: "some content"}
    @invalid_attrs %{}

    test "lists all entries on index", %{conn: conn} do
      conn = get(conn, chapter_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing chapters"
    end

    test "renders form for new resources", %{conn: conn} do
      conn = get(conn, chapter_path(conn, :new))
      assert html_response(conn, 200) =~ "New chapter"
    end

    test "creates resource and redirects when data is valid", %{conn: conn} do
      conn = post(conn, chapter_path(conn, :create), chapter: @valid_attrs)
      assert redirected_to(conn) == chapter_path(conn, :index)
      assert Repo.get_by(Chapter, @valid_attrs)
    end

    test "does not create resource and renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, chapter_path(conn, :create), chapter: @invalid_attrs)
      assert html_response(conn, 200) =~ "New chapter"
    end

    test "shows chosen resource", %{conn: conn} do
      chapter = Repo.insert!(%Chapter{})
      conn = get(conn, chapter_path(conn, :show, chapter))
      assert html_response(conn, 200) =~ "Show chapter"
    end

    test "renders page not found when id is nonexistent", %{conn: conn} do
      assert_error_sent(404, fn ->
        get(conn, chapter_path(conn, :show, -1))
      end)
    end

    test "renders form for editing chosen resource", %{conn: conn} do
      chapter = Repo.insert!(%Chapter{})
      conn = get(conn, chapter_path(conn, :edit, chapter))
      assert html_response(conn, 200) =~ "Edit chapter"
    end

    test "updates chosen resource and redirects when data is valid", %{conn: conn} do
      chapter = Repo.insert!(%Chapter{})
      conn = put(conn, chapter_path(conn, :update, chapter), chapter: @valid_attrs)
      assert redirected_to(conn) == chapter_path(conn, :show, chapter)
      assert Repo.get_by(Chapter, @valid_attrs)
    end

    test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
      chapter = Repo.insert!(%Chapter{})
      conn = put(conn, chapter_path(conn, :update, chapter), chapter: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit chapter"
    end

    test "deletes chosen resource", %{conn: conn} do
      chapter = Repo.insert!(%Chapter{})
      conn = delete(conn, chapter_path(conn, :delete, chapter))
      assert redirected_to(conn) == chapter_path(conn, :index)
      refute Repo.get(Chapter, chapter.id)
    end
  end

  test "requires admin authentication on all actions", %{conn: conn} do
    Enum.each(
      [
        get(conn, chapter_path(conn, :new)),
        get(conn, chapter_path(conn, :index)),
        get(conn, chapter_path(conn, :show, "123")),
        get(conn, chapter_path(conn, :edit, "123")),
        put(conn, chapter_path(conn, :update, "123")),
        post(conn, chapter_path(conn, :create, %{})),
        delete(conn, chapter_path(conn, :delete, "123"))
      ],
      fn conn ->
        assert html_response(conn, 302)
        assert conn.halted
      end
    )
  end
end
