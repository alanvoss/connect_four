defmodule ConnectFour.Board do
  @board [
    [0, 1, 0, 0, 1, 2, 1],
    [1, 2, 0, 0, 2, 1, 2],
    [2, 1, 0, 2, 1, 2, 2],
    [2, 1, 2, 2, 1, 2, 1],
    [1, 2, 1, 1, 2, 2, 1],
    [1, 1, 2, 2, 1, 1, 1],
  ]

  @contender_colors %{
    1 => IO.ANSI.cyan,
    2 => IO.ANSI.red
  }

  @contender_characters %{
    0 => ["   "],
    1 => [@contender_colors[1], " \xF0\x9F\x85\xB0 "],
    2 => [@contender_colors[2], " \xF0\x9F\x85\xB1 "]
  }

  def new do
    for i <- 1..7 do
      for j <- 1..6 do
        0
      end
    end
  end

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

  def evaluate_board(board \\ @board) do
x =    evaluate_rows(board) ||
      evaluate_columns(board) ||
      evaluate_diagonals(board)
      evaluate_tie(board)
require IEx
#IEx.pry
x
  end

  defp evaluate_rows(board) do
    result =
      board
      |> Enum.with_index
      |> Enum.find_value(&find_start_coordinate/1)

    case result do
      nil -> nil
      {row_index, column_index} ->
        end_column_index = column_index + 3
        {:winner, Enum.map(column_index..end_column_index, &({row_index, &1}))}
    end
  end

  defp evaluate_columns(board) do
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
      {column_index, row_index} ->
        end_row_index = row_index + 3
        {:winner, Enum.map(row_index..end_row_index, &({column_index, &1}))}
    end
  end

  defp evaluate_diagonals(board) do
    up_and_to_right =
      for row_index <- 3..8 do
        diagonal(row_index, 0, 1)
        |> Enum.filter(&is_valid?/1)
      end
    
    up_and_to_left =
      for row_index <- 3..8 do
        diagonal(row_index, 6, -1)
        |> Enum.filter(&is_valid?/1)
      end

require IEx
#IEx.pry
"alan"
  end

  defp diagonal(row_index, column_index, increment) do
    diagonal(row_index, column_index, increment, [])
  end
  defp diagonal(-1, _, _, acc), do: acc
  defp diagonal(row_index, column_index, increment, acc) do
    diagonal(row_index - 1, column_index + increment, increment, acc ++ [{column_index, row_index}])
  end

  defp is_valid?({column_index, row_index}) do
    row_index >= 0 &&
      row_index <= 5 &&
      column_index >= 0 &&
      column_index <= 6
  end

  defp evaluate_tie(board) do
    found_zero =
      board
      |> Enum.find(&(Enum.any?(&1, fn piece -> piece == 0 end)))

    case found_zero do
      nil -> :tie
      _ -> nil
    end
  end

  defp find_start_coordinate({row, row_index}) do
    find_start_coordinate(row, row_index, nil, 0, 0)
  end
  defp find_start_coordinate(_, row_index, _, column_index, 4) do
    {row_index, column_index}
  end
  defp find_start_coordinate([], _, _, _, _), do: false
  defp find_start_coordinate([first | rest], row_index, char, column_index, count) when first == char do
    find_start_coordinate(rest, row_index, char, column_index, count + 1)
  end
  defp find_start_coordinate([first | rest], row_index, _, column_index, count) do
    find_start_coordinate(rest, row_index, first, column_index + 1, 1)
  end

  def drop(board \\ @board, which, column_index) do
    if Enum.at(board, 0) |> Enum.at(column_index) !== 0 do
      raise "That move is not allowed"
    end

    IO.inspect board
    |> Enum.reverse
    |> drop(which, column_index, false, [])
  end

  defp drop([], _, _, _, board), do: board
  defp drop([row | rest], which, column_index, true, board) do
    drop(rest, which, column_index, true, [row | board])
  end
  defp drop([row | rest], which, column_index, false, board) do
    case Enum.at(row, column_index) do
      0 ->
        drop(rest, which, column_index, true,
          [List.replace_at(row, column_index, which) | board])
      _ ->
        drop(rest, which, column_index, false, [row | board])
    end
  end

  def print_winner(name, which) do
    IO.puts [IO.ANSI.clear]
    IO.puts []
    IO.puts []
    IO.puts [IO.ANSI.red, "And the winner is ..."]
    IO.puts []
    IO.puts [@contender_colors[which], name]
    IO.puts []
  end

  def print_contenders(contender1, contender2) do
    IO.puts [IO.ANSI.clear]
    IO.puts [@contender_colors[1], contender1]
    IO.puts []
    IO.puts [IO.ANSI.yellow, "    vs    "]
    IO.puts []
    IO.puts [@contender_colors[2], contender2]
    IO.puts []
    IO.puts [IO.ANSI.reset]
  end

  def print_drop(board \\ @board, contender, column) do
    IO.puts [IO.ANSI.clear]
    IO.puts Enum.map(1..7, fn
      ^column -> @contender_characters[contender]
      n -> @contender_characters[0]
    end)
    print(board, false)
  end

  def print(board \\ @board, clear \\ true) do
    if clear, do: IO.puts [IO.ANSI.clear]
    for line <- board do
      IO.puts Enum.map(line, fn space ->
        @contender_characters[space]
      end) |>
      List.flatten
    end
    IO.puts [IO.ANSI.reset]
  end
end
