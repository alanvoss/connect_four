defmodule ConnectFour.Contenders.ConnectCrusher do
  use GenServer
  alias ConnectFour.BoardHelper

  def start(default) do
    GenServer.start(__MODULE__, default)
  end

  def handle_call(:name, _from, state) do
    {:reply, "Connect Crusher", state}
  end

  def handle_call({:move, board}, _from, state) do
    {:reply, find_column(board), state}
  end

  def find_column(board) do
    {column, _value} =
      find_plays(board)
      |> Enum.find(fn {column, value_at} -> value_at == 0 end)

    column
  end

  def find_plays(board) do
    plays()
    |> Enum.map(fn {row, column} ->
      { column, board |> BoardHelper.at_coordinate({row, column}) }
    end)
  end

  def plays do
    (6..0)
    |> Enum.map(&(&1))
    |> Enum.map(fn row ->
      (2..5)
      |> Enum.map(fn column ->
        {row, column}
      end)
    end)
    |> List.flatten
  end
end
