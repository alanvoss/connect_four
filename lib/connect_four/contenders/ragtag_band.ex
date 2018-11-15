defmodule ConnectFour.Contenders.RagtagBand do
  use GenServer
  alias ConnectFour.BoardHelper

  def start(default) do
    GenServer.start(__MODULE__, default)
  end

  def handle_call(:name, _from, state) do
    {:reply, "Ragtag Band", state}
  end

  def handle_call({:move, board}, _from, state) do
    random_column =
      board
      |> available_columns
      |> Enum.random

    # 


    {:reply, random_column, state}
  end

  def choose_next_move(board) do
    columns = board |> available_columns
    x = case Enum.find(columns, &(winning_move?(board, 1, &1))) do
      # if opponent is about to win, block
      nil ->
        columns
        |> Enum.map(&(BoardHelper.drop(board, 1, &1)))
        |> hands_over_victory?
        |> Enum.reduce(columns, fn column, acc ->
             List.delete(acc, column)
           end)
        |> List.wrap
        |> Enum.random
      column -> column
    end
    x || Enum.at(columns, 0)
  end

  def hands_over_victory?(board) do
    board
    |> available_columns
    |> Enum.find(&(winning_move?(board, 2, &1)))
  end

  def winning_move?(board, contender, column_index) do
    # 3 in a row, either player
    BoardHelper.drop(board, contender, column_index)
    |> BoardHelper.evaluate_board
  end

  defp available_columns(board) do
    board
    |> Enum.at(0)
    |> Enum.with_index
    |> Enum.filter(&(elem(&1, 0) == 0))
    |> Enum.map(&(elem(&1, 1)))
  end
end
