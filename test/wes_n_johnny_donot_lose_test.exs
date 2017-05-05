defmodule WesNJohnnyDonotLoseTest do
  use ExUnit.Case
  alias ConnectFour.BoardHelper
  alias ConnectFour.Contenders.WesNJohnny

  @board [
    [0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0],
    [2, 2, 2, 0, 0, 0, 0],
  ]

  describe "donot lose" do
    @tag :wip
    test "returns blocker" do
      assert WesNJohnny.find_loser(@board) == 3
    end

    # test "invalid drop" do
    #   assert BoardHelper.drop(@board, 2, 1) == {:error, "non-allowed move"}
    # end
  end
end
