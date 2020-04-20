import React from "react";
import { connect } from "react-redux";
import Board from "./Board";
import * as actions from "../../actions/BoardActions";

const mapStateToProps = (state, ownProps) => {
  const id = Number(ownProps.match.params.id);
  const matchingBoard = state.boards.find(board => board.id === id);
  return {
    board: matchingBoard
  };
};

const mapDispatchToProps = (dispatch, ownProps) => {
  const id = Number(ownProps.match.params.id);
  return {
    onFetchBoard: () => {
      dispatch(actions.fetchBoard(id)).catch(error => console.log(error)); // do we need this?
    }
  };
};

class BoardContainer extends React.Component {
  componentDidMount() {
    this.props.onFetchBoard();
  }

  render() {
    if (this.props.board) {
      return <Board board={this.props.board} />;
    }
    return null;
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(BoardContainer);
