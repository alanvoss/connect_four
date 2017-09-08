defmodule ConnectFour.Contenders.MeowMix do
  use GenServer
  alias ConnectFour.BoardHelper

  def start(default) do
    GenServer.start(__MODULE__, default)
  end

  def handle_call(:name, _from, state) do
    {:reply, "MeowMix9000", state}
  end

  def handle_call({:move, board}, _from, state) do
    case winning_drop(board) do
      {:winner, column} ->
        {:reply, column, board}
      {:nowinner} ->
        random_column = random_drop(board)
        {:reply, random_column, state}
    end
  end

  defp winning_drop(board) do
    one_drops = Enum.to_list 0..6
    |> Enum.map(fn(n) -> {n, BoardHelper.drop(board, 1, n)} end)
    |> Enum.filter(fn({_n, b}) -> match?({:ok, _}, b) end)
    |> Enum.map(fn({n, b}) -> {n, elem(b, 1)} end)

    two_drops = Enum.to_list 0..6
    |> Enum.map(fn(n) -> {n, BoardHelper.drop(board, 2, n)} end)
    |> Enum.filter(fn({_n, b}) -> match?({:ok, _}, b) end)
    |> Enum.map(fn({n, b}) -> {n, elem(b, 1)} end)

    winner = one_drops
    |> Enum.map(fn({n, b}) -> {n, BoardHelper.evaluate_board(b)} end)
    |> Enum.filter(fn({_n, b}) -> match?({:winner, _}, b) end)

    IO.inspect(winner)
    {:nowinner}

    case winner do
      [{n, _}] ->
        {:winner, n}
      _ ->
        two_winner = two_drops
        |> Enum.map(fn({n, b}) -> {n, BoardHelper.evaluate_board(b)} end)
        |> Enum.filter(fn({_n, b}) -> match?({:winner, _}, b) end)

        case two_winner do
          [{n, _}] ->
            {:winner, n}
          _ ->
            {:nowinner}
        end
    end
  end

  defp random_drop(board) do
    board
    |> Enum.at(0)
    |> Enum.with_index
    |> Enum.filter(&(elem(&1, 0) == 0))
    |> Enum.map(&(elem(&1, 1)))
    |> Enum.random
  end
end
