defmodule FootDraftsWeb.PageController do
  use FootDraftsWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
