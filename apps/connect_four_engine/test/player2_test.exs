defmodule Player2HelperTest do
  use ExUnit.Case
  alias ConnectFourEngine.Contenders.Player2

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

  describe "dangerous list" do
    test "lists with 3 or more of '2's are dangerous" do
      assert Player2.dangerous_list([0,1,2,2,2]) == true
    end

    test "lists without 3 or more of '2's are dangerous" do
      assert Player2.dangerous_list([0,1,2,2,1]) == false
    end
  end

  describe "block_rows" do
    test "a single row" do
      board = ~b(
        0,0,0,0,0,0,0
        0,0,2,2,2,1,1
      )
      assert Player2.block_rows(nil, board) == 1
    end

    test "a full board" do
      board = ~b(
        0,0,0,2,2,2,1
        0,0,1,1,2,2,2
        0,0,2,1,2,1,2
      )
      assert Player2.block_rows(nil, board) == 2
    end
  end

  describe "block columns" do
    test "a simple column with something to block" do
      board = ~b(
        0
        1
        1
        1
        2
      )
      assert Player2.block_columns(board) == 0
    end

    test "a simple column with nothing to block" do
      board = ~b(
        0
        1
        2
        1
        2
      )
      assert Player2.block_columns(board) == nil
    end

    test "a column that is too tall" do
      board = ~b(
        1
        1
        1
        2
      )
      assert Player2.block_columns(board) == nil
    end

    test "a full board with something to block" do
      board = ~b(
        0, 0, 2, 0, 1, 1, 1
        0, 0, 2, 1, 2, 1, 1
        0, 0, 2, 1, 1, 2, 2
        0, 0, 1, 1, 1, 1, 1
      )
      assert Player2.block_columns(board) == 3
    end
  end

  describe "left_block" do
    test "it returns nil for a row with nothing to block" do
      assert Player2.left_block({[0,0,2,2,1,2], 1}) == nil
    end
    test "it returns the leftmost place to block" do
      assert Player2.left_block({[0,0,2,2,2,1,2], 1}) == 1
    end
    test "it returns the leftmost _empty_ place to block" do
      assert Player2.left_block({[0,1,2,2,2,1,2], 1}) == nil
    end
  end
end
