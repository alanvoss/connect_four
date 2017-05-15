defmodule ConnectFour.Web.PageController do
  use ConnectFour.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
