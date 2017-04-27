# ConnectFour

A competition to find the ultimate AI bot to beat Connect Four.

## Installation

Fork the repo:

* https://github.com/alanvoss/connect_four

## Instructions

You have 1 hour to create the best bot that you can to play Connect Four.  The winner
will receive a prize of some sort (for those at the meetup for which this was programmed).

* try it out (might improve interface at some point)
  * you must run this in bash shell within no muxer for the colors to work properly

`> mix run -e 'ConnectFour.Controller.start_game(ConnectFour.Contenders.PureRandomness, ConnectFour.Contenders.PureRandomness)'`

* create a contender (`<project_root>/lib/connect_four/contenders`)
  * take a look at `PureRandomness` for some ideas
  * it needs to be a `GenServer` that responds to:
    * `:name:` (your team name)
    * `{:move, board}` `call`s (the column from 0-6 that you would like to put your piece into
  * utilize the BoardHelper for several helper functions that should simplify some common tasks
    * board evaluation
    * board creation
  * your `GenServer` can choose to store `state` if if wishes, but the full board will be passed each time.
    * `0` is an empty, eligible space / column
    * `1` is where you've moved previously
    * `2` is where your opponent has moved
  * test it against `PureRandomness`.  if you can't beat it 100% of the time...
  * your `GenServer` should respond to all calls within 5 seconds.  If not, you forfeit.
  * if your `GenServer` dies, tough luck.  There are no `Supervisor`s to keep you alive.
  * if you make a disallowed move (a column that is already full), you also forfeit.

* create a pull request

* we'll run a tournament with all the contenders to find the ultimate winner
