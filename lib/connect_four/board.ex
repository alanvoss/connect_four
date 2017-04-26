defmodule ConnectFour.Board do
  @board [
    [0, 1, 0, 0, 1, 2, 1],
    [1, 2, 0, 0, 2, 1, 2],
    [2, 1, 0, 2, 1, 2, 1],
    [2, 1, 0, 1, 2, 1, 1],
    [1, 2, 0, 2, 1, 2, 1],
    [1, 1, 2, 1, 1, 2, 1],
  ]

  @contender_colors %{
    1 => IO.ANSI.cyan,
    2 => IO.ANSI.red
  }

  @contender_characters %{
    0 => ["   "],
    1 => [@contender_colors[1], " \xF0\x9F\x85\xB0 "],
    2 => [@contender_colors[2],  " \xF0\x9F\x85\xB1 "]
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
        rem(column + 1, 2)
      end
    end
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
