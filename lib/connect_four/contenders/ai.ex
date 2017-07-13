defmodule ConnectFour.Contenders.AI do
  use GenServer
  alias ConnectFour.BoardHelper

  def start(default) do
    GenServer.start(__MODULE__, default)
  end

  def handle_call(:name, _from, state) do
    {:reply, "EricEdLuke", state}
  end

  def handle_call({:move, board}, _from, state) do
    column_choice = can_win?(board) || can_block?(board) || (0..6 |> Enum.random)


  #  with {:ok, test_board} <- BoardHelper.drop(board, 1, column_choice) do
  #   if can_block?(test_board) do
  #     IO.puts("next block?")
  #     column_choice =
  #       0..6
  #       |> Enum.to_list
  #       |> Kernel.--([column_choice])
  #       |> Enum.random
  #   end
  # else
  # end


    # IO.puts("CHOICE #{column_choice}")

    {:reply, column_choice, state}
  end

  defp can_win?(board, player \\ 1) do
    0..6
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
end