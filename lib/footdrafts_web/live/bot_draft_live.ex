defmodule FootDraftsWeb.BotDraftLive do
  use FootDraftsWeb, :live_view

  alias FootDrafts.{BotStrategy, Draft.State, Football}
  alias FootDrafts.GameModes.Normal

  @squad_size 5
  @participants [:human, :bot]
  @bot_delay_min_ms 1_000
  @bot_delay_max_ms 3_000
  @position_order ["Goalkeeper", "Defender", "Midfielder", "Forward"]
  @position_pool_sizes %{
    "Goalkeeper" => 4,
    "Defender" => 4,
    "Midfielder" => 8,
    "Forward" => 4
  }

  @type difficulty :: :easy | :medium | :hard

  @impl true
  def mount(params, _session, socket) do
    difficulty = parse_difficulty(Map.get(params, "difficulty"))

    socket =
      socket
      |> assign(:page_title, "Bot Draft")
      |> assign(:squad_size, @squad_size)
      |> assign(:difficulty, difficulty)
      |> assign(:bot_thinking?, false)
      |> assign(:outcome, nil)
      |> assign(:status_message, "Your turn. Pick your first player.")

    socket =
      if connected?(socket) do
        assign(socket, :state, new_draft_state())
      else
        assign(socket, :state, empty_draft_state())
      end

    {:ok, socket}
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
                  delay_ms = bot_delay_ms()
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

            <div class="mt-3 space-y-2" id="human-squad-list">
              <div :for={{position, players} <- squad_by_position(@state, :human)}>
                <p class="text-xs font-semibold uppercase tracking-[0.1em] text-[#294132]/60">
                  {position} ({length(players)}/{position_slot_count(position)})
                </p>

                <ul class="ml-2 text-sm text-[#243c2d]">
                  <li :for={player <- players}>{player.name}</li>
                </ul>
              </div>
            </div>
          </article>

          <article class="rounded-xl bg-[#fff4e5] p-4" id="bot-panel">
            <h2 class="text-xs font-semibold uppercase tracking-[0.16em] text-[#7a4710]/80">Bot</h2>

            <p class="mt-2 text-2xl font-bold text-[#54300e]">
              {squad_size(@state, :bot)} / {@squad_size}
            </p>

            <div class="mt-3 space-y-2" id="bot-squad-list">
              <div :for={{position, players} <- squad_by_position(@state, :bot)}>
                <p class="text-xs font-semibold uppercase tracking-[0.1em] text-[#7a4710]/60">
                  {position} ({length(players)}/{position_slot_count(position)})
                </p>

                <ul class="ml-2 text-sm text-[#704318]">
                  <li :for={player <- players}>{player.name}</li>
                </ul>
              </div>
            </div>
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

          <div :for={{position, players} <- pool_players_by_position(@state)} class="mb-4">
            <h3 class="mb-2 text-xs font-semibold uppercase tracking-[0.14em] text-[#294132]/70">
              {position}
            </h3>

            <ul class="grid gap-3" id={"available-player-list-#{position}"}>
              <li
                :for={player <- players}
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
                    @bot_thinking? or @state.status == :complete or
                      State.current_turn(@state) != :human or
                      position_full?(@state, :human, player.position) or
                      club_already_picked?(@state, :human, player.club_name)
                  }
                  class="inline-flex items-center justify-center rounded-xl bg-[#1f2f26] px-4 py-2 text-sm font-semibold text-white transition hover:bg-[#132019] disabled:cursor-not-allowed disabled:bg-[#6e7d73]"
                >
                  Pick
                </button>
              </li>
            </ul>
          </div>
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

  defp empty_draft_state do
    State.new(Normal, :worldwide, %{}, @participants, @squad_size)
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

  defp bot_delay_ms do
    Enum.random(@bot_delay_min_ms..@bot_delay_max_ms)
  end

  defp pick_error_message(:not_your_turn), do: "It is not your turn."
  defp pick_error_message(:player_not_available), do: "That player is no longer available."
  defp pick_error_message(:club_already_drafted), do: "You already drafted a player from that club."
  defp pick_error_message(:position_full), do: "You already filled that position."
  defp pick_error_message(:unknown_position), do: "That player has an unrecognized position."
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

  @position_order ["Goalkeeper", "Defender", "Midfielder", "Forward"]

  defp position_slot_count(position), do: Map.fetch!(Normal.position_requirements(), position)

  defp squad_by_position(state, participant_id) do
    players = squad_players(state, participant_id)

    Enum.map(@position_order, fn position ->
      {position, Enum.filter(players, &(&1.position == position))}
    end)
  end

  defp pool_players_by_position(state) do
    players = pool_players(state)

    @position_order
    |> Enum.map(fn position -> {position, Enum.filter(players, &(&1.position == position))} end)
    |> Enum.reject(fn {_position, players} -> players == [] end)
  end

  defp position_full?(state, participant_id, position) do
    requirement = position_slot_count(position)

    taken =
      state.participants
      |> Map.fetch!(participant_id)
      |> Map.fetch!(:squad)
      |> Enum.count(fn player_id ->
        state.players |> Map.fetch!(player_id) |> Map.fetch!(:position) == position
      end)

    taken >= requirement
  end

  defp club_already_picked?(state, participant_id, club_name) do
    state.participants
    |> Map.fetch!(participant_id)
    |> Map.fetch!(:squad)
    |> Enum.any?(fn player_id ->
      state.players |> Map.fetch!(player_id) |> Map.fetch!(:club_name) == club_name
    end)
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
      players -> players
    end
    |> sample_players_by_position()
    |> Map.new(fn player -> {player.id, player} end)
  end

  # Pulls a fixed number of players per position (4 for Goalkeeper/Defender/
  # Forward, 8 for Midfielder) at random from the full normalized player list.
  # We explicitly enforce club diversity within the sampled pool
  # to prevent participants from getting deadlocked with no available picks.
  defp sample_players_by_position(players) do
    shuffled_players = Enum.shuffle(players)
    by_position = Enum.group_by(shuffled_players, & &1.position)

    Enum.flat_map(@position_pool_sizes, fn {position, count} ->
      by_position
      |> Map.get(position, [])
      # Take players with unique clubs first to maximize diversity
      |> Enum.uniq_by(& &1.club_id)
      |> Enum.take(count)
      # Fallback: If a position doesn't have enough unique clubs to meet the count,
      # we pad it back out with the remaining shuffled players of that position.
      |> pad_pool_if_needed(Map.get(by_position, position, []), count)
    end)
  end

  # Helper to ensure we always return the exact count required,
  # even if it means duplicating clubs when unique ones run out.
  defp pad_pool_if_needed(sampled, _all_position_players, count) when length(sampled) >= count, do: sampled
  defp pad_pool_if_needed(sampled, all_position_players, count) do
    remaining = all_position_players -- sampled
    sampled ++ Enum.take(remaining, count - length(sampled))
  end

  defp normalize_db_players(players) do
    current_season = Integer.to_string(Date.utc_today().year)

    Enum.map(players, fn player ->
      rating =
        case Football.hidden_rating_for(player.id, current_season) do
          %Decimal{} = value -> Decimal.to_float(value)
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

end
