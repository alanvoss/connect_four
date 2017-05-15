defmodule ConnectFourEngine.Contenders.Player2 do
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
    |> block_rows(board)
    |> good_random(board)

    {:reply, move, state}
  end

  def good_random(nil, board) do
    choice = random_column(nil, board)
    |> worthwhile_column(board)

    choice || good_random(nil, board)
  end
  def good_random(col, _board), do: col

  def random_column(nil, board) do
    board
    |> Enum.at(0)
    |> Enum.with_index
    |> Enum.filter(&(elem(&1, 0) == 0))
    |> Enum.map(&(elem(&1, 1)))
    |> Enum.random
  end
  def random_column(choice, _board), do: choice

  def block_columns(board) do
    column_with_three = board
    |> rotate_board
    |> Enum.with_index
    |> Enum.reject(fn {col, idx} -> too_tall(col) end)
    |> Enum.find(&three_consecutive_at_top/1)

    case column_with_three do
      nil -> nil
      {_row, row_index} ->
        row_index
    end
  end

  def block_rows(nil, board) do
    first_bad = board
    |> first_row_with_three

    position = board
    |> first_row_with_three
    |> left_block
    |> right_block

    case position do
      nil -> nil
      {row, idx} -> nil
      position ->
        if too_tall(select_column(board, position)) do
          nil
        else
          position
        end
    end
  end
  def block_rows(col, _board), do: col

  defp first_row_with_three(board) do
    board
    |> Enum.with_index
    |> Enum.filter(&dangerous_list((elem(&1,0))))
    |> Enum.at(0)
  end

  def left_block(i) when is_integer(i), do: i
  def left_block(nil), do: nil
  def left_block({row, idx}) do
    col_num = row
    |> if_dangerous
    |> Enum.with_index
    |> Enum.find(fn {item, _idx} -> item == 2 end)

    case col_num do
      {_item, idx} when idx > 0 ->
        idx = idx - 1
        case Enum.at(row, idx) do
          x when x == 0 -> idx
          _ -> nil
        end
      {_item, _idx} -> nil
      nil -> nil
    end
  end

  def if_dangerous(list) do
    if dangerous_list(list) do
      list
    else
      []
    end
  end

  defp right_block(i) when is_integer(i), do: i
  defp right_block(nil), do: nil
  defp right_block({row, idx}) do
    col_num = row
    |> if_dangerous
    |> Enum.with_index
    |> Enum.reverse
    |> Enum.find(fn {item, _idx} -> item == 2 end)

    case col_num do
      {_item, idx} when (idx > 0) ->
        idx = idx - 1
        case Enum.at(row, idx) do
          x when x == 0 -> 7 - (idx)
          _ -> nil
        end
      {_item, _idx} -> nil
      nil -> nil
    end
  end

  def dangerous_list(list) do
    list
    |> find_consecutives
    |> Enum.any?(fn {item, count} -> item >= 1 && count >= 3 end)
  end

  def three_consecutive_at_top({column, _index}) do
    item = column
    |> find_consecutives
    |> Enum.reject(fn {item, count} -> item == 0 end)
    |> Enum.at(0)

    if item do
      {item, count} = item
      item > 0 && count >= 3
    else
      nil
    end
  end

  def find_consecutives(list) do
    list
    |> Enum.map(fn x -> {x,1} end)
    |> Enum.reduce([], &find_consecutives/2)
    |> Enum.reverse
  end
  def find_consecutives(item, []), do: [item]
  def find_consecutives({num, _count}, [{last, last_count}|t] = list) do
    cond do
      num == 0 ->
        list
      num == last ->
        [{num, last_count + 1} | t]
      true ->
        [{num, 1} | list]
    end
  end

  def worthwhile_column(nil, _board), do: nil
  def worthwhile_column(col, board) do
    yes? = board
    |> select_column(col)
    |> Enum.map(fn el ->
      case el do
        0 ->
          0
        1 ->
          0
        2 ->
          2
      end
    end)
    |> Enum.take(4)
    |> Enum.all?(fn el ->
      el == 0
    end)

    if yes? do
      col
    else
      nil
    end
  end

  defp select_column(board, num) do
    board
    |> rotate_board
    |> Enum.at(num)
  end

  defp too_tall(column) do
    Enum.at(column, 0) != 0
  end

  defp rotate_board(board) do
    board
    |> Enum.with_index
    |> Enum.reduce(Enum.map(1..7, fn _ -> [] end), fn {row, _row_index}, acc ->
      Enum.zip(acc, row)
      |> Enum.map(fn {list, value} -> list ++ [value] end)
    end)
  end

end
