defmodule ConnectFour.Controller do
  alias ConnectFour.{Board, BoardHelper}

  def start_game(opponent1, opponent2) do
    contenders = [opponent1, opponent2]
    opp1 = Enum.random(contenders)
    [opp2] = List.delete(contenders, opp1)

    {:ok, opp1_pid} = opp1.start_link(nil)
    {:ok, opp2_pid} = opp2.start_link(nil)

    # announcement
    Board.print_contenders(GenServer.call(opp1_pid, :name), GenServer.call(opp2_pid, :name))
    :timer.sleep(2000)

    new_board = BoardHelper.new()
    loop(new_board, [opp1_pid, opp2_pid], 1)
  end

  defp loop(board, contenders = [opp1_pid, opp2_pid], contender) do
    Board.print(board)

    contender_pid = Enum.at(contenders, contender - 1)
    column = GenServer.call(contender_pid, {
      :move,
      case contender do
        1 -> board
        2 -> BoardHelper.flip(board)
      end
    })

    Board.print_drop(board, contender, column)
    :timer.sleep(100)
    new_board = BoardHelper.drop(board, contender, column)
    Board.print(new_board)
    :timer.sleep(100)

    case BoardHelper.evaluate_board(new_board) do
      {:winner, highlight_coords} ->
        for i <- 1..5 do
          :timer.sleep(100)
          Board.print(new_board, true, highlight_coords)
          :timer.sleep(100)
          Board.print(new_board)
        end
        :timer.sleep(2000)
        Board.print_winner(GenServer.call(contender_pid, :name), contender)
        IO.puts [IO.ANSI.reset()]
      :tie ->
        Board.print_tie(GenServer.call(opp1_pid, :name), GenServer.call(opp2_pid, :name))
        IO.puts [IO.ANSI.reset()]
      _ ->
        loop(new_board, contenders, rem(contender, 2) + 1)
    end
  end
end
