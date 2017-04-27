defmodule ConnectFour.Controller do
  alias ConnectFour.{Board, BoardHelper}

  # storing these in an Agent in case of GenServer contender crash
  # where I wouldn't be able to retrieve the name to print the winner
  # probably should just reimplement this as another GenServer
  defp player(index, name) do
    Agent.update(:contenders, fn m -> Map.put(m, index, name) end)
  end
  defp player(index) do
    Agent.get(:contenders, fn m -> Map.get(m, index) end)
  end

  def start_game(opponent1, opponent2) do
    Agent.start_link(fn -> %{1 => nil, 2 => nil} end, name: :contenders)

    contenders = [opponent1, opponent2]
    opp1 = Enum.random(contenders)
    [opp2] = List.delete(contenders, opp1)

    {:ok, opp1_pid} = opp1.start_link(nil)
    {:ok, opp2_pid} = opp2.start_link(nil)

    player(1, GenServer.call(opp1_pid, :name))
    player(2, GenServer.call(opp2_pid, :name))

    # announcement
    Board.print_contenders(player(1), player(2))
    :timer.sleep(2000)

    new_board = BoardHelper.new()
    loop(new_board, [opp1_pid, opp2_pid], 1)
  end

  defp loop(board, contenders = [opp1_pid, opp2_pid], contender) do
    Board.print(board)

    contender_pid = Enum.at(contenders, contender - 1)

    column =
    try do
      GenServer.call(contender_pid, {
        :move,
        case contender do
          1 -> board
          2 -> BoardHelper.flip(board)
        end
      })
    catch 
      :exit, _ ->
        forfeit(contender, "Timeout or other Genserver error")
    end

    new_board =
      case BoardHelper.drop(board, contender, column) do
        {:error, error} ->
          forfeit(contender, error)
        {:ok, error_free_board} ->
          error_free_board
      end

    Board.print_drop(board, contender, column)
    :timer.sleep(100)
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
        Board.print_winner(player(contender), contender)
        IO.puts [IO.ANSI.reset()]
      :tie ->
        Board.print_tie(player(1), player(2))
        IO.puts [IO.ANSI.reset()]
      _ ->
        loop(new_board, contenders, rem(contender, 2) + 1)
    end
  end

  defp forfeit(contender, reason) do
    Board.print_forfeit(contender, reason)
    :timer.sleep(5000)
    winner = rem(contender, 2) + 1
    Board.print_winner(player(winner), winner)
    System.halt(0)
  end
end
