defmodule Pan.RecommendationControllerTest do
  use PanWeb.ConnCase

  describe "when user is logged in and is an admin" do
    setup do
      admin = insert_admin_user()
      conn = assign(build_conn(), :current_user, admin)
      {:ok, conn: conn}
    end

    alias PanWeb.Recommendation
    @valid_attrs %{comment: "some content"}
    @invalid_attrs %{}

    test "lists all entries on index", %{conn: conn} do
      conn = get(conn, recommendation_path(conn, :index))
      assert html_response(conn, 200) =~ "Recommendations"
    end

    test "renders form for new resources", %{conn: conn} do
      conn = get(conn, recommendation_path(conn, :new))
      assert html_response(conn, 200) =~ "New recommendation"
    end

    test "creates resource and redirects when data is valid", %{conn: conn} do
      conn = post(conn, recommendation_path(conn, :create), recommendation: @valid_attrs)
      assert redirected_to(conn) == recommendation_path(conn, :index)
      assert Repo.get_by(Recommendation, @valid_attrs)
    end

    test "does not create resource and renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, recommendation_path(conn, :create), recommendation: @invalid_attrs)
      assert html_response(conn, 200) =~ "New recommendation"
    end

    test "shows chosen resource", %{conn: conn} do
      recommendation = Repo.insert!(%Recommendation{})
      conn = get(conn, recommendation_path(conn, :show, recommendation))
      assert html_response(conn, 200) =~ "Show recommendation"
    end

    test "renders page not found when id is nonexistent", %{conn: conn} do
      assert_error_sent(404, fn ->
        get(conn, recommendation_path(conn, :show, -1))
      end)
    end

    test "renders form for editing chosen resource", %{conn: conn} do
      recommendation = Repo.insert!(%Recommendation{})
      conn = get(conn, recommendation_path(conn, :edit, recommendation))
      assert html_response(conn, 200) =~ "Edit recommendation"
    end

    test "updates chosen resource and redirects when data is valid", %{conn: conn} do
      recommendation = Repo.insert!(%Recommendation{})

      conn =
        put(conn, recommendation_path(conn, :update, recommendation), recommendation: @valid_attrs)

      assert redirected_to(conn) == recommendation_path(conn, :show, recommendation)
      assert Repo.get_by(Recommendation, @valid_attrs)
    end

    test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
      recommendation = Repo.insert!(%Recommendation{})

      conn =
        put(conn, recommendation_path(conn, :update, recommendation),
          recommendation: @invalid_attrs
        )

      assert html_response(conn, 200) =~ "Edit recommendation"
    end

    test "deletes chosen resource", %{conn: conn} do
      recommendation = Repo.insert!(%Recommendation{})
      conn = delete(conn, recommendation_path(conn, :delete, recommendation))
      assert redirected_to(conn) == recommendation_path(conn, :index)
      refute Repo.get(Recommendation, recommendation.id)
    end
  end

  test "requires admin authentication on all actions", %{conn: conn} do
    Enum.each(
      [
        get(conn, recommendation_path(conn, :new)),
        get(conn, recommendation_path(conn, :index)),
        get(conn, recommendation_path(conn, :show, "123")),
        get(conn, recommendation_path(conn, :edit, "123")),
        put(conn, recommendation_path(conn, :update, "123")),
        post(conn, recommendation_path(conn, :create, %{})),
        delete(conn, recommendation_path(conn, :delete, "123"))
      ],
      fn conn ->
        assert html_response(conn, 302)
        assert conn.halted
      end
    )
  end
end
