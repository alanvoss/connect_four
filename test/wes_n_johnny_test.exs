defmodule WesNJohnnyTest do
  use ExUnit.Case
  alias ConnectFour.BoardHelper
  alias ConnectFour.Contenders.WesNJohnny

  @board [
    [0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0],
    [1, 0, 0, 0, 0, 0, 0],
    [1, 0, 0, 0, 0, 0, 0],
    [1, 0, 0, 0, 0, 0, 0]
  ]

  describe "winner" do
    test "can we win" do
      assert BoardHelper.drop(@board, 1, 0) == {:ok,     [[0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0],
    [1, 0, 0, 0, 0, 0, 0],
    [1, 0, 0, 0, 0, 0, 0],
    [1, 0, 0, 0, 0, 0, 0],
    [1, 0, 0, 0, 0, 0, 0]]}
    end

    # test "invalid drop" do
    #   assert BoardHelper.drop(@board, 2, 1) == {:error, "non-allowed move"}
    # end
  end
end
