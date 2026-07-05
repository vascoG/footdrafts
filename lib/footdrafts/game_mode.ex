defmodule FootDrafts.GameMode do
  @moduledoc """
  Behaviour implemented by every draft mode.

  A `FootDrafts.DraftRoom` GenServer (next PR) is configured with one of these
  modules and never contains mode-specific logic itself — it just calls
  `validate_pick/3` before applying a pick, `apply_pick/3` to update state, and
  `outcome/1` once the draft is complete. This keeps Normal, Blind, Budget, and
  the Fearless series wrapper as isolated, independently-testable modules
  instead of branches inside the GenServer.

  Only `FootDrafts.GameModes.Normal` ships in this PR. Blind and Budget follow
  the same shape; Fearless wraps whichever base mode a series uses rather than
  being a fifth implementation (see the module doc on `GameModes.Normal`).
  """

  alias FootDrafts.Draft.State

  @doc """
  Returns the eligible player ids for this draft, given a scope
  (`:worldwide` or a competition id) and the full set of known players.
  Called once, when a room is created, to build the initial `State.pool`.
  """
  @callback pool(scope :: :worldwide | term(), players :: %{State.player_id() => State.player()}) ::
              [State.player_id()]

  @doc """
  Shapes a player for a specific draft client. Must never include the hidden
  `:rating` field — this is the one place that field could leak, so every
  mode implementation is expected to be deliberate about its allowlist rather
  than blocklisting fields.
  """
  @callback visible_fields(player :: State.player()) :: map()

  @doc """
  Validates whether `participant_id` may currently pick `player_id`. Called
  by the DraftRoom GenServer before `apply_pick/3` — never trust a client's
  own idea of whether a pick is legal.
  """
  @callback validate_pick(
              state :: State.t(),
              participant_id :: State.participant_id(),
              player_id :: State.player_id()
            ) ::
              :ok | {:error, atom()}

  @doc """
  Applies an already-validated pick, returning updated state. Split from
  `validate_pick/3` because some future modes (Budget) need to mutate more
  than just the squad/pool — e.g. deduct from a participant's budget — while
  reusing the same validation entry point.
  """
  @callback apply_pick(
              state :: State.t(),
              participant_id :: State.participant_id(),
              player_id :: State.player_id()
            ) ::
              State.t()

  @doc "Computes the match outcome once `state.status == :complete`."
  @callback outcome(state :: State.t()) :: %{winner: State.participant_id(), scores: map()}
end
