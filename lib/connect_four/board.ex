defmodule ConnectFour.Board do
  alias ConnectFour.BoardHelper

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

  @highlighter_color IO.ANSI.black()

  @contender_characters %{
    0 => ["   "],
    1 => [@contender_colors[1], " \xF0\x9F\x85\xB0 "],
    2 => [@contender_colors[2], " \xF0\x9F\x85\xB1 "]
  }

  @highlighted_contender_characters %{
    0 => ["   "],
    1 => [@highlighter_color, " \xF0\x9F\x85\xB0 "],
    2 => [@highlighter_color, " \xF0\x9F\x85\xB1 "]
  }

  def print_winner(name, contender) do
    IO.puts [IO.ANSI.clear]
    IO.puts []
    IO.puts []
    IO.puts [IO.ANSI.green, "And the winner is ..."]
    IO.puts []
    IO.puts [@contender_colors[contender], name]
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
    IO.puts Enum.map(0..6, fn
      ^column -> @contender_characters[contender]
      n -> @contender_characters[0]
    end)
    print(board, false)
  end

  def print(board \\ @board, clear \\ true, highlighted_coordinates \\ []) do
    if clear, do: IO.puts [IO.ANSI.clear]
    Enum.map(0..5, fn row ->
      IO.puts Enum.map(0..6, fn column ->
        coordinate = {column, row}
        contender = BoardHelper.at_coordinate(board, coordinate)
        if coordinate in highlighted_coordinates do
          @highlighted_contender_characters[contender]
        else
          @contender_characters[contender]
        end
      end)
    end)
  end
end
