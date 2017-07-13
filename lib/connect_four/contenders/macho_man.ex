defmodule ConnectFour.Contenders.MachoMan do
  def choose_column(board) do
    cond do
      spaces_left_in_column(board, 0) > 0 -> 0
      spaces_left_in_column(board, 1) > 0 -> 1
      spaces_left_in_column(board, 2) > 0 -> 2
      spaces_left_in_column(board, 3) > 0 -> 3
      spaces_left_in_column(board, 4) > 0 -> 4
      spaces_left_in_column(board, 5) > 0 -> 5
    end
  end

  # defp valid_column?(board, column) do
  # end

  # defp top_chip_ownder(board, column) do

  # end

  defp spaces_left_in_column(board, column) do
    # x = 0
    # Iterate over rows
    # If row has 0 value at index == column, increment x
    # Stop incrementing x when you reach a non-zero value at index == column
    # return when you stop incrementing x
    Enum.reduce board, 0, fn(row, acc) ->
      if Enum.at(row, column) == 0 do
        acc + 1
      else
        acc
      end
    end
  end
end
