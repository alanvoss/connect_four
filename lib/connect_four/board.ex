defmodule ConnectFour.Board do
  @board [
    [0, 1, 0, 0, 1, 2, 1],
    [1, 2, 0, 0, 2, 1, 2],
    [2, 1, 0, 2, 1, 2, 1],
    [2, 1, 0, 1, 2, 1, 1],
    [1, 2, 0, 2, 1, 2, 1],
    [1, 1, 2, 1, 1, 2, 1],
  ]

  def print(board \\ @board) do
    IO.puts [IO.ANSI.clear]
    for line <- board do
      IO.puts Enum.map(line, fn space ->
        case space do
           0 -> ["  "]
           1 -> [IO.ANSI.cyan, "\xF0\x9F\x85\xB0 "]
           #1 -> [IO.ANSI.cyan, "O "]
           2 -> [IO.ANSI.red, "\xF0\x9F\x85\xB1 "]
           #2 -> [IO.ANSI.red, "O "]
         end
      end) |>
      List.flatten
    end
    IO.puts [IO.ANSI.reset]
  end
end




    #status = [IO.ANSI.yellow, "\033[2J", "\xF0\x9F\x98\x81", IO.ANSI.reset]
     #status = [IO.ANSI.yellow, "\033[<2>A", "\xF0\x9F\x98\x81", IO.ANSI.reset]
      # IO.puts ["The status is: ", status]
      #end
      #end
