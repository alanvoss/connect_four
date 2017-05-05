defmodule ConnectFour.Contenders.TeamNotCheaters do
  use GenServer

  def start(default) do
    GenServer.start(__MODULE__, %{moved: false})
  end

  def handle_call(:name, _from, state) do
    {:reply, "Team Not Cheaters", state}
  end

  def handle_call({:move, board}, _from, state) do
    
    if (!state[:moved]) do
        state = Map.put(state, :moved, true)
        {:reply, 6, state}
    else
        {:reply, 6, state}
    end
  end

end
