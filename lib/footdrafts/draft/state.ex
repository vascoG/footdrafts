defmodule FootDrafts.Draft.State do
  @moduledoc """
  In-memory state for a single draft. Owned exclusively by a `FootDrafts.DraftRoom`
  GenServer (not built yet — that's the next PR) so there is a single source of
  truth per room and no race conditions between concurrent pick requests.

  `players` is loaded once when the draft starts (via `GameMode.pool/2` against
  the Football context) and never re-queried during the hot path. It intentionally
  carries the hidden `:rating` field — this struct never leaves the server process,
  so it's safe to hold the rating here. `GameMode.visible_fields/1` is what
  decides what actually gets serialized out to a LiveView.
  """

  @enforce_keys [:competition_scope, :squad_size, :turn_order]
  defstruct [
    :competition_scope,
    :squad_size,
    :turn_order,
    players: %{},
    participants: %{},
    pool: MapSet.new(),
    picks: [],
    status: :drafting
  ]

  @type player_id :: term()
  @type participant_id :: term()

  @type player :: %{
          required(:club_id) => term(),
          required(:rating) => number(),
          optional(atom()) => term()
        }

  @type participant :: %{seat: non_neg_integer(), squad: [player_id()]}

  @type pick :: %{participant_id: participant_id(), player_id: player_id(), round: pos_integer()}

  @type t :: %__MODULE__{
          competition_scope: :worldwide | term(),
          squad_size: pos_integer(),
          turn_order: [participant_id()],
          players: %{optional(player_id()) => player()},
          participants: %{optional(participant_id()) => participant()},
          pool: MapSet.t(player_id()),
          picks: [pick()],
          status: :drafting | :complete
        }

  @doc """
  Builds a fresh draft state for `participant_ids`, drawing the pool from
  `players` (already scoped) via the given game mode module.
  """
  @spec new(
          module(),
          :worldwide | term(),
          %{player_id() => player()},
          [participant_id()],
          pos_integer()
        ) ::
          t()
  def new(game_mode, competition_scope, players, participant_ids, squad_size) do
    pool_ids = game_mode.pool(competition_scope, players)

    participants =
      participant_ids
      |> Enum.with_index()
      |> Map.new(fn {id, seat} -> {id, %{seat: seat, squad: []}} end)

    %__MODULE__{
      competition_scope: competition_scope,
      squad_size: squad_size,
      turn_order: participant_ids,
      players: Map.take(players, pool_ids),
      participants: participants,
      pool: MapSet.new(pool_ids)
    }
  end

  @doc "Whose turn it is, based on picks made so far and the fixed turn order."
  @spec current_turn(t()) :: participant_id()
  def current_turn(%__MODULE__{turn_order: order, picks: picks}) do
    Enum.at(order, rem(length(picks), length(order)))
  end
end
