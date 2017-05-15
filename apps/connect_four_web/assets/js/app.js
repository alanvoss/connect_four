import "phoenix_html";
import socket from "./socket";
import channel from "./channel";
import React from "react";
import { render } from "react-dom";
import { combineReducers, createStore } from "redux";
import { connect, Provider } from "react-redux";

const board = (state = { board: [[], [], [], [], [], []] }, action) => {
  switch (action.type) {
    case "BOARD_UPDATED":
      return Object.assign({}, state, { board: action.body.board });
    default:
      return state;
  }
};

const gameStatus = (
  state = { player1: "", player2: "", winner: "", status: "waiting" },
  action
) => {
  switch (action.type) {
    case "BOARD_UPDATED":
      return Object.assign({}, state, {
        status: "in-progress",
        player1: action.body.player1,
        player2: action.body.player2
      });
    case "WINNER":
      return Object.assign({}, state, {
        status: "done",
        winner: action.body.name
      });
    case "TIE":
      return Object.assign({}, state, { status: "done", winner: "tie" });
    case "FORFEIT":
      return Object.assign({}, state, {
        status: "done",
        winner: `forfeit: ${action.body.name}`
      });
    default:
      return state;
  }
};

const winnerHistory = (state = [], action) => {
  switch (action.type) {
    case "WINNER":
      state.push({
        player1: action.body.player1,
        player2: action.body.player2,
        status: "winner",
        who: action.body.name
      });
      return state;
    case "TIE":
      state.push({
        player1: action.body.player1,
        player2: action.body.player2,
        status: "tie"
      });
      return state;
    case "FORFEIT":
      state.push({
        player1: action.body.player1,
        player2: action.body.player2,
        status: "forfeit",
        who: action.body.name
      });
      return state;
    default:
      return state;
  }
};

let reducer = combineReducers({ board, gameStatus, winnerHistory });
let store = createStore(
  reducer,
  window.__REDUX_DEVTOOLS_EXTENSION__ && window.__REDUX_DEVTOOLS_EXTENSION__()
);

channel.on("board", msg => {
  store.dispatch({ type: "BOARD_UPDATED", body: msg });
});
channel.on("forfeit", msg => {
  store.dispatch({ type: "FORFEIT", body: msg });
});
channel.on("tie", msg => {
  store.dispatch({ type: "TIE", body: msg });
});
channel.on("winner", msg => {
  store.dispatch({ type: "WINNER", body: msg });
});

const styles = {
  space: {
    borderRadius: 10,
    padding: 4,
    margin: 4,
    display: "inline-block",
    width: 20,
    height: 20,
    verticalAlign: "middle"
  },
  player1: {
    backgroundColor: "blue"
  },
  player2: {
    backgroundColor: "red"
  },
  board: {
    width: 28 * 7,
    height: 28 * 6,
    display: "block",
    backgroundColor: "#ccc"
  },
  winner: {
    fontWeight: "bold"
  }
};

let Space = ({ space }) => {
  return (
    <span style={Object.assign({}, styles.space, styles[`player${space}`])} />
  );
};

let Row = ({ row }) => {
  return (
    <div>
      {row.map((space, index) => <Space space={space} key={index} />)}
    </div>
  );
};

const WinnerRow = ({ game, winner: { player1, player2, status, who } }) => {
  return (
    <li>
      {game + 1}.
      <span>{player1} vs. {player2}</span>
      <div style={styles.winner}>{status}: {who}</div>
    </li>
  );
};

const WinnerHistory = ({ winnerHistory }) => {
  if (winnerHistory.length == 0) return <div />;
  return (
    <ul>
      {winnerHistory.map((winner, index) => (
        <WinnerRow winner={winner} key={index} game={index} />
      ))}
    </ul>
  );
};

const startBattle = () => {
  channel.push("start_battle", {});
};

let App = ({ board, player1, player2, status, winner, winnerHistory }) => {
  return (
    <div>
      <div>
        Player 1:
        {" "}
        {player1}
        {" "}
        <span style={Object.assign({}, styles.space, styles.player1)} />
      </div>
      <div>
        Player 2:
        {" "}
        {player2}
        {" "}
        <span style={Object.assign({}, styles.space, styles.player2)} />
      </div>
      <div style={styles.board}>
        {board.map((row, index) => <Row row={row} key={index} />)}
      </div>
      {status != "in-progress" &&
        <button onClick={startBattle}>Start Battle</button>}
      <WinnerHistory winnerHistory={winnerHistory} />
    </div>
  );
};

const mapStateToProps = ({ board, gameStatus, winnerHistory }) => {
  return {
    board: board.board,
    player1: gameStatus.player1,
    player2: gameStatus.player2,
    winner: gameStatus.winner,
    status: gameStatus.status,
    winnerHistory: winnerHistory
  };
};

const mapDispatchToProps = dispatch => {
  return {};
};

App = connect(mapStateToProps, mapDispatchToProps)(App);

render(
  <Provider store={store}>
    <App />
  </Provider>,
  document.getElementById("root")
);
