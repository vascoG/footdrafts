defmodule FootDrafts.GameModes.NormalTest do
  use ExUnit.Case, async: true

  alias FootDrafts.Draft.State
  alias FootDrafts.GameModes.Normal

  @players %{
    1 => %{
      id: 1,
      name: "Player A",
      club_id: 100,
      club_name: "Club A",
      competition_id: 10,
      rating: 80
    },
    2 => %{
      id: 2,
      name: "Player B",
      club_id: 101,
      club_name: "Club B",
      competition_id: 10,
      rating: 90
    },
    3 => %{
      id: 3,
      name: "Player C",
      club_id: 100,
      club_name: "Club A",
      competition_id: 10,
      rating: 70
    },
    4 => %{
      id: 4,
      name: "Player D",
      club_id: 102,
      club_name: "Club C",
      competition_id: 20,
      rating: 60
    }
  }

  defp new_state(scope \\ :worldwide, squad_size \\ 2) do
    State.new(Normal, scope, @players, [:alice, :bob], squad_size)
  end

  describe "pool/2" do
    test "worldwide scope includes every player" do
      assert Normal.pool(:worldwide, @players) |> Enum.sort() == [1, 2, 3, 4]
    end

    test "competition scope filters to that competition only" do
      assert Normal.pool(10, @players) |> Enum.sort() == [1, 2, 3]
      assert Normal.pool(20, @players) |> Enum.sort() == [4]
    end
  end

  describe "visible_fields/1" do
    test "never includes the hidden rating" do
      visible = Normal.visible_fields(@players[1])
      refute Map.has_key?(visible, :rating)
      assert visible.name == "Player A"
    end
  end

  describe "validate_pick/3 — turn order" do
    test "rejects a pick from the participant who is not up" do
      state = new_state()
      assert Normal.validate_pick(state, :bob, 1) == {:error, :not_your_turn}
    end

    test "allows the participant whose turn it is" do
      state = new_state()
      assert Normal.validate_pick(state, :alice, 1) == :ok
    end

    test "turn alternates after each apply_pick" do
      state = new_state()
      assert :ok = Normal.validate_pick(state, :alice, 1)
      state = Normal.apply_pick(state, :alice, 1)
      assert Normal.validate_pick(state, :bob, 2) == :ok
      assert Normal.validate_pick(state, :alice, 3) == {:error, :not_your_turn}
    end
  end

  describe "validate_pick/3 — pool availability" do
    test "rejects a player outside the current pool" do
      state = new_state(10)
      assert Normal.validate_pick(state, :alice, 4) == {:error, :player_not_available}
    end

    test "rejects a player who has already been picked" do
      state = new_state()
      state = Normal.apply_pick(state, :alice, 1)
      assert Normal.validate_pick(state, :bob, 1) == {:error, :player_not_available}
    end
  end

  describe "validate_pick/3 — one player per club" do
    test "rejects a second pick from a club the participant already drafted" do
      state = new_state(10, 3)
      state = Normal.apply_pick(state, :alice, 1)
      state = Normal.apply_pick(state, :bob, 2)
      # It's alice's turn again; player 3 is also Club A, same as her player 1
      assert Normal.validate_pick(state, :alice, 3) == {:error, :club_already_drafted}
    end

    test "the same club is fine across two different participants" do
      state = new_state(10, 2)
      state = Normal.apply_pick(state, :alice, 1)

      # Bob picking a Club A player too (id 3) is legal — the constraint is per-squad, not global
      assert Normal.validate_pick(state, :bob, 3) == :ok
    end
  end

  describe "validate_pick/3 — completed draft" do
    test "rejects any further picks once both squads are full" do
      state = new_state(10, 1)
      state = Normal.apply_pick(state, :alice, 1)
      state = Normal.apply_pick(state, :bob, 2)
      assert state.status == :complete
      assert Normal.validate_pick(state, :alice, 3) == {:error, :draft_complete}
    end
  end

  describe "apply_pick/3" do
    test "adds the player to the squad and removes it from the pool" do
      state = new_state()
      state = Normal.apply_pick(state, :alice, 1)
      assert state.participants[:alice].squad == [1]
      refute MapSet.member?(state.pool, 1)
    end

    test "records a pick with an incrementing round number" do
      state = new_state()
      state = Normal.apply_pick(state, :alice, 1)
      state = Normal.apply_pick(state, :bob, 2)
      assert [%{round: 1}, %{round: 2}] = state.picks
    end
  end

  describe "outcome/1" do
    test "the higher average-rating squad wins" do
      state = new_state(10, 1)
      state = Normal.apply_pick(state, :alice, 1)
      state = Normal.apply_pick(state, :bob, 2)

      assert Normal.outcome(state) == %{winner: :bob, scores: %{alice: 80.0, bob: 90.0}}
    end

    test "returns nil winner when squads have equal average ratings" do
      tied_players = %{
        1 => %{
          id: 1,
          name: "Player A",
          club_id: 100,
          club_name: "Club A",
          competition_id: 10,
          rating: 80
        },
        2 => %{
          id: 2,
          name: "Player B",
          club_id: 101,
          club_name: "Club B",
          competition_id: 10,
          rating: 80
        }
      }

      state = State.new(Normal, :worldwide, tied_players, [:alice, :bob], 1)
      state = Normal.apply_pick(state, :alice, 1)
      state = Normal.apply_pick(state, :bob, 2)

      assert Normal.outcome(state) == %{winner: nil, scores: %{alice: 80.0, bob: 80.0}}
    end
  end
end
