require IEx

defmodule ConnectFour.Contenders.CMaggard do
  use GenServer

  alias ConnectFour.{BoardHelper}

  @name "cmaggard"

  def start(default) do
    GenServer.start(__MODULE__, default)
  end

  def handle_call(:name, _from, state) do
    {:reply, @name, state}
  end

  def handle_call({:move, board}, _from, state) do
    move = cond do
      do_i_have_winning_move?(board) ->
        board |> winning_cols |> choose_random
      does_opponent_have_winning_move?(board) ->
        board |> BoardHelper.flip |> winning_cols |> choose_random
      true ->
        board |> valid_cols |> choose_random
    end
    {:reply, move, state}
  end

  defp score_move({:error, _}), do: 0
  defp score_move({:ok, board}) do
    board |> BoardHelper.evaluate_board |> score
  end

  def score({:winner, _}), do: 1
  def score(_), do: 0.5

  def do_i_have_winning_move?(board) do
    not (board |> winning_cols |> Enum.empty?)
  end

  def does_opponent_have_winning_move?(board) do
    not (board |> BoardHelper.flip |> winning_cols |> Enum.empty?)
  end

  def winning_cols(board) do
    board
    |> cols_with_scores
    |> Enum.filter(& elem(&1, 0) == 1)
    |> Enum.map(& elem(&1, 1) )
  end

  def valid_cols(board) do
    board
    |> cols_with_scores
    |> Enum.reject(& elem(&1, 0) == 0)
    |> Enum.map(& elem(&1, 1) )
  end

  def cols_with_scores(board) do
    0..6 
    |> Enum.map(fn col ->
      with new_board  <- board |> make_move(col),
           score <- score_move(new_board)
      do
        score
      end
    end)
    |> Enum.with_index
  end

  defp make_move(board, col), do: BoardHelper.drop(board, 1, col)

  def choose_random(list) when is_list(list), do: list |> Enum.shuffle |> Enum.at(0)
end
