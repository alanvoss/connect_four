defmodule ConnectFour.Contenders.Tielur do
  use GenServer
  alias ConnectFour.BoardHelper

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

    winning_move = win_check(board, 1)
    |> Enum.reject(fn(column) -> is_nil(column) end)
    |> List.first

    blocking_move = win_check(board, 2)
    |> Enum.reject(fn(column) -> is_nil(column) end)
    |> List.first

    {:reply, (winning_move || blocking_move || random_column), state}
  end

  def win_check(board, contender) do
    for sim_move <- possible_moves() do 
      with {:ok, board} <- BoardHelper.drop(board,contender,sim_move),
           {:winner, winner} <- BoardHelper.evaluate_board(board) do
         sim_move
      else 
        _ ->nil
      end
    end
  end
  def possible_moves do
    0..6 |> Enum.to_list
  end

end
