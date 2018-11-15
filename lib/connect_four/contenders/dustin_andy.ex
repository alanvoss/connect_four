defmodule ConnectFour.Contenders.DustinAndy do
  use GenServer
  alias ConnectFour.BoardHelper

  def start(default) do
    GenServer.start(__MODULE__, default)
  end

  def handle_call(:name, _from, state) do
    # letters = for n <- ?A..?Z, do: n
    # random_name =
    #   for i <- 1..12 do
    #     Enum.random(letters)
    #   end

    {:reply, "DustinAndy", state}
  end

  def handle_call({:move, board}, _from, state) do

    random_column =
      board
      |> Enum.at(0)
      |> Enum.with_index
      # finding all the zeros
      |> Enum.filter(&(elem(&1, 0) == 0))
      |> Enum.map(&(elem(&1, 1)))
      |> Enum.random


      # iterate through each one and check if we 'win'
      # check if the opponent put a piece there and see if would win.

    columns = [0,1,2,3,4,5,6]
    column = 3
    {found_winner, column} = evaluate_us(columns, board)

    if found_winner == :false do
      {foundBlock, column} = evaluate_them(columns, board)
    end

    # how to count rows....

    {cell, index} = Enum.with_index(hd(board))
      |> Enum.filter(fn({cell, index}) -> cell==0 end )
      |> Enum.random

    # IO.puts "column: #{ column }, index: #{ index }"
    # System.halt(0)
    # IO.gets("column: #{ column }, index: #{ index }")
    {:reply, column || index, state}
  end

  defp evaluate_us(columns, board) do
    boards = Enum.map(columns, fn(column) ->
      case BoardHelper.drop(board, 1, column) do
        {:error, _} ->
          {:false, nil, nil}
        {:ok, newBoard} ->
          case BoardHelper.evaluate_board(newBoard) do
            {:winner, coords} -> {:winner, newBoard, column}
            _ -> {:false, nil, nil}
          end
      end
    end)


    winners = Enum.filter(boards, fn({status, board, column}) -> status==:winner end)

    column = if Enum.count(winners) > 0 do
      winner = hd(winners)
      # IO.inspect(winner)
      # IO.gets("winnr")
      {status, board, c} = winner
      {:true, c}
    else
      {:false, nil}
    end
  end

  defp evaluate_them(columns, board) do
    boards = Enum.map(columns, fn(column) ->
      case BoardHelper.drop(board, 2, column) do
        {:error, _} ->
          {:false, nil, nil}
        {:ok, newBoard} ->
          case BoardHelper.evaluate_board(newBoard) do
            {:winner, coords} -> {:winner, newBoard, column}
            _ -> {:false, nil, nil}
          end
      end
    end)

    winners = Enum.filter(boards, fn({status, board, column}) -> status==:winner end)

    column = if Enum.count(winners) > 0 do
      winner = hd(winners)
      {status, board, c} = winner
      {:true, c}
    else
      {:false, nil}
    end
  end

end
