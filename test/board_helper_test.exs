defmodule BoardHelperTest do
  use ExUnit.Case
  alias ConnectFour.BoardHelper

  test "new returns a 7 x 6 board" do
    board = BoardHelper.new
    assert length(board) == 6
    assert Enum.all?(board, &(length(&1) == 7))
  end

  @board [
    [0, 1, 0, 0, 1, 2, 1],
    [1, 2, 0, 0, 2, 1, 2],
    [2, 1, 0, 2, 1, 2, 2],
    [2, 1, 2, 2, 1, 2, 1],
    [1, 2, 1, 1, 2, 2, 1],
    [1, 1, 2, 2, 1, 1, 1]
  ]

  test "flip" do
    board = BoardHelper.flip(@board)
    assert board == [
      [0, 2, 0, 0, 2, 1, 2],
      [2, 1, 0, 0, 1, 2, 1],
      [1, 2, 0, 1, 2, 1, 1],
      [1, 2, 1, 1, 2, 1, 2],
      [2, 1, 2, 2, 1, 1, 2],
      [2, 2, 1, 1, 2, 2, 2]
    ]
  end

  describe "drop" do
    test "valid drop" do
      assert BoardHelper.drop(@board, 1, 2) == {:ok, [
        [0, 1, 0, 0, 1, 2, 1],
        [1, 2, 0, 0, 2, 1, 2],
        [2, 1, 1, 2, 1, 2, 2],
        [2, 1, 2, 2, 1, 2, 1],
        [1, 2, 1, 1, 2, 2, 1],
        [1, 1, 2, 2, 1, 1, 1]
      ]}
    end

    test "invalid drop" do
      assert BoardHelper.drop(@board, 2, 1) == {:error, "non-allowed move"}
    end
  end

  describe "get_diagonal_coordinates" do
    board = BoardHelper.new
    assert BoardHelper.get_diagonal_coordinates(board) == [
      [{0,3},{1,2},{2,1},{3,0}],
      [{0,4},{1,3},{2,2},{3,1},{4,0}],
      [{0,5},{1,4},{2,3},{3,2},{4,1},{5,0}],
      [{1,5},{2,4},{3,3},{4,2},{5,1},{6,0}],
      [{2,5},{3,4},{4,3},{5,2},{6,1}],
      [{3,5},{4,4},{5,3},{6,2}],
      [{6,3},{5,2},{4,1},{3,0}],
      [{6,4},{5,3},{4,2},{3,1},{2,0}],
      [{6,5},{5,4},{4,3},{3,2},{2,1},{1,0}],
      [{5,5},{4,4},{3,3},{2,2},{1,1},{0, 0}],
      [{4,5},{3,4},{2,3},{1,2},{0,1}],
      [{3,5},{2,4},{1,3},{0,2}]
    ]
  end

  test "at_coordinate" do
    assert BoardHelper.at_coordinate(@board, {3,5}) == 2
    assert BoardHelper.at_coordinate(@board, {1,3}) == 1
    assert BoardHelper.at_coordinate(@board, {0,0}) == 0
  end

  test "is_valid_coordinate?" do
    assert BoardHelper.is_valid_coordinate?({3, 5})  == true
    assert BoardHelper.is_valid_coordinate?({1, 3})  == true
    assert BoardHelper.is_valid_coordinate?({0, 0})  == true
    assert BoardHelper.is_valid_coordinate?({6, 5})  == true
    assert BoardHelper.is_valid_coordinate?({-1, 4}) == false
    assert BoardHelper.is_valid_coordinate?({2, -1}) == false
    assert BoardHelper.is_valid_coordinate?({7, 5})  == false
    assert BoardHelper.is_valid_coordinate?({3, 7})  == false
  end

  describe "evaluate horizontal winner" do
    @board [
      [0, 1, 0, 0, 1, 2, 1],
      [1, 2, 0, 0, 2, 1, 2],
      [2, 1, 0, 1, 1, 2, 2],
      [2, 1, 2, 2, 2, 2, 1],
      [1, 2, 1, 1, 1, 2, 1],
      [1, 1, 2, 2, 1, 1, 1]
    ]

    @winning_coordinates [{2, 3}, {3, 3}, {4, 3}, {5, 3}]

    test "evaluate_board should pass" do
      assert BoardHelper.evaluate_board(@board) ==
        {:winner, @winning_coordinates}
    end

    test "evaluate_rows should pass" do
      assert BoardHelper.evaluate_rows(@board) ==
        {:winner, @winning_coordinates}
    end

    test "evaluate_columns should fail" do
      assert BoardHelper.evaluate_columns(@board) == nil
    end

    test "evaluate_diagonals should fail" do
      assert BoardHelper.evaluate_diagonals(@board) == nil
    end

    test "evaluate_tie should fail" do
      assert BoardHelper.evaluate_tie(@board) == nil
    end
  end

  describe "evaluate vertical winner" do
    @board [
      [0, 1, 0, 0, 1, 2, 1],
      [1, 2, 0, 0, 2, 1, 2],
      [2, 1, 0, 2, 1, 2, 2],
      [2, 1, 0, 2, 1, 2, 1],
      [1, 2, 1, 1, 1, 2, 1],
      [1, 1, 2, 2, 1, 1, 1]
    ]

    @winning_coordinates [{4, 2}, {4, 3}, {4, 4}, {4, 5}]

    test "evaluate_board should pass" do
      assert BoardHelper.evaluate_board(@board) ==
        {:winner, @winning_coordinates}
    end

    test "evaluate_rows should fail" do
      assert BoardHelper.evaluate_rows(@board) == nil
    end

    test "evaluate_columns should pass" do
      assert BoardHelper.evaluate_columns(@board) ==
        {:winner, @winning_coordinates}
    end

    test "evaluate_diagonals should fail" do
      assert BoardHelper.evaluate_diagonals(@board) == nil
    end

    test "evaluate_tie should fail" do
      assert BoardHelper.evaluate_tie(@board) == nil
    end
  end

  describe "evaluate diagonal up and to the right winner" do
    @board [
      [0, 1, 0, 0, 1, 2, 1],
      [1, 2, 0, 0, 2, 2, 2],
      [2, 1, 0, 2, 1, 2, 2],
      [2, 1, 0, 1, 2, 1, 1],
      [1, 2, 1, 1, 1, 2, 1],
      [1, 1, 2, 2, 1, 1, 1]
    ]

    @winning_coordinates [{1, 5}, {2, 4}, {3, 3}, {4, 2}]

    test "evaluate_board should pass" do
      assert BoardHelper.evaluate_board(@board) ==
        {:winner, @winning_coordinates}
    end

    test "evaluate_rows should fail" do
      assert BoardHelper.evaluate_rows(@board) == nil
    end

    test "evaluate_columns should fail" do
      assert BoardHelper.evaluate_columns(@board) == nil
    end

    test "evaluate_diagonals should pass" do
      assert BoardHelper.evaluate_diagonals(@board) ==
        {:winner, @winning_coordinates}
    end

    test "evaluate_tie should fail" do
      assert BoardHelper.evaluate_tie(@board) == nil
    end
  end

  describe "evaluate diagonal up and to the left winner" do
    @board [
      [0, 1, 2, 0, 1, 2, 1],
      [1, 2, 1, 2, 1, 2, 2],
      [2, 1, 2, 1, 2, 1, 2],
      [2, 1, 1, 1, 2, 2, 1],
      [1, 2, 1, 1, 1, 2, 1],
      [1, 1, 2, 2, 1, 1, 1]
    ]

    @winning_coordinates [{5, 3}, {4, 2}, {3, 1}, {2, 0}]

    test "evaluate_board should pass" do
      assert BoardHelper.evaluate_board(@board) ==
        {:winner, @winning_coordinates}
    end

    test "evaluate_rows should fail" do
      assert BoardHelper.evaluate_rows(@board) == nil
    end

    test "evaluate_columns should fail" do
      assert BoardHelper.evaluate_columns(@board) == nil
    end

    test "evaluate_diagonals should pass" do
      assert BoardHelper.evaluate_diagonals(@board) ==
        {:winner, @winning_coordinates}
    end

    test "evaluate_tie should fail" do
      assert BoardHelper.evaluate_tie(@board) == nil
    end
  end

  describe "evaluate tie" do
    @board [
      [1, 2, 2, 2, 1, 2, 1],
      [1, 2, 1, 1, 1, 2, 2],
      [2, 1, 2, 2, 1, 2, 1],
      [2, 1, 2, 2, 2, 1, 1],
      [1, 2, 1, 1, 1, 2, 2],
      [1, 1, 2, 2, 1, 2, 1]
    ]

    test "evaluate_board should tie" do
      assert BoardHelper.evaluate_board(@board) == :tie
    end

    test "evaluate_rows should fail" do
      assert BoardHelper.evaluate_rows(@board) == nil
    end

    test "evaluate_columns should fail" do
      assert BoardHelper.evaluate_columns(@board) == nil
    end

    test "evaluate_diagonals should fail" do
      assert BoardHelper.evaluate_diagonals(@board) == nil
    end

    test "evaluate_tie should fail" do
      assert BoardHelper.evaluate_tie(@board) == :tie
    end
  end
end
