defmodule ConnectFour.Contenders.AlanBot do
  use GenServer
  alias ConnectFour.BoardHelper

  @max_moves_out 5 

  def start(default) do
    GenServer.start(__MODULE__, default)
  end

  def handle_call(:name, _from, state) do
    {:reply, "Alan Bot", state}
  end

  def handle_call({:move, board}, _from, state) do
    column =
      available_columns(board)
      |> Enum.map(&({&1, weight(board, &1, @max_moves_out)}))
      |> Enum.map(fn {column, {wins, losses}} -> {column, wins - losses} end)
      |> Enum.sort_by(&(elem(&1, 1)))
      |> Enum.map(&(elem(&1, 0)))
      |> List.last

    {:reply, column, state}
  end

  def weight(board, column, remaining_moves) do
    case remaining_moves do
      0 -> {0, 0}
      remaining_moves ->
        {:ok, new_board} = BoardHelper.drop(board, 1, column)
        {wins, losses} =
          case BoardHelper.evaluate_board(new_board) do
            {:winner, _} ->
              {1, 0}
            {:tie, _} ->
              {0.5, 0.5}
            _ ->
              flipped_board = BoardHelper.flip(new_board)
              {total_winners, total_losers} =
                available_columns(new_board)
                |> Enum.reduce({0, 0}, fn column, {winners, losers} ->
                     {win, loss} = weight(flipped_board, column, remaining_moves - 1)
                     {winners + loss, losers + win}
                   end)
              total = total_winners + total_losers
              case total do
                0 -> {0, 0}
                total -> {total_winners/total, total_losers/total}
              end
          end
        {wins, losses}
    end
  end

  defp available_columns(board) do
    board
    |> Enum.at(0)
    |> Enum.with_index
    |> Enum.filter(&(elem(&1, 0) == 0))
    |> Enum.map(&(elem(&1, 1)))
  end
end
