defmodule ConnectFour.Contenders.Tielur do
  use GenServer

  def start(default) do
    GenServer.start(__MODULE__, default)
  end

  def handle_call(:name, _from, state) do
    {:reply, "Tyler", state}
  end

  # Put Discs into Center
  def handle_call({:move, [ [_, _, _, _, _, _, _],
                            [_, _, _, _, _, _, _],
                            [_, _, _, _, _, _, _],
                            [_, _, _, _, _, _, _],
                            [_, _, _, _, _, _, _],
                            [_, _, _, 0, _, _, _]]}, _from, state) do

    {:reply, 3, state}
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

  def handle_call({:move, board}, _from, state) do
    {x, y} = ConnectFour.MyBoardHelper.check_for_winning_move(board, ConnectFour.MyBoardHelper.all_possible_moves)

    {:reply, y, state}
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
