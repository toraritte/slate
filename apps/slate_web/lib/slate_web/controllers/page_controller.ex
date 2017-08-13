defmodule SlateWeb.PageController do
  use SlateWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
