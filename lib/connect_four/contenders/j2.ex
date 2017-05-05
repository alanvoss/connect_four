defmodule ConnectFour.Contenders.J2 do
  use GenServer

  alias ConnectFour.BoardHelper, as: Helper

  def start(default) do
    GenServer.start(__MODULE__, default)
  end

  def handle_call(:name, _from, state) do
    {:reply, "J2", state}
  end

  def handle_call({:move, board}, _from, state) do
    new_board = move(board, move_number(board))

    {:reply, new_board, state}
  end

  defp move(board, move_num) when move_num in [1,2] do
    3
    # Helper.drop(board, 1, 3)
  end

  defp move(board, move_num) do
    case check_row_run(board, :left, 3) do
      nil -> drop_random(board)
      col -> col
    end

    # case check_row_run(board, :left, 3) do
    #   nil ->
    #     case check_row_run(board, :left, 2) do
    #       nil ->
    #         case check_row_run(board, :left, 1) do
    #           nil -> 
    #             # TODO: switch to columns here
    #             drop_random(board)
    #           col -> col
    #         end
    #       col -> col
    #     end
    #   col -> col
    # end
  end

  defp check_row_run(board, :left, 0), do: drop_random(board)

  defp check_row_run(board, :left, run_size) do
    result =
      board
      |> Enum.with_index
      |> Enum.find_value(&(find_start_coordinate(&1, run_size)))

    col = case result do
      nil -> nil
      {column_index, row_index} when column_index > 0 ->
        # check the left side
        case Helper.at_coordinate(board, {column_index - 1, row_index}) do
          0 ->
            # drop it here
            # Helper.drop(board, column_index - 1)
            column_index - 1
          _ -> nil
        end
      _ -> nil
    end

    case col do
      # nil -> check_row_run(board, :right, run_size)
      nil -> check_column_run(board, run_size)
      _ -> col
    end
  end

  defp check_column_run(board, run_size) do
    rotated_board = 
      board
      |> Enum.with_index
      |> Enum.reduce(Enum.map(1..7, fn _ -> [] end), fn {row, row_index}, acc ->
           Enum.zip(acc, row)
           |> Enum.map(fn {list, value} -> list ++ [value] end)
         end)

    result =
      rotated_board
      |> Enum.with_index
      |> Enum.find_value(&(find_start_coordinate(&1, run_size)))

    col = case result do
      nil -> nil
      {row_index, column_index} when row_index > 0 ->
        case Helper.at_coordinate(rotated_board, {row_index - 1, column_index}) do
          0 ->
            # Drop it here
            # row_index - 1
            column_index
          _ -> nil
        end
      _ -> nil
    end

    case col do
      nil -> check_row_run(board, :right, run_size)
      _ -> col
    end
  end

  defp check_row_run(board, :right, run_size) do
    result =
      board
      |> Enum.with_index
      |> Enum.find_value(&(find_start_coordinate(&1, run_size)))

    col = case result do
      nil -> nil
      {column_index, row_index} when column_index < 7 - run_size ->
        # check the left side
        end_index = column_index + run_size - 1
        case Helper.at_coordinate(board, {end_index + 1, row_index}) do
          0 ->
            # drop it here
            # Helper.drop(board, end_index + 1)
            end_index + 1
          _ -> nil
        end
      _ -> nil
    end

    case col do
      nil -> check_row_run(board, :left, run_size - 1)
      _ -> col
    end
  end



  defp drop_random(board) do
    random_column =
      board
      |> Enum.at(0)
      |> Enum.with_index
      |> Enum.filter(&(elem(&1, 0) == 0))
      |> Enum.map(&(elem(&1, 1)))
      |> Enum.random

    random_column
  end

  @doc "Find a place in a list of values where a string of 4 identical non-0s occurs."
  defp find_start_coordinate({row, row_index}, row_size) do
    find_start_coordinate(row, {0, row_index}, nil, 0, row_size, 0)
  end
  defp find_start_coordinate(_, {column_index, row_index}, _, _, row_size, count) when count == row_size do
    {column_index, row_index}
  end
  defp find_start_coordinate([], _, _, _, _, _), do: false
  defp find_start_coordinate([first | rest], {column_index, row_index}, char, index, row_size, count) when first == char do
    find_start_coordinate(rest, {column_index, row_index}, char, index + 1, row_size, count + 1)
  end
  defp find_start_coordinate([0 | rest], {column_index, row_index}, _, index, row_size, count) do
    find_start_coordinate(rest, {index, row_index}, nil, index + 1, row_size, 1)
  end
  defp find_start_coordinate([first | rest], {column_index, row_index}, _, index, row_size, count) do
    find_start_coordinate(rest, {index, row_index}, first, index + 1, row_size, 1)
  end


  defp move_number(board) do
    open_spaces =
      board
      |> List.flatten()
      |> Enum.filter(fn space -> space == 0 end)
      |> length()

    42 - open_spaces + 1
  end
end
