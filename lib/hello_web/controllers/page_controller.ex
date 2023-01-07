defmodule HelloWeb.PageController do
  use HelloWeb, :controller

  plug HelloWeb.Plugs.Locale, "en" when action in [:index]

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
