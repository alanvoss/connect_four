defmodule Player3HelperTest do
  use ExUnit.Case
  alias ConnectFourEngine.Contenders.Player3

  def sigil_b(string, []) do
    string
    |> String.split("\n")
    |> Enum.reject( fn r -> String.trim(r) == "" end)
    |> Enum.map( fn r ->
      r
      |> String.split(",")
      |> Enum.map( fn c ->
        c
        |> String.trim
        |> String.to_integer
      end)
    end)
  end

  test "the sigil" do
    b = ~b(
      1, 2, 3,  4,  5,  6
      7, 8, 9, 10, 11, 12
    )

    assert b == [
      [1,2,3,4,5,6],
      [7,8,9,10,11,12]
    ]
  end

  describe "winners_and_losers" do
    test "it returns vertical winners and losers" do
      board = ~b(
        0,0,0,0,0,0,0
        1,0,0,0,0,0,0
        2,2,0,0,2,2,2
        1,1,1,2,1,1,1
        1,1,1,2,1,1,1
        1,1,1,2,1,1,1
      )

      {winners, losers} = Player3.winners_and_losers(board, 1)

      winning_cols = winners
      |> Enum.map(&elem(&1,0))

      losing_cols = losers
      |> Enum.map(&elem(&1,0))

      assert winning_cols == [2,3]
      assert losing_cols == [0,1,4,5,6]
    end

    test "it returns horizontal winners and losers" do
      board = ~b(
        0,0,0,0,0,0,0
        0,0,0,0,0,0,0
        0,0,0,0,0,0,0
        0,0,0,0,0,0,0
        0,0,0,0,0,0,0
        0,0,1,1,1,0,0
      )

      {winners, losers} = Player3.winners_and_losers(board, 1)

      winning_cols = winners
      |> Enum.map(&elem(&1,0))

      losing_cols = losers
      |> Enum.map(&elem(&1,0))

      assert winning_cols == [1,5]
      assert losing_cols == [0,2,3,4,6]
    end

    test "it returns diagonalwinners and losers" do
      board = ~b(
        0,0,0,0,0,0,0
        0,0,0,0,0,0,0
        0,0,0,0,0,0,0
        0,0,1,2,0,0,0
        0,1,1,2,0,0,0
        1,2,2,2,1,0,0
      )

      {winners, losers} = Player3.winners_and_losers(board, 1)

      winning_cols = winners
      |> Enum.map(&elem(&1,0))

      losing_cols = losers
      |> Enum.map(&elem(&1,0))

      assert winning_cols == [3]
      assert losing_cols == [0,1,2,4,5,6]
    end
  end
end
