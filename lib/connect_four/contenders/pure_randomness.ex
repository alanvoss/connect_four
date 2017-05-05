defmodule ConnectFour.Contenders.PureRandomness do
  use GenServer

  def start(default) do
    GenServer.start(__MODULE__, default)
  end

  def handle_call(:name, _from, state) do
    letters = for n <- ?A..?Z, do: n
    random_name =
      for i <- 1..12 do
        Enum.random(letters)
      end

    {:reply, List.to_string(random_name), state}
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