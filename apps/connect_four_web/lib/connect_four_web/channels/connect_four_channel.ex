defmodule ConnectFour.Web.ConnectFourChannel do
  use Phoenix.Channel

  def join("connect_four", _message, socket) do
    {:ok, socket}
  end

  def handle_in("start_battle", %{}, socket) do
    ConnectFourEngine.Controller.start_battle
    {:noreply, socket}
  end
end
