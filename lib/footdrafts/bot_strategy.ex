defmodule FootDrafts.BotStrategy do
  @moduledoc """
  Difficulty-based bot pick strategy over a set of legal player ids.
  """

  @type difficulty :: :easy | :medium | :hard

  @spec pick_player_id([term()], %{optional(term()) => %{rating: number()}}, difficulty()) ::
          term() | nil
  def pick_player_id([], _players, _difficulty), do: nil

  def pick_player_id(legal_ids, players, difficulty) do
    ranked_ids =
      Enum.sort_by(
        legal_ids,
        fn id -> players |> Map.fetch!(id) |> Map.fetch!(:rating) end,
        :desc
      )

    candidate_ids = candidate_ids(ranked_ids, difficulty)

    candidate_ids
    |> fallback_candidates(ranked_ids)
    |> Enum.random()
  end

  @spec candidate_ids([term()], difficulty()) :: [term()]
  def candidate_ids(ranked_ids, :easy), do: ranked_slice(ranked_ids, 3, 10)
  def candidate_ids(ranked_ids, :medium), do: ranked_slice(ranked_ids, 1, 5)
  def candidate_ids(ranked_ids, :hard), do: ranked_slice(ranked_ids, 1, 1)

  defp fallback_candidates([], ranked_ids), do: ranked_ids
  defp fallback_candidates(candidate_ids, _ranked_ids), do: candidate_ids

  defp ranked_slice(ranked_ids, from_rank, to_rank) do
    start_index = max(from_rank - 1, 0)
    length = max(to_rank - from_rank + 1, 0)
    Enum.slice(ranked_ids, start_index, length)
  end
end
