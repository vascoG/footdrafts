defmodule FootDraftsWeb.BotDraftLive do
  use FootDraftsWeb, :live_view

  alias FootDrafts.{BotStrategy, Draft.State, Football}
  alias FootDrafts.GameModes.Normal

  @squad_size 5
  @participants [:human, :bot]
  @bot_delay_min_ms 1_000
  @bot_delay_max_ms 3_000

  @type difficulty :: :easy | :medium | :hard

  @impl true
  def mount(params, _session, socket) do
    difficulty = parse_difficulty(Map.get(params, "difficulty"))
    delay_override_ms = parse_delay_override(Map.get(params, "bot_delay_ms"))
    state = new_draft_state()

    {:ok,
     socket
     |> assign(:page_title, "Bot Draft")
     |> assign(:squad_size, @squad_size)
     |> assign(:difficulty, difficulty)
     |> assign(:delay_override_ms, delay_override_ms)
     |> assign(:state, state)
     |> assign(:bot_thinking?, false)
     |> assign(:outcome, nil)
     |> assign(:status_message, "Your turn. Pick your first player.")}
  end

  @impl true
  def handle_event("pick", %{"id" => id}, socket) do
    cond do
      socket.assigns.bot_thinking? ->
        {:noreply, socket}

      socket.assigns.state.status == :complete ->
        {:noreply, socket}

      true ->
        case Integer.parse(id) do
          {player_id, ""} ->
            case apply_legal_pick(socket.assigns.state, :human, player_id) do
              {:ok, state_after_human} ->
                if state_after_human.status == :complete do
                  {:noreply,
                   socket
                   |> assign(:state, state_after_human)
                   |> finalize_outcome(state_after_human)}
                else
                  delay_ms = bot_delay_ms(socket)
                  Process.send_after(self(), :bot_turn, delay_ms)

                  {:noreply,
                   socket
                   |> assign(:state, state_after_human)
                   |> assign(:bot_thinking?, true)
                   |> assign(:status_message, "Bot is thinking...")}
                end

              {:error, reason} ->
                {:noreply, put_flash(socket, :error, pick_error_message(reason))}
            end

          _ ->
            {:noreply, put_flash(socket, :error, "Invalid player id.")}
        end
    end
  end

  def handle_event("set_difficulty", %{"level" => difficulty}, socket) do
    parsed_difficulty = parse_difficulty(difficulty)
    state = new_draft_state()

    {:noreply,
     socket
     |> assign(:difficulty, parsed_difficulty)
     |> assign(:state, state)
     |> assign(:bot_thinking?, false)
     |> assign(:outcome, nil)
     |> assign(:status_message, "Your turn. Pick your first player.")}
  end

  @impl true
  def handle_info(:bot_turn, socket) do
    if socket.assigns.state.status == :complete or not socket.assigns.bot_thinking? do
      {:noreply, socket}
    else
      legal_ids = legal_player_ids(socket.assigns.state, :bot)

      case BotStrategy.pick_player_id(
             legal_ids,
             socket.assigns.state.players,
             socket.assigns.difficulty
           ) do
        nil ->
          {:noreply,
           socket
           |> assign(:bot_thinking?, false)
           |> assign(:status_message, "Bot has no legal picks left. Start a new draft.")}

        player_id ->
          {:ok, state_after_bot} = apply_legal_pick(socket.assigns.state, :bot, player_id)

          if state_after_bot.status == :complete do
            {:noreply,
             socket
             |> assign(:state, state_after_bot)
             |> assign(:bot_thinking?, false)
             |> finalize_outcome(state_after_bot)}
          else
            {:noreply,
             socket
             |> assign(:state, state_after_bot)
             |> assign(:bot_thinking?, false)
             |> assign(:status_message, "Your turn. Pick the next player.")}
          end
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
            Draft five players. Bot picks are legal, delayed, and driven by hidden rating difficulty.
          </p>

          <div class="mt-4 flex flex-wrap gap-2" id="difficulty-picker">
            <button
              id="difficulty-easy"
              phx-click="set_difficulty"
              phx-value-level="easy"
              class={difficulty_button_classes(@difficulty, :easy)}
            >
              Easy
            </button>

            <button
              id="difficulty-medium"
              phx-click="set_difficulty"
              phx-value-level="medium"
              class={difficulty_button_classes(@difficulty, :medium)}
            >
              Medium
            </button>

            <button
              id="difficulty-hard"
              phx-click="set_difficulty"
              phx-value-level="hard"
              class={difficulty_button_classes(@difficulty, :hard)}
            >
              Hard
            </button>
          </div>
        </header>

        <div class="grid gap-4 rounded-2xl border border-[#1f2f26]/10 bg-white p-4 shadow-sm sm:grid-cols-3">
          <article class="rounded-xl bg-[#eef6e8] p-4" id="human-panel">
            <h2 class="text-xs font-semibold uppercase tracking-[0.16em] text-[#294132]/80">You</h2>

            <p class="mt-2 text-2xl font-bold text-[#122117]">
              {squad_size(@state, :human)} / {@squad_size}
            </p>

            <ul class="mt-3 space-y-1 text-sm text-[#243c2d]" id="human-squad-list">
              <li :for={player <- squad_players(@state, :human)}>
                {player.name} - {player.position}
              </li>
            </ul>
          </article>

          <article class="rounded-xl bg-[#fff4e5] p-4" id="bot-panel">
            <h2 class="text-xs font-semibold uppercase tracking-[0.16em] text-[#7a4710]/80">Bot</h2>

            <p class="mt-2 text-2xl font-bold text-[#54300e]">
              {squad_size(@state, :bot)} / {@squad_size}
            </p>

            <ul class="mt-3 space-y-1 text-sm text-[#704318]" id="bot-squad-list">
              <li :for={player <- squad_players(@state, :bot)}>{player.name} - {player.position}</li>
            </ul>
          </article>

          <article class="rounded-xl border border-dashed border-[#1f2f26]/20 p-4" id="status-panel">
            <h2 class="text-xs font-semibold uppercase tracking-[0.16em] text-[#294132]/80">
              Status
            </h2>

            <p class="mt-2 text-sm text-[#243c2d]">{@status_message}</p>

            <p class="mt-2 text-sm text-[#243c2d]">Players available: {MapSet.size(@state.pool)}</p>

            <p class="mt-2 text-xs uppercase tracking-[0.14em] text-[#294132]/70">
              Difficulty: {String.upcase(to_string(@difficulty))}
            </p>
          </article>
        </div>

        <section
          :if={@outcome}
          class="rounded-2xl border border-[#1f2f26]/20 bg-[#f5fbef] p-4 text-sm text-[#122117]"
          id="outcome-panel"
        >
          <h2 class="font-semibold">Draft Outcome</h2>

          <p class="mt-2">Winner: {winner_label(@outcome.winner)}</p>

          <p class="mt-1">Your score: {score_for(@outcome.scores, :human)}</p>

          <p class="mt-1">Bot score: {score_for(@outcome.scores, :bot)}</p>
        </section>

        <section class="rounded-3xl border border-[#1f2f26]/10 bg-white p-4 shadow-sm">
          <div class="mb-3 flex items-center justify-between">
            <h2 class="font-semibold text-[#18251c]">Available Players</h2>

            <span class="text-xs uppercase tracking-[0.16em] text-[#294132]/80">Fake data ready</span>
          </div>

          <ul class="grid gap-3" id="available-player-list">
            <li
              :for={player <- pool_players(@state)}
              class="flex flex-col gap-3 rounded-2xl border border-[#1f2f26]/10 bg-[#fdfefb] p-4 sm:flex-row sm:items-center sm:justify-between"
            >
              <div>
                <p class="font-semibold text-[#122117]">{player.name}</p>

                <p class="text-sm text-[#294132]/80">
                  {player.position} - {player.club_name} - {player.nationality}
                </p>
              </div>

              <button
                id={"pick-player-#{player.id}"}
                data-player-id={player.id}
                phx-click="pick"
                phx-value-id={player.id}
                disabled={
                  @bot_thinking? or @state.status == :complete or State.current_turn(@state) != :human
                }
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

  defp difficulty_button_classes(active_difficulty, button_difficulty) do
    base =
      "rounded-xl px-3 py-1.5 text-xs font-semibold uppercase tracking-[0.14em] transition border"

    if active_difficulty == button_difficulty do
      base <> " border-[#1b2b22] bg-[#1f2f26] text-white"
    else
      base <> " border-[#1b2b22]/25 bg-white text-[#1b2b22] hover:border-[#1b2b22]/40"
    end
  end

  defp new_draft_state do
    players = load_player_pool()
    State.new(Normal, :worldwide, players, @participants, @squad_size)
  end

  defp apply_legal_pick(state, participant_id, player_id) do
    with :ok <- Normal.validate_pick(state, participant_id, player_id) do
      {:ok, Normal.apply_pick(state, participant_id, player_id)}
    end
  end

  defp legal_player_ids(state, participant_id) do
    state.pool
    |> Enum.filter(fn player_id ->
      Normal.validate_pick(state, participant_id, player_id) == :ok
    end)
  end

  defp finalize_outcome(socket, state) do
    outcome = Normal.outcome(state)
    human_score = score_for(outcome.scores, :human)
    bot_score = score_for(outcome.scores, :bot)

    message =
      case outcome.winner do
        :human -> "Draft complete. You win #{human_score} to #{bot_score}."
        :bot -> "Draft complete. Bot wins #{bot_score} to #{human_score}."
        nil -> "Draft complete. It is a draw at #{human_score}."
      end

    socket
    |> assign(:outcome, outcome)
    |> assign(:status_message, message)
  end

  defp parse_difficulty("easy"), do: :easy
  defp parse_difficulty("hard"), do: :hard
  defp parse_difficulty(_), do: :medium

  defp parse_delay_override(nil), do: nil

  defp parse_delay_override(delay_ms) do
    case Integer.parse(delay_ms) do
      {value, ""} when value >= 0 -> value
      _ -> nil
    end
  end

  defp bot_delay_ms(socket) do
    socket.assigns.delay_override_ms || Enum.random(@bot_delay_min_ms..@bot_delay_max_ms)
  end

  defp pick_error_message(:not_your_turn), do: "It is not your turn."
  defp pick_error_message(:player_not_available), do: "That player is no longer available."

  defp pick_error_message(:club_already_drafted),
    do: "You already drafted a player from that club."

  defp pick_error_message(:draft_complete), do: "Draft is already complete."

  defp squad_size(state, participant_id) do
    state.participants
    |> Map.fetch!(participant_id)
    |> Map.fetch!(:squad)
    |> length()
  end

  defp squad_players(state, participant_id) do
    state.participants
    |> Map.fetch!(participant_id)
    |> Map.fetch!(:squad)
    |> Enum.map(fn player_id ->
      state.players
      |> Map.fetch!(player_id)
      |> Normal.visible_fields()
    end)
  end

  defp pool_players(state) do
    state.pool
    |> Enum.map(fn player_id ->
      state.players |> Map.fetch!(player_id) |> Normal.visible_fields()
    end)
    |> Enum.sort_by(& &1.name)
  end

  defp winner_label(:human), do: "You"
  defp winner_label(:bot), do: "Bot"
  defp winner_label(nil), do: "Draw"

  defp score_for(scores, participant_id) do
    scores
    |> Map.fetch!(participant_id)
    |> Float.round(2)
  end

  defp load_player_pool do
    Football.list_players(:worldwide)
    |> normalize_db_players()
    |> case do
      [] -> fake_players()
      players -> players
    end
    |> balanced_players_by_club(2)
    |> Map.new(fn player -> {player.id, player} end)
  end

  defp balanced_players_by_club(players, players_per_club) do
    players
    |> Enum.group_by(& &1.club_id)
    |> Enum.filter(fn {_club_id, club_players} -> length(club_players) >= players_per_club end)
    |> Enum.flat_map(fn {_club_id, club_players} ->
      club_players
      |> Enum.sort_by(& &1.name)
      |> Enum.take(players_per_club)
    end)
  end

  defp normalize_db_players(players) do
    current_season = Integer.to_string(Date.utc_today().year)

    Enum.map(players, fn player ->
      rating =
        case Football.hidden_rating_for(player.id, current_season) do
          %Decimal{} = value -> Decimal.to_float(value)
          _ -> fallback_rating(player.id)
        end

      %{
        id: player.id,
        name: player.name,
        position: player.position || "Unknown",
        club_id: player.club_id,
        club_name: (player.club && player.club.name) || "Unknown Club",
        nationality: player.nationality || "Unknown",
        competition_id: competition_id_for(player),
        rating: rating
      }
    end)
  end

  defp competition_id_for(player) do
    cond do
      player.competition && player.competition.id -> player.competition.id
      player.club && player.club.competition_id -> player.club.competition_id
      true -> nil
    end
  end

  defp fallback_rating(player_id), do: 65 + rem(player_id * 11, 32)

  defp fake_players do
    [
      %{
        id: 101,
        name: "Mateo Ruiz",
        position: "Goalkeeper",
        club_id: 201,
        club_name: "Valencia Blue",
        nationality: "Spain",
        competition_id: 1,
        rating: 88.0
      },
      %{
        id: 117,
        name: "Ivan Kolar",
        position: "Defender",
        club_id: 201,
        club_name: "Valencia Blue",
        nationality: "Croatia",
        competition_id: 1,
        rating: 82.0
      },
      %{
        id: 102,
        name: "Joao Mota",
        position: "Left Back",
        club_id: 202,
        club_name: "Lisbon Harbor",
        nationality: "Portugal",
        competition_id: 1,
        rating: 79.0
      },
      %{
        id: 110,
        name: "Rafael Duarte",
        position: "Left Wing",
        club_id: 202,
        club_name: "Lisbon Harbor",
        nationality: "Portugal",
        competition_id: 1,
        rating: 86.0
      },
      %{
        id: 103,
        name: "Luka Senic",
        position: "Center Back",
        club_id: 203,
        club_name: "Danube Athletic",
        nationality: "Croatia",
        competition_id: 1,
        rating: 85.0
      },
      %{
        id: 104,
        name: "Arthur Klein",
        position: "Center Back",
        club_id: 203,
        club_name: "Danube Athletic",
        nationality: "Germany",
        competition_id: 1,
        rating: 83.0
      },
      %{
        id: 106,
        name: "Noah Berg",
        position: "Defensive Midfielder",
        club_id: 204,
        club_name: "Stockholm IF",
        nationality: "Sweden",
        competition_id: 1,
        rating: 87.0
      },
      %{
        id: 107,
        name: "Ibrahim Yildiz",
        position: "Central Midfielder",
        club_id: 204,
        club_name: "Stockholm IF",
        nationality: "Turkey",
        competition_id: 1,
        rating: 90.0
      },
      %{
        id: 111,
        name: "Jonas Silva",
        position: "Right Wing",
        club_id: 205,
        club_name: "Santos Vista",
        nationality: "Brazil",
        competition_id: 1,
        rating: 92.0
      },
      %{
        id: 112,
        name: "Tariq Mansour",
        position: "Striker",
        club_id: 205,
        club_name: "Casablanca Stars",
        nationality: "Morocco",
        competition_id: 1,
        rating: 89.0
      }
    ]
  end
end
