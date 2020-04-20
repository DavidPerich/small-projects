export default function listsReducer(state = [], action) {
  if (action.type === "FETCH_BOARD_SUCCESS") {
    const excludedLists = state.filter(list => list.board_id !== action.board.id);
    let { lists, ...boardWithoutLists } =  action.board
    lists = lists.map(list => { list.title, list.id })

    return excludedLists.concat(lists);
  } else {
    return state;
  }
}