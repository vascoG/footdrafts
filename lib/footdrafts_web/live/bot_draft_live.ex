defmodule FootDraftsWeb.BotDraftLive do
  use FootDraftsWeb, :live_view

  alias FootDrafts.Football

  @squad_size 5

  @impl true
  def mount(_params, _session, socket) do
    pool = load_player_pool()

    {:ok,
     socket
     |> assign(:page_title, "Bot Draft")
     |> assign(:squad_size, @squad_size)
     |> assign(:pool, pool)
     |> assign(:human_squad, [])
     |> assign(:bot_squad, [])
     |> assign(:draft_complete?, false)
     |> assign(:status_message, "Your turn. Pick your first player.")}
  end

  @impl true
  def handle_event("pick", %{"id" => id}, socket) do
    if socket.assigns.draft_complete? do
      {:noreply, socket}
    else
      player_id = String.to_integer(id)

      case take_player(socket.assigns.pool, player_id) do
        {:ok, picked_player, pool_after_human} ->
          human_squad = socket.assigns.human_squad ++ [picked_player]

          {bot_squad, final_pool, status_message, draft_complete?} =
            run_bot_turn(human_squad, socket.assigns.bot_squad, pool_after_human)

          {:noreply,
           socket
           |> assign(:pool, final_pool)
           |> assign(:human_squad, human_squad)
           |> assign(:bot_squad, bot_squad)
           |> assign(:status_message, status_message)
           |> assign(:draft_complete?, draft_complete?)}

        :error ->
          {:noreply, put_flash(socket, :error, "That player is no longer available.")}
      end
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <section class="space-y-6" id="bot-draft-mode">
        <header class="rounded-3xl border border-[#1f2f26]/10 bg-gradient-to-br from-[#f8f8f2] to-[#e8f0dc] p-6 shadow-sm">
          <p class="text-xs font-semibold uppercase tracking-[0.22em] text-[#415944]">Game Mode</p>

          <h1 class="mt-2 font-[Trebuchet_MS] text-3xl font-bold text-[#18251c]">Play Against Bot</h1>

          <p class="mt-2 text-sm leading-relaxed text-[#294132]/80">
            Draft five players. The bot always picks the highest-value remaining player.
          </p>
        </header>

        <div class="grid gap-4 rounded-2xl border border-[#1f2f26]/10 bg-white p-4 shadow-sm sm:grid-cols-3">
          <article class="rounded-xl bg-[#eef6e8] p-4" id="human-panel">
            <h2 class="text-xs font-semibold uppercase tracking-[0.16em] text-[#294132]/80">You</h2>

            <p class="mt-2 text-2xl font-bold text-[#122117]">
              {length(@human_squad)} / {@squad_size}
            </p>

            <ul class="mt-3 space-y-1 text-sm text-[#243c2d]" id="human-squad-list">
              <li :for={player <- @human_squad}>{player.name} · {player.position}</li>
            </ul>
          </article>

          <article class="rounded-xl bg-[#fff4e5] p-4" id="bot-panel">
            <h2 class="text-xs font-semibold uppercase tracking-[0.16em] text-[#7a4710]/80">Bot</h2>

            <p class="mt-2 text-2xl font-bold text-[#54300e]">{length(@bot_squad)} / {@squad_size}</p>

            <ul class="mt-3 space-y-1 text-sm text-[#704318]" id="bot-squad-list">
              <li :for={player <- @bot_squad}>{player.name} · {player.position}</li>
            </ul>
          </article>

          <article class="rounded-xl border border-dashed border-[#1f2f26]/20 p-4" id="status-panel">
            <h2 class="text-xs font-semibold uppercase tracking-[0.16em] text-[#294132]/80">
              Status
            </h2>

            <p class="mt-2 text-sm text-[#243c2d]">{@status_message}</p>

            <p class="mt-2 text-sm text-[#243c2d]">Players available: {length(@pool)}</p>
          </article>
        </div>

        <section class="rounded-3xl border border-[#1f2f26]/10 bg-white p-4 shadow-sm">
          <div class="mb-3 flex items-center justify-between">
            <h2 class="font-semibold text-[#18251c]">Available Players</h2>

            <span class="text-xs uppercase tracking-[0.16em] text-[#294132]/80">Fake data ready</span>
          </div>

          <ul class="grid gap-3" id="available-player-list">
            <li
              :for={player <- @pool}
              class="flex flex-col gap-3 rounded-2xl border border-[#1f2f26]/10 bg-[#fdfefb] p-4 sm:flex-row sm:items-center sm:justify-between"
            >
              <div>
                <p class="font-semibold text-[#122117]">{player.name}</p>

                <p class="text-sm text-[#294132]/80">
                  {player.position} · {player.club_name} · {player.nationality}
                </p>
              </div>

              <button
                id={"pick-player-#{player.id}"}
                data-player-id={player.id}
                phx-click="pick"
                phx-value-id={player.id}
                disabled={@draft_complete?}
                class="inline-flex items-center justify-center rounded-xl bg-[#1f2f26] px-4 py-2 text-sm font-semibold text-white transition hover:bg-[#132019] disabled:cursor-not-allowed disabled:bg-[#6e7d73]"
              >
                Pick
              </button>
            </li>
          </ul>
        </section>
      </section>
    </Layouts.app>
    """
  end

  defp run_bot_turn(human_squad, bot_squad, pool) do
    cond do
      complete?(human_squad, bot_squad) ->
        {bot_squad, pool, winner_message(human_squad, bot_squad), true}

      length(bot_squad) >= @squad_size ->
        {bot_squad, pool, "Bot squad complete. Finish your picks.", false}

      true ->
        bot_pick = Enum.max_by(pool, & &1.bot_value)
        {:ok, picked_player, pool_after_bot} = take_player(pool, bot_pick.id)
        new_bot_squad = bot_squad ++ [picked_player]

        if complete?(human_squad, new_bot_squad) do
          {new_bot_squad, pool_after_bot, winner_message(human_squad, new_bot_squad), true}
        else
          {new_bot_squad, pool_after_bot, "Your turn. Pick the next player.", false}
        end
    end
  end

  defp complete?(human_squad, bot_squad) do
    length(human_squad) >= @squad_size and length(bot_squad) >= @squad_size
  end

  defp winner_message(human_squad, bot_squad) do
    human_score = average_score(human_squad)
    bot_score = average_score(bot_squad)

    cond do
      human_score > bot_score ->
        "Draft complete. You win #{Float.round(human_score, 2)} to #{Float.round(bot_score, 2)}."

      bot_score > human_score ->
        "Draft complete. Bot wins #{Float.round(bot_score, 2)} to #{Float.round(human_score, 2)}."

      true ->
        "Draft complete. It is a draw at #{Float.round(human_score, 2)}."
    end
  end

  defp average_score(players) do
    total = Enum.reduce(players, 0.0, fn player, acc -> acc + player.bot_value end)
    total / max(length(players), 1)
  end

  defp take_player(pool, player_id) do
    case Enum.split_with(pool, fn player -> player.id != player_id end) do
      {remaining, [picked_player]} -> {:ok, picked_player, remaining}
      _ -> :error
    end
  end

  defp load_player_pool do
    Football.list_players(:worldwide)
    |> normalize_pool()
    |> case do
      [] -> fake_pool()
      players -> players
    end
    |> Enum.take(16)
    |> Enum.sort_by(& &1.name)
  end

  defp normalize_pool(players) do
    Enum.map(players, fn player ->
      value = 65 + rem(player.id * 11, 32)

      %{
        id: player.id,
        name: player.name,
        position: player.position || "Unknown",
        club_name: (player.club && player.club.name) || "Unknown Club",
        nationality: player.nationality || "Unknown",
        bot_value: value / 1.0
      }
    end)
  end

  defp fake_pool do
    [
      %{
        id: 101,
        name: "Mateo Ruiz",
        position: "Goalkeeper",
        club_name: "Valencia Blue",
        nationality: "Spain",
        bot_value: 88.0
      },
      %{
        id: 102,
        name: "Joao Mota",
        position: "Left Back",
        club_name: "Lisbon Harbor",
        nationality: "Portugal",
        bot_value: 79.0
      },
      %{
        id: 103,
        name: "Luka Senic",
        position: "Center Back",
        club_name: "Danube Athletic",
        nationality: "Croatia",
        bot_value: 85.0
      },
      %{
        id: 104,
        name: "Arthur Klein",
        position: "Center Back",
        club_name: "Rhine SC",
        nationality: "Germany",
        bot_value: 83.0
      },
      %{
        id: 105,
        name: "Pietro Nardi",
        position: "Right Back",
        club_name: "Torino Nord",
        nationality: "Italy",
        bot_value: 81.0
      },
      %{
        id: 106,
        name: "Noah Berg",
        position: "Defensive Midfielder",
        club_name: "Stockholm IF",
        nationality: "Sweden",
        bot_value: 87.0
      },
      %{
        id: 107,
        name: "Ibrahim Yildiz",
        position: "Central Midfielder",
        club_name: "Ankara Sun",
        nationality: "Turkey",
        bot_value: 90.0
      },
      %{
        id: 108,
        name: "Niko Petrov",
        position: "Central Midfielder",
        club_name: "Belgrade United",
        nationality: "Serbia",
        bot_value: 84.0
      },
      %{
        id: 109,
        name: "Leo Martin",
        position: "Attacking Midfielder",
        club_name: "Lyon Horizons",
        nationality: "France",
        bot_value: 91.0
      },
      %{
        id: 110,
        name: "Rafael Duarte",
        position: "Left Wing",
        club_name: "Porto Waves",
        nationality: "Portugal",
        bot_value: 86.0
      },
      %{
        id: 111,
        name: "Jonas Silva",
        position: "Right Wing",
        club_name: "Santos Vista",
        nationality: "Brazil",
        bot_value: 92.0
      },
      %{
        id: 112,
        name: "Tariq Mansour",
        position: "Striker",
        club_name: "Casablanca Stars",
        nationality: "Morocco",
        bot_value: 89.0
      },
      %{
        id: 113,
        name: "Ethan Cole",
        position: "Striker",
        club_name: "Bristol Albion",
        nationality: "England",
        bot_value: 80.0
      },
      %{
        id: 114,
        name: "Mika Ojala",
        position: "Right Wing",
        club_name: "Helsinki Forge",
        nationality: "Finland",
        bot_value: 78.0
      },
      %{
        id: 115,
        name: "Dusan Markic",
        position: "Left Wing",
        club_name: "Prague Crown",
        nationality: "Czechia",
        bot_value: 82.0
      },
      %{
        id: 116,
        name: "Bruno Costa",
        position: "Attacking Midfielder",
        club_name: "Madeira City",
        nationality: "Portugal",
        bot_value: 77.0
      }
    ]
  end
end
