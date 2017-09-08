defmodule ConnectFour.Contenders.TJ.BoardHelper do
  @moduledoc """
    Helpers for evaluating, creating, and appending to boards
  """

  @doc """
  Create a new board.

  Returns: a matrix representing a board.

  ## Examples:

      iex> ConnectFour.BoardHelper.new()
      [[0, 0, 0, 0, 0, 0, 0],
       [0, 0, 0, 0, 0, 0, 0],
       [0, 0, 0, 0, 0, 0, 0],
       [0, 0, 0, 0, 0, 0, 0],
       [0, 0, 0, 0, 0, 0, 0],
       [0, 0, 0, 0, 0, 0, 0]]

  """
  def new do
    for _ <- 0..5 do
      for _ <- 0..6 do
        0
      end
    end
  end

  @doc """
  Finds the value at a given coordinate (0 indexed)

  Returns one of: 0 (no piece), 1 (contender 1), 2 (contender 2)

  ## Examples

      iex> ConnectFour.BoardHelper.at_coordinate(
      ...> [[0, 0, 0, 0, 0, 0, 0],
      ...>  [0, 0, 0, 0, 0, 0, 0],
      ...>  [0, 0, 0, 0, 0, 0, 0],
      ...>  [0, 0, 1, 0, 0, 0, 0],
      ...>  [0, 2, 2, 1, 0, 0, 0],
      ...>  [0, 2, 2, 1, 1, 0, 0]], {4, 5})
      1

  """
  def at_coordinate(board, {column, row}) do
    board
    |> Enum.at(row)
    |> Enum.at(column)
  end

  @doc """
  Determines whether a coordinate falls within the bounds of the board.  Coordinates are from
  {0,0} in the upper left corner to {6, 5} in the lower right.

  Returns one of (boolean): true, false

  ## Examples

      iex> ConnectFour.BoardHelper.is_valid_coordinate?({0, 4})
      true

      iex> ConnectFour.BoardHelper.is_valid_coordinate?({7, 4})
      false

  """
  def is_valid_coordinate?({column_index, row_index}) do
    row_index in 0..5 && column_index in 0..6
  end

  @doc """
  Drop a contender (either 1 or 2) into a given board at the given column (0 indexed).

  Returns a new board

  ## Examples

      iex> ConnectFour.BoardHelper.drop(
      ...> [[0, 0, 0, 0, 0, 0, 0],
      ...>  [0, 0, 0, 0, 0, 0, 0],
      ...>  [0, 0, 0, 0, 0, 0, 0],
      ...>  [0, 0, 1, 0, 0, 0, 0],
      ...>  [0, 2, 2, 1, 0, 0, 0],
      ...>  [0, 2, 2, 1, 1, 0, 0]], 1, 1)
      {:ok, [[0, 0, 0, 0, 0, 0, 0],
             [0, 0, 0, 0, 0, 0, 0],
             [0, 0, 0, 0, 0, 0, 0],
             [0, 1, 1, 0, 0, 0, 0],
             [0, 2, 2, 1, 0, 0, 0],
             [0, 2, 2, 1, 1, 0, 0]]}

  """
  def drop(board, contender, column_index) when contender in [1,2] do
    if Enum.at(board, 0) |> Enum.at(column_index) !== 0 do
      {:error, "non-allowed move"}
    else
      {:ok,
        board
        |> Enum.reverse
        |> drop(contender, column_index, false, [])
      }
    end
  end

  @doc """
  Evaluate a board for winners, ties, or no winner yet.

  Returns one of: {:winner, winning_coordinates}, :tie, nil (no winner yet)

  ## Examples

      iex> ConnectFour.BoardHelper.evaluate_board(
      ...> [[0, 0, 0, 0, 0, 0, 0],
      ...>  [0, 0, 0, 0, 0, 0, 0],
      ...>  [0, 0, 0, 0, 0, 0, 0],
      ...>  [0, 0, 1, 0, 0, 0, 0],
      ...>  [0, 2, 2, 1, 0, 0, 0],
      ...>  [0, 2, 2, 1, 1, 0, 0]])
      nil

      iex> ConnectFour.BoardHelper.evaluate_board(
      ...> [[0, 0, 0, 0, 0, 0, 0],
      ...>  [0, 0, 0, 0, 0, 0, 0],
      ...>  [0, 1, 0, 0, 0, 0, 0],
      ...>  [0, 1, 1, 0, 0, 0, 0],
      ...>  [0, 2, 2, 1, 0, 0, 0],
      ...>  [2, 2, 2, 1, 1, 0, 0]])
      {:winner, [{4, 5}, {3, 4}, {2, 3}, {1, 2}]}

  """
  def evaluate_board(board, evaluator \\ &find_start_coordinate/1) do
    evaluate_rows(board, evaluator) ||
      evaluate_columns(board, evaluator) ||
      evaluate_diagonals(board, evaluator) ||
      evaluate_tie(board)
  end

  @doc """
  Evaluate a board for winners horizontally.

  Returns one of: {:winner, winning_coordinates}, nil

  ## Examples

      iex> ConnectFour.BoardHelper.evaluate_board(
      ...> [[0, 0, 0, 0, 0, 0, 0],
      ...>  [0, 0, 0, 0, 0, 0, 0],
      ...>  [0, 0, 0, 0, 0, 0, 0],
      ...>  [0, 0, 1, 0, 0, 0, 0],
      ...>  [0, 2, 2, 1, 0, 0, 0],
      ...>  [0, 2, 2, 1, 1, 0, 0]])
      nil

      iex> ConnectFour.BoardHelper.evaluate_board(
      ...> [[0, 0, 0, 0, 0, 0, 0],
      ...>  [0, 0, 0, 0, 0, 0, 0],
      ...>  [0, 0, 0, 0, 0, 0, 0],
      ...>  [0, 0, 1, 0, 0, 0, 0],
      ...>  [0, 2, 2, 1, 0, 0, 0],
      ...>  [2, 2, 2, 1, 1, 1, 1]])
      {:winner, [{3, 5}, {4, 5}, {5, 5}, {6, 5}]}

  """
  def evaluate_rows(board, evaluator \\ &find_start_coordinate/1) do
    result =
      board
      |> Enum.with_index
      |> Enum.find_value(evaluator)

    case result do
      nil -> nil
      {column_index, row_index} ->
        end_column_index = column_index + 3
        {:winner, Enum.map(column_index..end_column_index, &({&1, row_index}))}
    end
  end

  @doc """
  Evaluate a board for winners vertically.

  Returns one of: {:winner, winning_coordinates}, nil

  ## Examples

      iex> ConnectFour.BoardHelper.evaluate_columns(
      ...> [[0, 0, 0, 0, 0, 0, 0],
      ...>  [0, 0, 0, 0, 0, 0, 0],
      ...>  [0, 0, 0, 0, 0, 0, 0],
      ...>  [0, 0, 1, 0, 0, 0, 0],
      ...>  [0, 2, 2, 1, 0, 0, 0],
      ...>  [0, 2, 2, 1, 1, 0, 0]])
      nil

      iex> ConnectFour.BoardHelper.evaluate_columns(
      ...> [[0, 0, 0, 0, 0, 0, 0],
      ...>  [0, 0, 0, 0, 0, 0, 0],
      ...>  [0, 2, 0, 0, 0, 0, 0],
      ...>  [0, 2, 1, 1, 0, 0, 0],
      ...>  [0, 2, 2, 1, 0, 0, 0],
      ...>  [0, 2, 2, 1, 1, 1, 0]])
      {:winner, [{1, 2}, {1, 3}, {1, 4}, {1, 5}]}

  """
  def evaluate_columns(board, evaluator \\ &find_start_coordinate/1) do
    rotated_board =
      board
      |> Enum.with_index
      |> Enum.reduce(Enum.map(1..7, fn _ -> [] end), fn {row, _row_index}, acc ->
           Enum.zip(acc, row)
           |> Enum.map(fn {list, value} -> list ++ [value] end)
         end)

    result =
      rotated_board
      |> Enum.with_index
      |> Enum.find_value(evaluator)

    case result do
      nil -> nil
      {row_index, column_index} ->
        end_row_index = row_index + 3
        {:winner, Enum.map(row_index..end_row_index, &({column_index, &1}))}
    end
  end

  @doc """
  Evaluate a board for winners diagonally.

  Returns one of: {:winner, winning_coordinates}, nil

  ## Examples

      iex> ConnectFour.BoardHelper.evaluate_diagonals(
      ...> [[0, 0, 0, 0, 0, 0, 0],
      ...>  [0, 0, 0, 0, 0, 0, 0],
      ...>  [0, 0, 0, 0, 0, 0, 0],
      ...>  [0, 0, 1, 0, 0, 0, 0],
      ...>  [0, 2, 2, 1, 0, 0, 0],
      ...>  [0, 2, 2, 1, 1, 0, 0]])
      nil

      iex> ConnectFour.BoardHelper.evaluate_diagonals(
      ...> [[0, 0, 0, 0, 0, 0, 0],
      ...>  [0, 0, 0, 0, 0, 0, 0],
      ...>  [0, 1, 0, 0, 0, 0, 0],
      ...>  [0, 2, 1, 0, 0, 0, 0],
      ...>  [0, 2, 2, 1, 0, 0, 0],
      ...>  [0, 2, 2, 1, 1, 1, 0]])
      {:winner, [{4, 5}, {3, 4}, {2, 3}, {1, 2}]}

  """
  def evaluate_diagonals(board, evaluator \\ &find_start_coordinate/1) do
    coordinates = get_diagonal_coordinates()

    result =
      coordinates
      |> Enum.map(fn set -> Enum.map(set, &(at_coordinate(board, &1))) end)
      |> Enum.with_index
      |> Enum.find_value(evaluator)

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
  Evaluate a board for ties.

  Returns one of: :tie, nil

  ## Examples

      iex> ConnectFour.BoardHelper.evaluate_tie(
      ...> [[0, 0, 0, 0, 0, 0, 0],
      ...>  [0, 0, 0, 0, 0, 0, 0],
      ...>  [0, 0, 0, 0, 0, 0, 0],
      ...>  [0, 0, 1, 0, 0, 0, 0],
      ...>  [0, 2, 2, 1, 0, 0, 0],
      ...>  [0, 2, 2, 1, 1, 0, 0]])
      nil

      iex> ConnectFour.BoardHelper.evaluate_tie(
      ...> [[1, 2, 2, 2, 1, 2, 1],
      ...>  [1, 2, 1, 1, 1, 2, 2],
      ...>  [2, 1, 2, 2, 1, 2, 1],
      ...>  [2, 1, 2, 2, 2, 1, 1],
      ...>  [1, 2, 1, 1, 1, 2, 2],
      ...>  [1, 1, 2, 2, 1, 2, 1]])
      :tie

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

  @doc """
  Get a list of all continuous diagonal coordinates of at least 4 in length.

  Returns a list of coordinates.

  ## Examples

      iex> ConnectFour.BoardHelper.get_diagonal_coordinates()
      [[{0, 3}, {1, 2}, {2, 1}, {3, 0}], [{0, 4}, {1, 3}, {2, 2}, {3, 1}, {4, 0}],
       [{0, 5}, {1, 4}, {2, 3}, {3, 2}, {4, 1}, {5, 0}],
       [{1, 5}, {2, 4}, {3, 3}, {4, 2}, {5, 1}, {6, 0}],
       [{2, 5}, {3, 4}, {4, 3}, {5, 2}, {6, 1}], [{3, 5}, {4, 4}, {5, 3}, {6, 2}],
       [{6, 3}, {5, 2}, {4, 1}, {3, 0}], [{6, 4}, {5, 3}, {4, 2}, {3, 1}, {2, 0}],
       [{6, 5}, {5, 4}, {4, 3}, {3, 2}, {2, 1}, {1, 0}],
       [{5, 5}, {4, 4}, {3, 3}, {2, 2}, {1, 1}, {0, 0}],
       [{4, 5}, {3, 4}, {2, 3}, {1, 2}, {0, 1}], [{3, 5}, {2, 4}, {1, 3}, {0, 2}]]

  """
  def get_diagonal_coordinates do
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

  @doc """
  Swap `1`s and `2`s, but leave `0`s undisturbed.

  Returns a board from the opposite player's perspective.

  ## Examples

      iex> ConnectFour.BoardHelper.flip(
      ...> [[0, 0, 0, 0, 0, 0, 0],
      ...>  [0, 0, 0, 0, 0, 0, 0],
      ...>  [0, 0, 0, 0, 0, 0, 0],
      ...>  [0, 0, 1, 0, 0, 0, 0],
      ...>  [0, 2, 2, 1, 0, 0, 0],
      ...>  [0, 2, 2, 1, 1, 0, 0]])
      [[0, 0, 0, 0, 0, 0, 0],
       [0, 0, 0, 0, 0, 0, 0],
       [0, 0, 0, 0, 0, 0, 0],
       [0, 0, 2, 0, 0, 0, 0],
       [0, 1, 1, 2, 0, 0, 0],
       [0, 1, 1, 2, 2, 0, 0]]

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

  # Construct a diagonal set of coordinates.
  defp diagonal(row_index, column_index, increment) do
    diagonal(row_index, column_index, increment, [])
  end
  defp diagonal(-1, _, _, acc), do: acc
  defp diagonal(row_index, column_index, increment, acc) do
    diagonal(row_index - 1, column_index + increment, increment, acc ++ [{column_index, row_index}])
  end

  # Find a place in a list of values where a string of 4 identical non-0s occurs.
  def find_start_coordinate({row, row_index}) do
    find_start_coordinate(row, {0, row_index}, nil, 0, 0)
  end
  def find_start_coordinate(_, {column_index, row_index}, _, _, 4) do
    {column_index, row_index}
  end
  def find_start_coordinate([], _, _, _, _), do: false
  def find_start_coordinate([first | rest], {column_index, row_index}, char, index, count) when first == char do
    find_start_coordinate(rest, {column_index, row_index}, char, index + 1, count + 1)
  end
  def find_start_coordinate([0 | rest], {_column_index, row_index}, _, index, _count) do
    find_start_coordinate(rest, {index, row_index}, nil, index + 1, 1)
  end
  def find_start_coordinate([first | rest], {_column_index, row_index}, _, index, _count) do
    find_start_coordinate(rest, {index, row_index}, first, index + 1, 1)
  end

  def reverse_coordinate({column_index, row_index}, row) do
    {length(row) - column_index - 1, row_index}
  end
  def reverse_coordinate(_, _row), do: false

  # Find a place in a list of values where a string of 3 identical non-0s is either preceded or
  # followed by a 0.
  def find_threat({row, row_index}) do
    find_threat(row, {0, row_index}, nil, 0, 0)
    ||
    find_threat(Enum.reverse(row), {0, row_index}, nil, 0, 0) |> reverse_coordinate(row)
  end
  def find_threat([0 | _rest], {_column_index, row_index}, _, index, 3) do
    {index, row_index}
  end
  def find_threat([], _, _, _, _), do: false
  def find_threat([first | rest], {column_index, row_index}, char, index, count) when first == char do
    find_threat(rest, {column_index, row_index}, char, index + 1, count + 1)
  end
  def find_threat([0 | rest], {_column_index, row_index}, _, index, _count) do
    find_threat(rest, {index, row_index}, nil, index + 1, 1)
  end
  def find_threat([first | rest], {_column_index, row_index}, _, index, _count) do
    find_threat(rest, {index, row_index}, first, index + 1, 1)
  end

  # Perform the mutation of dropping a piece onto the board.
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
