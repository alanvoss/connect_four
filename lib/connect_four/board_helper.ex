defmodule ConnectFour.BoardHelper do
  @moduledoc """
    Helpers for evaluating, creating, and appending to boards
  """

  @doc "Create a new board."
  def new do
    for i <- 0..5 do
      for j <- 0..6 do
        0
      end
    end
  end

  @doc """
    If necessary, flip the 1s and 2s in a board so that everyone receives a board
    with 1 as themselves and 2 as their opponent.
  """
  def flip(board) do
    for row <- board do
      for column <- row do
        case column do
          0 -> 0
          1 -> 2
          2 -> 1
        end
      end
    end
  end

  @doc "Evaluate a board and return a winner."
  def evaluate_board(board) do
    evaluate_rows(board) ||
      evaluate_columns(board) ||
      evaluate_diagonals(board) ||
      evaluate_tie(board)
  end

  @doc """
    Return the value of what is at a particular space on the board (zero indexed).
      0 - no piece
      1 - contender 1
      2 - contender 2
  """
  def at_coordinate(board, {column, row}) do
    board
    |> Enum.at(row)
    |> Enum.at(column)
  end

  @doc "Does a coordinate fall within the bounds of the board?"
  def is_valid_coordinate?({column_index, row_index}) do
    row_index >= 0 &&
      row_index <= 5 &&
      column_index >= 0 &&
      column_index <= 6
  end

  @doc """
    Drop a piece of contender (0 or 1) into an existing board at the column and
    return a new board.
  """
  def drop(board, contender, column_index) do
    if Enum.at(board, 0) |> Enum.at(column_index) !== 0 do
      {:error, "non-allowed move"}
    else
      {:ok,
        board
        |> Enum.reverse
        |> drop(contender + 1, column_index, false, [])
      }
    end
  end

  @doc "Evaluate horizontal winners."
  def evaluate_rows(board) do
    result =
      board
      |> Enum.with_index
      |> Enum.find_value(&find_start_coordinate/1)

    case result do
      nil -> nil
      {column_index, row_index} ->
        end_column_index = column_index + 3
        {:winner, Enum.map(column_index..end_column_index, &({&1, row_index}))}
    end
  end

  @doc "Evaluate vertical winners."
  def evaluate_columns(board) do
    rotated_board = 
      board
      |> Enum.with_index
      |> Enum.reduce(Enum.map(1..7, fn _ -> [] end), fn {row, row_index}, acc ->
           Enum.zip(acc, row)
           |> Enum.map(fn {list, value} -> list ++ [value] end)
         end)

    result =
      rotated_board
      |> Enum.with_index
      |> Enum.find_value(&find_start_coordinate/1)

    case result do
      nil -> nil
      {row_index, column_index} ->
        end_row_index = row_index + 3
        {:winner, Enum.map(row_index..end_row_index, &({column_index, &1}))}
    end
  end

  @doc "Evaluate diagonal winners."
  def evaluate_diagonals(board) do
    coordinates =
      board
      |> get_diagonal_coordinates

    result =
      coordinates
      |> Enum.map(fn set -> Enum.map(set, &(at_coordinate(board, &1))) end)
      |> Enum.with_index
      |> Enum.find_value(&find_start_coordinate/1)

    case result do
      nil -> nil
      {column, row} ->
        {
          :winner,
          Enum.at(coordinates, row)
          |> Enum.drop(column)
          |> Enum.take(4)
        }
    end
  end

  @doc """
    Evaluate whether there is any space left to put a piece.  Should only be run
    after all the other evaluation functions.
  """
  def evaluate_tie(board) do
    found_zero =
      board
      |> Enum.find(&(Enum.any?(&1, fn piece -> piece == 0 end)))

    case found_zero do
      nil -> :tie
      _ -> nil
    end
  end

  @doc "Get the list of all the sets of valid diagonals at least four spaces in width"
  def get_diagonal_coordinates(board) do
    up_and_to_right =
      for row_index <- 3..8 do
        diagonal(row_index, 0, 1)
        |> Enum.filter(&is_valid_coordinate?/1)
      end
    
    up_and_to_left =
      for row_index <- 3..8 do
        diagonal(row_index, 6, -1)
        |> Enum.filter(&is_valid_coordinate?/1)
      end

    up_and_to_right ++ up_and_to_left
  end

  @doc "Construct a diagonal set of coordinates."
  defp diagonal(row_index, column_index, increment) do
    diagonal(row_index, column_index, increment, [])
  end
  defp diagonal(-1, _, _, acc), do: acc
  defp diagonal(row_index, column_index, increment, acc) do
    diagonal(row_index - 1, column_index + increment, increment, acc ++ [{column_index, row_index}])
  end

  @doc "Find a place in a list of values where a string of 4 identical non-0s occurs."
  defp find_start_coordinate({row, row_index}) do
    find_start_coordinate(row, {0, row_index}, nil, 0, 0)
  end
  defp find_start_coordinate(_, {column_index, row_index}, _, _, 4) do
    {column_index, row_index}
  end
  defp find_start_coordinate([], _, _, _, _), do: false
  defp find_start_coordinate([first | rest], {column_index, row_index}, char, index, count) when first == char do
    find_start_coordinate(rest, {column_index, row_index}, char, index + 1, count + 1)
  end
  defp find_start_coordinate([0 | rest], {column_index, row_index}, _, index, count) do
    find_start_coordinate(rest, {index, row_index}, nil, index + 1, 1)
  end
  defp find_start_coordinate([first | rest], {column_index, row_index}, _, index, count) do
    find_start_coordinate(rest, {index, row_index}, first, index + 1, 1)
  end

  @doc "Perform the mutation of dropping a piece onto the board."
  defp drop([], _, _, _, board), do: board
  defp drop([row | rest], contender, column_index, true, board) do
    drop(rest, contender, column_index, true, [row | board])
  end
  defp drop([row | rest], contender, column_index, false, board) do
    case Enum.at(row, column_index) do
      0 ->
        drop(rest, contender, column_index, true,
          [List.replace_at(row, column_index, contender) | board])
      _ ->
        drop(rest, contender, column_index, false, [row | board])
    end
  end
end
