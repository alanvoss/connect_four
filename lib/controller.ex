defmodule ConnectFour.Controller do
  alias ConnectFour.Board

  def start_game(opponent1, opponent2) do
    opp1 = Enum.random([opponent1, opponent2])
    opp2 = Enum.filter([opponent1, opponent2], fn x -> x !== opp1 end)

    # announcement
    Board.print_contenders(opp1.call(:name), opp2.call(:name))

    new_board = Board.new()
    loop(new_board, [opp1, opp2], 0)
  end

  defp loop(board, opponents = [opp1, opp2], which) do
    Board.print(board)
    :timer.sleep(500)

    {:ok, column} = opponents[which].call({
      :move,
      case which do
        0 -> board
        1 -> Board.flip(board)
      end
    })

    Board.print_drop(board, which, column)
    :timer.sleep(500)
    new_board = Board.drop(board, which, column)
    Board.print(new_board)
    :timer.sleep(500)

    case Board.evaluate_board(new_board) do
      {:winner, highlight_coords} ->
        Board.print_winning_board(new_board, highlight_coords)
        Board.print_winner(opponents[which].call(:name), which)
      :tie ->
        Board.print_tie(opp1.call(:name), opp2.call(:name))
      _ ->
        loop(new_board, opponents, rem(which + 1, 2))
    end
  end
end
