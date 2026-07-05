defmodule FootDraftsWeb.BotDraftLiveTest do
  use FootDraftsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "renders bot draft page", %{conn: conn} do
    {:ok, _view, html} = live(conn, ~p"/play/bot")

    assert html =~ "Play Against Bot"
    assert html =~ "Available Players"
    assert html =~ "Difficulty"
  end

  test "human pick schedules delayed bot pick", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/play/bot?bot_delay_ms=5000")

    view
    |> element("#pick-player-101")
    |> render_click()

    assert render(view) =~ "Bot is thinking"
    refute has_element?(view, "#bot-squad-list li")

    send(view.pid, :bot_turn)

    assert has_element?(view, "#bot-squad-list li")
    assert render(view) =~ "Your turn. Pick the next player"
  end

  test "hard difficulty takes the top legal pick", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/play/bot?difficulty=hard&bot_delay_ms=5000")

    view
    |> element("#pick-player-101")
    |> render_click()

    send(view.pid, :bot_turn)

    assert render(view) =~ "Jonas Silva"
  end

  test "difficulty change resets the draft", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/play/bot?bot_delay_ms=5000")

    view
    |> element("#pick-player-101")
    |> render_click()

    send(view.pid, :bot_turn)

    assert has_element?(view, "#human-squad-list li")

    view
    |> element("#difficulty-easy")
    |> render_click()

    refute has_element?(view, "#human-squad-list li")
    assert render(view) =~ "Difficulty: EASY"
    assert render(view) =~ "Your turn. Pick your first player"
  end
end
