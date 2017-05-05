defmodule ConnectFour.Contenders.WesNJohnny do
  alias ConnectFour.BoardHelper
  use GenServer
  require Logger

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

  def find_loser(board) do
    [0,1,2,3,4,5,6]
      |> Enum.filter(fn(col) -> valid_move?(board, col) end)
      |> Enum.map(fn(col) ->
          {_, new_board} = BoardHelper.drop(board, 2, col)
          # Logger.debug "#{inspect(new_board)}"
          result = BoardHelper.evaluate_board(new_board)
          # Logger.debug "#{inspect(result)}"
          case result do
            {:winner, _} -> col
            _ -> nil
          end
         end)
      |> Enum.find_index(fn(col) -> !is_nil(col) end)


  end

  def valid_move?(board, col) do
    BoardHelper.at_coordinate(board, {col, 0}) == 0
  end
end
