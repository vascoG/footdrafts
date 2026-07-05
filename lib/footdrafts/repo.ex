defmodule FootDrafts.Repo do
  use Ecto.Repo,
    otp_app: :footdrafts,
    adapter: Ecto.Adapters.Postgres
end
