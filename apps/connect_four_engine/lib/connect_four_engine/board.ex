defmodule ConnectFourEngine.Board do
  alias ConnectFourEngine.BoardHelper

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

  def print_results(sorted_winners, number_of_matches) do
    IO.puts [IO.ANSI.clear]

    IO.puts "\n\n"
    IO.puts [IO.ANSI.yellow, "------- RESULTS -------"]
    IO.puts "\n\n"
    IO.puts [IO.ANSI.green, "After a total of #{number_of_matches} matches, here are the results:"]
    IO.puts "\n\n"

    winning_count =
      Enum.at(sorted_winners, 0)
      |> elem(1)

    sorted_winners
    |> Enum.with_index
    |> Enum.each(fn
         {{name, ^winning_count}, n} ->
           IO.puts [IO.ANSI.red, "#{n + 1}: #{name} had #{winning_count} wins"]
         {{name, wins}, n} ->
           IO.puts [IO.ANSI.green, "#{n + 1}: #{name} had #{wins} wins"]
        end)

    IO.puts "\n\n\n"
    IO.puts [IO.ANSI.reset]
  end

  def print_winner(name, contender) do
    IO.puts [IO.ANSI.clear]
    IO.puts []
    IO.puts []
    IO.puts [IO.ANSI.green, "And the winner is ..."]
    IO.puts []
    IO.puts [@contender_colors[contender], name]
    IO.puts []
    IO.puts [IO.ANSI.reset]
  end

  def print_contenders(contender1, contender2) do
    longest = Enum.max([String.length(contender1), String.length(contender2)])
    rounded_half = round(longest / 2)
    buffer = Enum.map(1..rounded_half - 1, fn _ -> " " end)

    IO.puts [IO.ANSI.clear]
    IO.puts [@contender_colors[1], contender1]
    IO.puts []
    IO.puts [IO.ANSI.yellow, "#{buffer}vs"]
    IO.puts []
    IO.puts [@contender_colors[2], contender2]
    IO.puts []
    IO.puts [IO.ANSI.reset]
  end

  def print_tie(contender1, contender2) do
    IO.puts [IO.ANSI.clear]
    IO.puts []
    IO.puts [IO.ANSI.clear, "It's a tie!!!!"]
    IO.puts []
    IO.puts [@contender_colors[1], contender1]
    IO.puts [@contender_colors[2], contender2]
    IO.puts []
    IO.puts [IO.ANSI.reset]
  end

  def print_forfeit(contender, reason) do
    IO.puts [IO.ANSI.clear]
    IO.puts []
    IO.puts []
    IO.puts [IO.ANSI.green, "Due to #{reason}"]
    IO.puts [IO.ANSI.green, "Player ", @contender_colors[contender], "#{contender}", IO.ANSI.green, " has forfeited"]
    IO.puts []
    IO.puts []
    IO.puts [IO.ANSI.reset]
  end

  def print_drop(board, contender, column) do
    IO.puts [IO.ANSI.clear]
    IO.puts Enum.map(0..6, fn
      ^column -> @contender_characters[contender]
      n -> @contender_characters[0]
    end)
    print(board, false)
  end

  def print(board, clear \\ true, highlighted_coordinates \\ []) do
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
    IO.puts [IO.ANSI.reset]
  end
end
