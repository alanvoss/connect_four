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
    chosen_column = choose_next_move(board)
    {:reply, chosen_column, state}
  end

  def choose_next_move(board) do
    columns = board |> available_columns
    x = case Enum.find(columns, fn(col) -> winning_move?(board, 1, col) end) do
      nil ->
        moves = blocking_moves(columns, board)
        if Enum.any?(moves) do
          choose_any_of(moves)
        else
          choose_any_of(columns)
        end
      column -> column
    end
    x || Enum.at(columns, 0)
  end

  def blocking_moves(avail, board) do
    Enum.map(avail, fn(col) ->
      {:ok, new_board} = BoardHelper.drop(board, 1, col)
      if hands_over_victory?(new_board) do
        col
      end
    end)
  end

  def choose_any_of(cols) do
    cols
    |> List.wrap
    |> Enum.random
  end

  def hands_over_victory?(board) do
    board
    |> available_columns
    |> Enum.find(&(winning_move?(board, 2, &1)))
  end

  def winning_move?(board, contender, column_index) do
    # 3 in a row, either player
    {:ok, new_board} = BoardHelper.drop(board, contender, column_index)
    new_board
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
