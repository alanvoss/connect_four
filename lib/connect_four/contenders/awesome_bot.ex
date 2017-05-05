defmodule ConnectFour.Contenders.AwesomeBot do
  use GenServer

  alias ConnectFour.BoardHelper


  def start(_) do
    GenServer.start(__MODULE__, :ok)
  end

  def init(:ok) do
    empty_board = BoardHelper.new()
    {:ok, empty_board}
  end


  def handle_call(:name, _from, last_board) do
    {:reply, "AwesomeBot", last_board}
  end

  def handle_call({:move, board}, _from, last_board) do
    col = 0
    # TODO determine the column

    column = determine_next_position(board)

    {:reply, column, last_board}
  end


  defp determine_next_position(board) do
    find_winning_position(board, 2) || find_winning_position(board, 1) || next_priority(board)
  end

  defp find_winning_position(board, contender) do
    0..6
    |> Stream.map(fn col ->
      with {:ok, updated_board} <- BoardHelper.drop(board, contender, col),
           {:winner, _} <- BoardHelper.evaluate_board(updated_board) do
        col
      else
        _ -> nil
      end
    end)
    |> Enum.filter(fn col -> col != nil end)
    |> Enum.at(0)
  end

  defp next_priority(board) do
    with {:ok, _} <- BoardHelper.drop(board, 1, 3) do
      3
    else
      _ ->
        for row <- 6..0,
            col <- 0..5 do
          for delta_row <- -1..1,
              delta_col <- -1..1 do
            {new_row, new_col} = new_coords = {row + delta_row, col + delta_col}
            if delta_col == 0 and delta_row == 0 do
              nil
            else
              with :true <- BoardHelper.is_valid_coordinate?(new_coords),
                   1 <- BoardHelper.at_coordinate(board, new_coords) do
                col
              else
                nil
              end
            end
          end
        end
        |> List.flatten()
        |> Enum.filter(fn col -> col != nil end)
        |> Enum.at(0)
    end
  end


end