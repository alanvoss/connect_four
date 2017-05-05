defmodule BoardHelperTest do
  use ExUnit.Case
  alias ConnectFour.BoardHelper

  @board [
    [0, 1, 0, 0, 1, 2, 1],
    [1, 2, 0, 0, 2, 1, 2],
    [2, 1, 0, 2, 1, 2, 2],
    [2, 1, 2, 2, 1, 2, 1],
    [1, 2, 1, 1, 2, 2, 1],
    [1, 1, 2, 2, 1, 1, 1]
  ]

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
end
