defmodule ConnectFour.Contenders.TeamNotCheaters do
  use GenServer
  alias ConnectFour.BoardHelper

  def start(default) do
    GenServer.start(__MODULE__, %{moved: false})
  end

  def handle_call(:name, _from, state) do
    {:reply, "Team Not Cheaters", state}
  end

  def handle_call({:move, board}, _from, state) do
    we_win = check_if_we_can_win(board)
    they_win = check_if_they_can_win(board)
    random_move = random_move(board, state)


    cond do
        !state[:moved] -> 
                    state = Map.put(state, :moved, true)
                    {:reply, 4, state}
        we_win != 0 -> {:reply, we_win, state}
        they_win != 0 -> {:reply, they_win, state}
        true -> random_move
    end

  end

  defp check_if_they_can_win(board) do
      opponents_board = BoardHelper.flip(board)
      check_if_we_can_win(opponents_board)
  end

  defp random_move(board, state) do
      random_column =
        board
        |> Enum.at(0)
        |> Enum.with_index
        |> Enum.filter(&(elem(&1, 0) == 0))
        |> Enum.map(&(elem(&1, 1)))
        |> Enum.filter(&BoardHelper.is_valid_coordinate?({&1, 0}))
        |> Enum.random

        {:reply, random_column, state}
  end

  defp check_if_we_can_win(board) do  
    Enum.map(0..6, fn i ->
        BoardHelper.drop(board,1, i)
    end)
    |> Enum.with_index
    |> Enum.filter(&(&1 != nil))
    |> Enum.map(&(elem(&1, 1)))
    |> List.first()

  end

end
