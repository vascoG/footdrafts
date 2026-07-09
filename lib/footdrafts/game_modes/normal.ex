defmodule FootDrafts.GameModes.Normal do
  @moduledoc """
  Normal draft: full player identity visible to both participants, pool
  scoped to `:worldwide` or a single competition, one player per real club,
  and a simple average-hidden-rating comparison decides the winner.

  This is the only mode in this PR. Blind and Budget will be siblings of this
  module implementing the same `FootDrafts.GameMode` behaviour — Blind swaps
  `visible_fields/1` to strip identity and expose a configurable stat subset
  instead, Budget adds a budget check to `validate_pick/3` and a deduction to
  `apply_pick/3`. Fearless (bo3/bo5) isn't a fifth mode: it's a wrapper that
  adds one extra `validate_pick/3` clause — "not already used earlier in the
  series" — around whichever base mode the series is running, backed by a
  `FootDrafts.Series` process that isn't part of this PR either.
  """

  @behaviour FootDrafts.GameMode

  alias FootDrafts.Draft.State

  @position_requirements %{
    "Goalkeeper" => 1,
    "Defender" => 1,
    "Midfielder" => 2,
    "Forward" => 1
  }

  @impl true
  def pool(:worldwide, players), do: Map.keys(players)

  def pool(competition_id, players) do
    players
    |> Enum.filter(fn {_id, player} -> player.competition_id == competition_id end)
    |> Enum.map(fn {id, _player} -> id end)
  end

  @impl true
  def visible_fields(player) do
    Map.take(player, [:id, :name, :position, :club_id, :club_name, :nationality, :competition_id])
  end

  @doc """
  Required count of each position per squad. Exposed publicly because both
  pick validation here and the initial pool-generation code (BotDraftLive)
  need to agree on it.
  """
  def position_requirements, do: @position_requirements

  @impl true
  def validate_pick(%State{status: :complete}, _participant_id, _player_id) do
    {:error, :draft_complete}
  end

  def validate_pick(%State{} = state, participant_id, player_id) do
    with :ok <- check_turn(state, participant_id),
         :ok <- check_available(state, player_id),
         :ok <- check_club_not_taken(state, participant_id, player_id),
         :ok <- check_position_slot_available(state, participant_id, player_id) do
      :ok
    end
  end

  @impl true
  def apply_pick(%State{} = state, participant_id, player_id) do
    participant = Map.fetch!(state.participants, participant_id)
    updated_participant = %{participant | squad: participant.squad ++ [player_id]}

    pick = %{participant_id: participant_id, player_id: player_id, round: length(state.picks) + 1}

    %{
      state
      | participants: Map.put(state.participants, participant_id, updated_participant),
        pool: MapSet.delete(state.pool, player_id),
        picks: state.picks ++ [pick]
    }
    |> maybe_complete()
  end

  @impl true
  def outcome(%State{status: :complete, participants: participants, players: players}) do
    scores =
      Map.new(participants, fn {participant_id, %{squad: squad}} ->
        {participant_id, squad_rating(squad, players)}
      end)

    max_score = scores |> Map.values() |> Enum.max()
    winners = for {id, score} <- scores, score == max_score, do: id

    winner = if length(winners) == 1, do: hd(winners), else: nil

    %{winner: winner, scores: scores}
  end

  # -- private --

  defp check_turn(state, participant_id) do
    if State.current_turn(state) == participant_id do
      :ok
    else
      {:error, :not_your_turn}
    end
  end

  defp check_available(%State{pool: pool}, player_id) do
    if MapSet.member?(pool, player_id), do: :ok, else: {:error, :player_not_available}
  end

  defp check_club_not_taken(
         %State{participants: participants, players: players},
         participant_id,
         player_id
       ) do
    %{club_id: incoming_club_id} = Map.fetch!(players, player_id)

    taken_clubs =
      participants
      |> Map.fetch!(participant_id)
      |> Map.fetch!(:squad)
      |> Enum.map(fn id -> players |> Map.fetch!(id) |> Map.fetch!(:club_id) end)

    if incoming_club_id in taken_clubs do
      {:error, :club_already_drafted}
    else
      :ok
    end
  end

  defp check_position_slot_available(
         %State{participants: participants, players: players},
         participant_id,
         player_id
       ) do
    %{position: incoming_position} = Map.fetch!(players, player_id)

    case Map.fetch(@position_requirements, incoming_position) do
      {:ok, allowed} ->
        taken =
          participants
          |> Map.fetch!(participant_id)
          |> Map.fetch!(:squad)
          |> Enum.count(fn id ->
            players |> Map.fetch!(id) |> Map.fetch!(:position) == incoming_position
          end)

        if taken < allowed do
          :ok
        else
          {:error, :position_full}
        end

      :error ->
        {:error, :unknown_position}
    end
  end

  defp maybe_complete(%State{squad_size: squad_size, participants: participants} = state) do
    if Enum.all?(participants, fn {_id, %{squad: squad}} -> length(squad) >= squad_size end) do
      %{state | status: :complete}
    else
      state
    end
  end

  defp squad_rating([], _players), do: 0.0

  defp squad_rating(squad, players) do
    ratings = Enum.map(squad, fn id -> players |> Map.fetch!(id) |> Map.fetch!(:rating) end)
    Enum.sum(ratings) / length(ratings)
  end
end
