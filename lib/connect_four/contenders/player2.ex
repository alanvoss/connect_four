defmodule ConnectFour.Contenders.Player2 do
  use GenServer

  def start(default) do
    GenServer.start(__MODULE__, default)
  end

  def handle_call(:name, _from, state) do
    {:reply, "Player 2 has entered", state}
  end

  def handle_call({:move, board}, _from, state) do
    move = board
    |> block_columns

    move = if move == nil do
      random_column(board)
    else
      move
    end

    IO.puts move

    {:reply, move, state}
  end

  def stupid_move(column) do
    if Enum.at(column, 0) != 0 do
      true
    else
      false
    end
  end

  def random_column(board) do
    board
    |> Enum.at(0)
    |> Enum.with_index
    |> Enum.filter(&(elem(&1, 0) == 0))
    |> Enum.map(&(elem(&1, 1)))
    |> Enum.random
  end

  def block_columns(board) do
    rotated_board = board
    |> Enum.with_index
    |> Enum.reduce(Enum.map(1..7, fn _ -> [] end), fn {row, _row_index}, acc ->
      Enum.zip(acc, row)
      |> Enum.map(fn {list, value} -> list ++ [value] end)
    end)

    column_with_three = rotated_board
    |> Enum.with_index
    |> Enum.find(&three_consecutive_at_top/1)

    case column_with_three do
      nil -> nil
      {_row, row_index} ->
        row_index
    end
  end

  def three_consecutive_at_top({column, _index}) do
    try do

      column
      |> Enum.reduce({0, 0, 0}, fn element, {last, last_count, total_count} ->
        if last_count == 3, do: throw(true)
        if !stupid_move(column), do: throw(false)

        cond do
          element == 0 ->
            {last, last_count, total_count + 1}
          element == last ->
            {element, last_count + 1, total_count + 1}
          true ->
            {element, 1, total_count + 1}
        end
      end )

      false
    catch
      x ->
        x
    end
  end
end
