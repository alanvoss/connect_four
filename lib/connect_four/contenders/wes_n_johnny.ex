defmodule ConnectFour.Contenders.WesNJohnny do
  use GenServer

  def start(default) do
    GenServer.start(__MODULE__, default)
  end

  def handle_call(:name, _from, state) do

    {:reply, "wes_and_johnny", state}
  end

  def handle_call({:move, board}, _from, state) do
    random_column =
      board
      |> Enum.at(0)
      |> Enum.with_index
      |> Enum.filter(&(elem(&1, 0) == 0))
      |> Enum.map(&(elem(&1, 1)))
      |> Enum.random

    {:reply, random_column, state}
  end
end
