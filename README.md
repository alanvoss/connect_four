# ConnectFour

A competition to find the ultimate bot to beat Connect Four.

## Instructions

You will be given a time limit (somewhere around 1 1/2 hours) to create the best bot
that you can to play Connect Four.

* Find a friend or two with whom to pair program.
* Fork the repo:
  * https://github.com/alanvoss/connect_four
* try out an example match
  * `> bin/match PureRandomness PureRandomness`
* create a contender (`<project_root>/lib/connect_four/contenders`)
  * take a look at `PureRandomness` for some ideas
  * it needs to be a `GenServer` that responds to:
    * `call` `:name:` (return your team name)
    * `call` `{:move, board}` (return the column from 0-6 in which you'd like to play on this turn)
  * utilize the `BoardHelper` (and refer to the tests) for several functions that simplify some common tasks
    * board evaluation
    * board creation
    * piece at given coordinate
    * "what would the board look like if I dropped my piece in this column?"
    * etc.
  * your `GenServer` can choose to store `state` if if wishes, but the full board will be passed each time.
  * the board is a matrix of a `List` of 6 `List`s, 7 integers each (7 across, 6 down):
    * `0` is an empty, eligible space / column
    * `1` is where you've moved previously
    * `2` is where your opponent has moved
  * make sure to run tests
    * `> mix test`
    * if tests fail against your repo, you will be disqualified
  * test your bot against `PureRandomness`.  if you can't beat it 100% of the time...
    * `> bin/match PureRandomness YourBotModuleName`
    * the result map for the match will be displayed immediately following the winner announcement
      * this should help you with troubleshooting
      * you can visualize this result by:
        * `> iex -S mix`
        * `iex> ConnectFour.Controller.display_game(result, true)`
    * alternatively, you can start a battle (see below) and then display with "Watch the Battle" (see below)
  * your `GenServer` should respond to all calls within 5 seconds.  If not, you forfeit.
    * you are allowed to do as much background processessing as you want between calls.
    * you are allowed to spin up other processes.
    * the lifecyle of your bot will be around 10 seconds.
      * no supervisor will keep it alive (if your `GenServer` dies, tough luck)
      * it will be started each time a match with your (new) opponent begins
  * if you make a disallowed move (a column that is already full or out of bounds), you also forfeit.
* run tests again, just to be sure
  * `> mix test`
* create a pull request against the original repo's `elixirconf2017` branch
  * https://github.com/alanvoss/connect_four
* we'll run a tournament with all the contenders to find the ultimate winner.
  * run yourself to get a log of games played
  * `> bin/battle`

## Results

* results will be available for download in this folder:

  http://bit.ly/2eWQOLf

## Watch the battle

* if you copy the above "Results" folder contents into your cloned repo's `results/` folder
  * `> bin/display_games`
