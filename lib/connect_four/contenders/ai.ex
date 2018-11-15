defmodule ConnectFour.Contenders.AI do
  use GenServer
  alias ConnectFour.BoardHelper

  @middle_position 4
  @columns [0, 1, 2, 3, 4, 5, 6]

  def start(default) do
    GenServer.start(__MODULE__, default)
  end

  def handle_call(:name, _from, state) do
    {:reply, "EricEdLuke", state}
  end

  def handle_call({:move, board}, _from, state) do
    column_choice = can_win?(board) || can_block?(board) ||
      for column <- priority_moves(board) do
        # ensure valid move
        with {:ok, test_board} <- BoardHelper.drop(board, 1, column) do
          # if next move would open up a win for the other player, don't consider than an option
          case !can_block?(test_board) do
            false -> nil
            true  -> column
          end
        else
          _ -> nil
        end
      end
      |> Enum.find(fn x -> x end)

    {:reply, column_choice, state}
  end

  defp priority_moves(board) do
    moves =
      @columns
      |> Enum.to_list
      |> Enum.shuffle

    case middle_open?(board) do
      true  -> [@middle_position] ++ (moves -- [@middle_position])
      false -> moves
    end
  end

  defp can_win?(board, player \\ 1) do
    @columns
    |> Enum.find fn column ->
      with {:ok, board} <- BoardHelper.drop(board, player, column),
           {:winner, coors} <- BoardHelper.evaluate_board(board) do
        column
      else
        _ -> nil
      end
    end
  end

  defp can_block?(board, player \\ 2) do
    can_win?(board, player)
  end

  defp middle_open?(board) do
    0 == BoardHelper.at_coordinate(board, {@middle_position, 0})
  end
end
