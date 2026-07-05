# FootDrafts

Phoenix LiveView + Ecto/PostgreSQL web app. Two guests (no accounts) each
draft a squad of real football players from a shared pool; a hidden
per-player rating (never sent to any client) decides the winner after a
simultaneous reveal. MVP is "Normal" mode only: single competition or
worldwide scope, 5-a-side squads, one player per real club, alternating
turns.

## Non-obvious rules

- All draft logic (pool scoping, pick validation, applying a pick, deciding
  the winner) goes through the `FootDrafts.GameMode` behaviour. Never branch
  on game mode inside a GenServer or LiveView — add a new module instead.
- `PlayerRating` (the hidden score) lives in its own schema/table, separate
  from `PlayerStat` (visible facts: goals, assists, appearances). Never
  preload or return both from the same query.
- No `User` schema in the MVP. Participants are guest sessions identified by
  a browser-held token, not accounts.
- Pick validation is always server-authoritative — never trust a
  client-submitted flag that says a move is legal.
- Prefer functions that take a `FootDrafts.Draft.State` struct and return a
  new one over functions with side effects, wherever the logic is testable
  without a GenServer or the database.
