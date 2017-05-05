defmodule ConnectFour.Contenders.SeanEric do
  use GenServer
  import ConnectFour.BoardHelper

  def start(default) do
    GenServer.start(__MODULE__, default)
  end

  def init(_) do
    {:ok, []}
  end

  def handle_call(:name, _, state) do
    {:reply, "Sean & Eric", state}
  end

  def handle_call({:move, board}, _from, state) do
    choice = make_choice(board, state, [])
    record_move(inspect {self(), [choice|state]})
    {:reply, choice, [choice|state]}
  end

  defp make_choice(board, state, used) do
    attempt = [
      &try_to_win/2,
      &try_to_block/2,
      fn(b, u) -> play_adjacent(b, state, u) end,
      &play_to_middle/2
    ] |> Enum.find_value(fn f -> f.(board, used) end)
  end

  defp play_adjacent(_, [], _) do
    false
  end
  defp play_adjacent(board, [last_play|_], used) do
    [last_play + 1, last_play - 1]
    |> Enum.shuffle()
    |> Enum.filter(fn column -> not column in used end)
    |> Enum.filter(fn column -> is_valid_coordinate?({column, 0}) end)
    |> Enum.find(can_play?(board, 1))
  end

  def player_can_win(board, player, used) do
    0..6
    |> Enum.filter(fn column -> not column in used end)
    |> Enum.find(fn column ->
      with {:ok, new_board} <- drop(board, player, column),
           {:winner, _} <- evaluate_board(new_board) do
        record_move("#{inspect self()} found win for #{player}: #{column}")
        true
      else
        _ -> false
      end
    end)
  end

  defp try_to_win(board, used) do
    player_can_win(board, 1, used)
  end

  defp try_to_block(board, used) do
    player_can_win(board, 2, used)
  end

  defp play_to_middle(board, used) do
    [3, 2, 4, 1, 5, 0, 6]
    |> Enum.filter(fn column -> not column in used end)
    |> Enum.find(can_play?(board, 1))
  end

  defp record_move(text) do
    File.write!("plays.txt", "#{text}\n", [:append])
  end

  defp can_play?(board, player) do
    fn column ->
      match?({:ok, _}, drop(board, player, column))
    end
  end
end
