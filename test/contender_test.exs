defmodule ContenderTest do
  use ExUnit.Case

  {:ok, modules} = :application.get_key(:connect_four, :modules)

  modules
  |> Enum.filter(&(String.starts_with?(Atom.to_string(&1), "Elixir.ConnectFour.Contenders")))
  |> Enum.each(fn module_name ->
       test_module = Atom.to_string(module_name) <> "Test" |> String.to_atom
       defmodule test_module do
         use ExUnit.Case
         use GenServer

         setup do
           {:ok, pid} = apply(unquote(module_name), :start, [nil])
           %{pid: pid}
         end

         describe ":name" do
           test "responds with a team name", %{pid: pid} do
             name = GenServer.call(pid, :name)
             assert is_binary(name)
             assert name != ""
           end
         end

         describe ":move" do
           @board [
             [2, 1, 0, 1, 1, 2, 1],
             [1, 2, 0, 2, 2, 1, 2],
             [2, 1, 0, 2, 1, 2, 2],
             [2, 1, 2, 2, 1, 2, 1],
             [1, 2, 1, 1, 2, 2, 1],
             [1, 1, 2, 2, 1, 1, 1]
           ]

           test "when only one choice left, calls that column", %{pid: pid} do
             assert GenServer.call(pid, {:move, @board}) == 2
           end

           @board [
             [0, 1, 0, 0, 1, 2, 1],
             [1, 2, 0, 0, 2, 1, 2],
             [2, 1, 0, 2, 1, 2, 2],
             [2, 1, 2, 2, 1, 2, 1],
             [1, 2, 1, 1, 2, 2, 1],
             [1, 1, 2, 2, 1, 1, 1]
           ]

           test "when a few choices remain, calls only eligible columns", %{pid: pid} do
             assert GenServer.call(pid, {:move, @board}) in [0,2,3]
           end

           @board [
             [0, 0, 0, 0, 0, 0, 0],
             [0, 0, 0, 0, 0, 0, 0],
             [0, 0, 0, 0, 0, 0, 0],
             [0, 0, 0, 0, 0, 0, 0],
             [0, 0, 0, 0, 0, 0, 0],
             [0, 0, 0, 0, 0, 0, 0]
           ]

           test "on an empty board, a number from 0-6 is returned", %{pid: pid} do
             assert GenServer.call(pid, {:move, @board}) in 0..6
           end
         end
       end
     end)
end
