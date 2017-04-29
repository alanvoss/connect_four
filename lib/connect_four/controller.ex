defmodule ConnectFour.Controller do
  alias ConnectFour.{Board, BoardHelper}

  @pause_between_state_changes 10
  @pause_between_frame_draws 10

  def start_battle do
    {:ok, modules} = :application.get_key(:connect_four, :modules)

    combos =
      modules
      |> Enum.filter(&(String.starts_with?(Atom.to_string(&1), "Elixir.ConnectFour.Contenders")))
      |> combinations(2)

    sorted_winners =
      combos
      |> Enum.map(&start_game(&1))
      |> List.flatten
      |> Enum.reduce(%{}, fn {:winner, name}, acc ->
           Map.update(acc, name, 1, &(&1 + 1))
         end)
      |> Enum.sort(&(elem(&1, 1) >= elem(&2, 1)))

    Board.print_results(sorted_winners, length(combos))
  end

  def start_game([opponent1, opponent2]) do
    Agent.start_link(fn -> %{1 => nil, 2 => nil} end, name: :contenders)

    contenders = [opponent1, opponent2]
    opp1 = Enum.random(contenders)
    [opp2] = List.delete(contenders, opp1)

    {:ok, opp1_pid} = opp1.start(nil)
    {:ok, opp2_pid} = opp2.start(nil)

    # TODO: also catch these and forfeit if :exit
    player(1, GenServer.call(opp1_pid, :name))
    player(2, GenServer.call(opp2_pid, :name))

    # announcement
    Board.print_contenders(player(1), player(2))
    :timer.sleep(@pause_between_state_changes)

    new_board = BoardHelper.new()
    case loop(new_board, [opp1_pid, opp2_pid], 1) do
      {:winner, contender} ->
        [{:winner, player(contender)}]
      {:forfeit, contender} ->
        [{:winner, player(rem(contender, 2) + 1)}]
      :tie ->
        [{:winner, player(1)}, {:winner, player(2)}]
    end
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
          {:forfeit, contender}
      end

    new_board =
      case column do
        {:forfeit, contender} ->
          {:forfeit, contender}
        column ->
          case BoardHelper.drop(board, contender, column) do
            {:error, error} ->
              forfeit(contender, error)
              {:forfeit, contender}
            {:ok, error_free_board} ->
              error_free_board
          end
      end

    case new_board do
      {:forfeit, contender} ->
        {:forfeit, contender}
      new_board ->
        Board.print_drop(board, contender, column)
        :timer.sleep(@pause_between_frame_draws)
        Board.print(new_board)
        :timer.sleep(@pause_between_frame_draws)

        case BoardHelper.evaluate_board(new_board) do
          {:winner, highlight_coords} ->
            for i <- 1..5 do
              :timer.sleep(@pause_between_frame_draws)
              Board.print(new_board, true, highlight_coords)
              :timer.sleep(@pause_between_frame_draws)
              Board.print(new_board)
            end
            :timer.sleep(@pause_between_state_changes)
            Board.print_winner(player(contender), contender)
            :timer.sleep(@pause_between_state_changes)
            {:winner, contender}
          :tie ->
            Board.print_tie(player(1), player(2))
            :timer.sleep(@pause_between_state_changes)
            :tie
          _ ->
            loop(new_board, contenders, rem(contender, 2) + 1)
        end
    end
  end

  defp forfeit(contender, reason) do
    Board.print_forfeit(contender, reason)
    :timer.sleep(@pause_between_state_changes)
    winner = rem(contender, 2) + 1
    Board.print_winner(player(winner), winner)
    :timer.sleep(@pause_between_state_changes)
  end

  # storing these in an Agent in case of GenServer contender crash
  # where I wouldn't be able to retrieve the name to print the winner
  # probably should just reimplement this as another GenServer
  defp player(index, name) do
    Agent.update(:contenders, fn m -> Map.put(m, index, name) end)
  end
  defp player(index) do
    Agent.get(:contenders, fn m -> Map.get(m, index) end)
  end

  defp combinations(_, 0), do: [[]]
  defp combinations([], _), do: []
  defp combinations(_deck = [x|xs], n) when is_integer(n) do
    (for y <- combinations(xs, n - 1), do: [x|y]) ++ combinations(xs, n)
  end
end
