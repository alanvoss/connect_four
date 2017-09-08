defmodule ConnectFour.Contenders.PureDeterminism do
  use GenServer

  alias ConnectFour.BoardHelper

  def start(default) do
    GenServer.start(__MODULE__, default)
  end

  def handle_call(:name, _from, state) do
    {:reply, "PureDeterminism", state}
  end

  def handle_call({:move, [[0, b, c, d, e, f, g] | _]}, _from, state)
    when b in [1, 2] 
     and c in [1, 2]
     and d in [1, 2] 
     and e in [1, 2]
     and f in [1, 2]
     and g in [1, 2], do: {:reply, 0, state}

  def handle_call({:move, [[a, 0, c, d, e, f, g] | _]}, _from, state)
    when a in [1, 2] 
     and c in [1, 2]
     and d in [1, 2] 
     and e in [1, 2]
     and f in [1, 2]
     and g in [1, 2], do: {:reply, 1, state}

  def handle_call({:move, [[a, b, 0, d, e, f, g] | _]}, _from, state)
    when a in [1, 2]
     and b in [1, 2]
     and d in [1, 2] 
     and e in [1, 2]
     and f in [1, 2]
     and g in [1, 2], do: {:reply, 2, state}

  def handle_call({:move, [[a, b, c, 0, e, f, g] | _]}, _from, state)
    when a in [1, 2]
     and b in [1, 2] 
     and c in [1, 2]
     and e in [1, 2]
     and f in [1, 2]
     and g in [1, 2], do: {:reply, 3, state}

  def handle_call({:move, [[a, b, c, d, 0, f, g] | _]}, _from, state)
    when a in [1, 2]
     and b in [1, 2] 
     and c in [1, 2]
     and d in [1, 2]
     and f in [1, 2]
     and g in [1, 2], do: {:reply, 4, state}

  def handle_call({:move, [[a, b, c, d, e, 0, g] | _]}, _from, state)
    when a in [1, 2]
     and b in [1, 2] 
     and c in [1, 2]
     and d in [1, 2] 
     and e in [1, 2]
     and g in [1, 2], do: {:reply, 5, state}

  def handle_call({:move, [[a, b, c, d, e, f, 0] | _]}, _from, state)
    when a in [1, 2]
     and b in [1, 2] 
     and c in [1, 2]
     and d in [1, 2] 
     and e in [1, 2]
     and f in [1, 2], do: {:reply, 6, state}

  def handle_call({:move, board}, _from, state) do
    choices =
      board
      |> available_columns
    
    case winning_columns(board, choices) do
      [winner | _] -> {:reply, winner, state}
      _ -> try_to_prevent_win(board, choices, state)
    end
  end
  
  def try_to_prevent_win(board, choices, state) do
    enemy_win_preventing_choices = 
      choices
      |> Enum.filter(fn choice ->
        with {:ok, new_board} <- BoardHelper.drop(board, 1, choice),
             flipped_board <- BoardHelper.flip(new_board),
             new_choices <- available_columns(flipped_board)
        do
          case winning_columns(flipped_board, new_choices) do
            [_winner | _] -> false
            _ -> true
          end
        else
          _ -> false
        end
      end)
    
    case enemy_win_preventing_choices do
      [enemy_win_preventer | _] -> {:reply, enemy_win_preventer, state}
      _ -> first_column(choices, state)
    end
  end
  
  def first_column([choice | _], state) do
    {:reply, choice, state}
  end
  
  defp available_columns([first_row | _]) do
    first_row
    |> Enum.with_index
    |> Enum.filter(&(elem(&1, 0) == 0))
    |> Enum.map(&(elem(&1, 1)))
  end
  
  defp winning_columns(board, choices) do
    choices
    |> Enum.filter(fn choice ->
      with {:ok, new_board} <- BoardHelper.drop(board, 1, choice),
           {:winner, _} <- BoardHelper.evaluate_board(new_board)
      do
        true
      else
        _ -> false
      end
    end)
  end
end
