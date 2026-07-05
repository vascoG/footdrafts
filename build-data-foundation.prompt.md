# Build: FootDrafts data foundation

## Context

FootDrafts is a Phoenix LiveView + PostgreSQL app. Two guests (no accounts)
draft a squad each of real football players; a hidden per-player rating,
never sent to any client, decides the winner after a simultaneous reveal.
MVP scope is "Normal" mode only: draft from a single competition or
worldwide, 5 players per squad, one player per real club, alternating turns.

Stack: Elixir + Phoenix (`--live`) + Ecto + PostgreSQL. The data source for
players/stats is football-data.org, pulled manually — there is no scheduled
sync job.

## Scope of this task — data foundation only

Do not build LiveView pages, the DraftRoom GenServer, PubSub/Registry
wiring, bot/solo play, or the Blind/Budget/Fearless modes. Those are
separate, later steps — building any of them now, even minimally, is out of
scope for this request.

Build:

1. **Ecto schemas + migrations** for:
   - `Competition` (name, country, tier, external_id)
   - `Club` (name, country, external_id, belongs_to :competition)
   - `Player` (name, position, nationality, birth_date, birth_city,
     external_id, belongs_to :club)
   - `PlayerStat` (belongs_to :player, season, goals, assists, appearances,
     minutes_played) — these are the fields a future "Blind Draft" mode is
     allowed to show; keep this schema focused on visible, factual stats.
   - `PlayerRating` (belongs_to :player, season, rating) — the hidden
     composite score. Keep this schema and table completely separate from
     `PlayerStat`; nothing should join or return them together by default.
   - A unique constraint on `external_id` per table (for import upserts),
     and a unique constraint on (`player_id`, `season`) for both
     `PlayerStat` and `PlayerRating`.

2. **A `FootDrafts.Football` context module** with:
   - `list_players(scope)` — `scope` is `:worldwide` or a competition id;
     preloads `:club` and `:competition`.
   - A separate, clearly-named function for fetching a player's hidden
     rating for a season (e.g. `hidden_rating_for(player_id, season)`) —
     keep this out of any function whose name doesn't say "rating" or
     "hidden", so it's obvious at every call site when hidden data is in
     play.

3. **A Mix task**, `mix football_data.import`, that:
   - Accepts a competition code as an argument.
   - Is a runnable skeleton — stub the actual HTTP call to
     football-data.org with a clear `# TODO:` and a typespec, since this
     will be exercised against the real API locally, not in CI.
   - Upserts `Competition`/`Club`/`Player` rows by `external_id`.
   - This is a manual, admin-run task, not a scheduled/Oban job — don't add
     job-scheduling infrastructure.

## Already built — don't recreate

The `FootDrafts.GameMode` behaviour (`pool/2`, `visible_fields/1`,
`validate_pick/3`, `apply_pick/3`, `outcome/1`), `FootDrafts.Draft.State`,
and `FootDrafts.GameModes.Normal` already exist with a passing ExUnit suite.
Don't regenerate these — they'll be dropped in as-is at
`lib/footdrafts/game_mode.ex`, `lib/footdrafts/draft/state.ex`, and
`lib/footdrafts/game_modes/normal.ex`. If anything in this task needs to
reference them (e.g. the context module eventually feeding `State.new/5`),
assume that interface rather than inventing a different one.

## Acceptance criteria

- `mix ecto.migrate` runs cleanly against a fresh database.
- No function outside the rating-specific ones ever returns a `rating`
  field alongside general player data.
- `mix football_data.import <code>` runs end-to-end (HTTP stubbed) without
  crashing, and is idempotent — running it twice doesn't create duplicates.
