defmodule ConnectFour.Controller do
  alias ConnectFour.{Board, BoardHelper}

  @pause_between_state_changes 1500
  @pause_between_frame_draws 100

  def display_games(dir \\ "results", stepwise \\ false) do
    dir
    |> List.wrap()
    |> gather_games()
    |> Enum.each(&(display_game(&1, stepwise)))
  end

  def start_battle do
    {:ok, modules} = :application.get_key(:connect_four, :modules)

    combos =
      modules
      |> Enum.filter(&(String.starts_with?(Atom.to_string(&1), "Elixir.ConnectFour.Contenders")))
      |> combinations(2)

    if length(combos) == 0 do
      IO.puts "There are 1 or fewer contenders currently, so there's no battles to be done."
      IO.puts "Try using #{__MODULE__}.start_game(...) instead"
      System.halt(0)
    end

    sorted_winners =
      combos
      |> Enum.map(fn contenders -> Task.async(fn -> {contenders, do_game(contenders)} end) end)
      |> Enum.map(&(Task.await(&1)))
      |> Enum.map(&(store_game(&1)))
      |> Enum.map(&(&1["victors"]))
      |> List.flatten
      |> Enum.reduce(%{}, fn name, acc ->
           Map.update(acc, name, 1, &(&1 + 1))
         end)
      |> Enum.sort(&(elem(&1, 1) >= elem(&2, 1)))

    Board.print_results(sorted_winners, length(combos))
  end

  def do_game(contenders) do
    contenders_info =
      contenders
      |> Enum.shuffle
      |> Enum.map(fn module ->
           {:ok, pid} = module.start(nil)
           name = GenServer.call(pid, :name)
           {pid, name}
         end)
      |> Enum.with_index

    new_board = BoardHelper.new()

    names =
      contenders_info
      |> Enum.map(&(contender_name(&1)))

    result = %{
      "contenders" => names,
      "result" => "win",
      "comment" => ""
    }

    result =
      case loop(new_board, contenders_info, []) do
        {{:winner, contender_info}, moves} ->
          Map.merge(result, %{
            "moves" =>  moves,
            "victors" => [elem(contender_info, 1)]
          })
        {{:forfeit, contender_info, reason}, moves} ->
          loser = elem(contender_info, 1)
          winner =
            contenders_info
            |> Enum.map(&(elem(&1, 0)))
            |> List.delete(contender_info)
            |> Enum.map(&(elem(&1, 1)))
            |> List.first

          Map.merge(result, %{
            "moves" => moves,
            "victors" => [winner],
            "comment" => "#{loser} forfeited because: #{reason}"
          })
        {:tie, moves} ->
          Map.merge(result, %{
            "result" => "tie",
            "moves" => moves,
            "victors" => names
          })
      end

    contenders_info
    |> Enum.map(&(elem(&1, 0)))
    |> Enum.map(&(elem(&1, 0)))
    |> Enum.filter(&(Process.alive?(&1)))
    |> Enum.each(&(GenServer.stop(&1)))

    result
  end

  def display_game(result, stepwise) do
    [player1, player2] = result["contenders"]

    # announcement screen
    Board.print_contenders(player1, player2)
    :timer.sleep(@pause_between_state_changes)

    # the action
    {winning_board, _} =
      result["moves"]
      |> Enum.reduce({BoardHelper.new(), 0}, fn column, {board, contender} ->
           Board.print_drop(board, contender + 1, column)
           if !stepwise, do: :timer.sleep(@pause_between_frame_draws)
           {:ok, new_board} = BoardHelper.drop(board, contender + 1, column)
           Board.print(new_board)
           if stepwise, do: IO.getn(:stdio, "hit any key", 1), else: :timer.sleep(@pause_between_frame_draws)
           {new_board, rem(contender + 1, 2)}
         end)

    # the winner announcement
    case result["result"] do
      "win" ->
        with {:winner, highlight_coords} <- BoardHelper.evaluate_board(winning_board) do
          for _ <- 1..5 do
            :timer.sleep(@pause_between_frame_draws)
            Board.print(winning_board, true, highlight_coords)
            :timer.sleep(@pause_between_frame_draws)
            Board.print(winning_board)
          end
        end

        :timer.sleep(@pause_between_state_changes)

        [victor] = result["victors"]
        winner_index =
          result["contenders"]
          |> Enum.with_index
          |> Enum.filter(&(elem(&1, 0) == victor))
          |> Enum.map(&(elem(&1, 1)))
          |> List.first

        Board.print_winner(victor, winner_index, result["comment"])
      "tie" ->
        Board.print_tie(player1, player2)
    end

    :timer.sleep(@pause_between_state_changes)
  end

  defp gather_games(file) do
    if File.dir?(file) do
      {:ok, files} = File.ls(file)
      files
      |> Enum.map(&(gather_games(Enum.join([file, &1], "/"))))
      |> List.flatten
      |> Enum.filter(&(&1 != nil))
      |> Enum.uniq
    else
      if file =~ ~r/\.json$/ do
        case File.read(file) do
          error when elem(error, 0) == :error -> nil
          {:ok, contents} ->
            case Poison.decode(contents) do
              {:error, :invalid, _} -> nil
              {:ok, json} -> json
            end
        end
      end
    end
  end

  defp store_game({contenders, result}) do
    json = result |> Poison.encode!()

    file_names =
      contenders
      |> Enum.map(&(Atom.to_string(&1)))
      |> Enum.map(&(String.split(&1, ".") |> List.last))

    File.cd!("results")

    file_names
    |> Enum.map(&(File.mkdir(&1)))

    File.write(Enum.join([List.first(file_names), "#{List.last(file_names)}.json"], "/"), json)
    File.write(Enum.join([List.last(file_names), "#{List.first(file_names)}.json"], "/"), json)

    File.cd!("..")

    result
  end

  defp contender_name({{_, name}, _}) do
    name
  end

  defp loop(board, [{{pid, _} = contender_info, contender}, _] = contenders, moves) do
    column =
      try do
        case contender do
          0 -> GenServer.call(pid, {:move, board})
          1 -> GenServer.call(pid, {:move, BoardHelper.flip(board)})
        end
      catch
        :exit, _ -> {:forfeit, contender_info, "timeout or GenServer crash"}
      end

    new_board =
      case column do
        {:forfeit, contender_info, reason} ->
          {:forfeit, contender_info, reason}
        column ->
          case BoardHelper.drop(board, contender + 1, column) do
            {:error, _} ->
              {:forfeit, contender_info, "disallowed move"}
            {:ok, error_free_board} ->
              error_free_board
          end
      end

    case new_board do
      {:forfeit, contender_info, reason} ->
        {{:forfeit, contender_info, reason}, Enum.reverse(moves)}
      new_board ->
        case BoardHelper.evaluate_board(new_board) do
          {:winner, _} ->
            {{:winner, contender_info}, Enum.reverse([column | moves])}
          :tie ->
            {:tie, Enum.reverse([column | moves])}
          _ ->
            loop(new_board, Enum.reverse(contenders), [column | moves])
        end
    end
  end

  defp combinations(_, 0), do: [[]]
  defp combinations([], _), do: []
  defp combinations([x|xs], n) when is_integer(n) do
    (for y <- combinations(xs, n - 1), do: [x|y]) ++ combinations(xs, n)
  end
end
