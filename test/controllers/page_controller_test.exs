defmodule Pan.PageControllerTest do
  use Pan.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "Panoptikum"
  end
end
