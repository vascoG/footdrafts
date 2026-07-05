defmodule FootDraftsWeb.BotDraftLiveTest do
  use FootDraftsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "renders bot draft page", %{conn: conn} do
    {:ok, _view, html} = live(conn, ~p"/play/bot")

    assert html =~ "Play Against Bot"
    assert html =~ "Available Players"
    assert html =~ "Your turn"
  end

  test "human pick also triggers bot pick", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/play/bot")

    view
    |> element("#pick-player-101")
    |> render_click()

    assert has_element?(view, "#human-squad-list li")
    assert has_element?(view, "#bot-squad-list li")
    assert render(view) =~ "Players available: 14"
  end
end
