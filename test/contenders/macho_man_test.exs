defmodule ConnectFour.Contenders.MachoManTest do
  alias ConnectFour.Contenders.MachoMan
  use ExUnit.Case, async: true

  @moduletag :focus

  # test "puts piece in first column that is not full" do
  #   board = [
  #     [0, 1, 0, 0, 1, 2, 1],
  #     [0, 2, 0, 0, 2, 1, 2],
  #     [0, 1, 0, 2, 1, 2, 2],
  #     [0, 1, 2, 2, 1, 2, 1],
  #     [1, 2, 1, 1, 2, 2, 1],
  #     [1, 1, 2, 2, 1, 1, 1]
  #   ]

  #   MachoMan.choose_column board == 3
  # end
  test "puts piece in first column that has at least 4 spaces open" do
    board = [
      [0, 1, 0, 0, 1, 0, 1],
      [0, 2, 0, 0, 1, 1, 2],
      [0, 1, 0, 2, 2, 2, 2],
      [0, 1, 2, 2, 1, 2, 1],
      [2, 2, 1, 1, 2, 2, 1],
      [1, 1, 2, 2, 1, 1, 1]
    ]

    assert MachoMan.choose_column(board) == 0
  end
  test "puts piece in first column that has 3 spaces open if the top piece is macho man's" do
    board = [
      [1, 1, 0, 1, 0, 2, 1],
      [2, 2, 0, 1, 0, 1, 2],
      [2, 1, 0, 2, 1, 2, 2],
      [2, 1, 1, 2, 1, 2, 1],
      [1, 2, 2, 1, 2, 2, 1],
      [1, 1, 2, 2, 1, 1, 1]
    ]

    assert MachoMan.choose_column(board) == 2
  end
  test "puts piece in first column that has 2 spaces open if the top piece is macho man's" do
    board = [
      [1, 1, 0, 1, 0, 2, 1],
      [2, 2, 0, 1, 0, 1, 2],
      [2, 1, 1, 2, 1, 2, 2],
      [2, 1, 1, 2, 1, 2, 1],
      [1, 2, 2, 1, 2, 2, 1],
      [1, 1, 2, 2, 1, 1, 1]
    ]

    assert MachoMan.choose_column(board) == 2
  end
  test "puts piece in first column that has 1 spaces open if the top piece is macho man's" do
    board = [
      [1, 1, 0, 1, 0, 2, 1],
      [2, 2, 1, 1, 0, 1, 2],
      [2, 1, 1, 2, 1, 2, 2],
      [2, 1, 1, 2, 1, 2, 1],
      [1, 2, 2, 1, 2, 2, 1],
      [1, 1, 2, 2, 1, 1, 1]
    ]

    assert MachoMan.choose_column(board) == 2
  end
end
