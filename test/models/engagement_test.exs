defmodule Pan.EngagementTest do
  use Pan.ModelCase

  alias Pan.Engagement

  @valid_attrs %{comment: "some content", from: %{day: 17, month: 4, year: 2010}, role: "some content", until: %{day: 17, month: 4, year: 2010}}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Engagement.changeset(%Engagement{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Engagement.changeset(%Engagement{}, @invalid_attrs)
    refute changeset.valid?
  end
end