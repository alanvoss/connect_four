defmodule ConnectFour.Contenders.HulkHogan do
  use GenServer

  def start(default) do
    GenServer.start(__MODULE__, default)
  end

  def handle_call(:name, _from, state) do
    {:reply, "Hulk Hogan", state}
  end

  def handle_call({:move, board}, _from, state) do
    {:reply, ConnectFour.Contenders.MachoMan.choose_column(board), state}
  end
end
