import React, { Component } from 'react';


class Table extends Component {
  static defaultProps = {
    perPage: 25
  }

  constructor(...args) {
    super(...args)

    this.state = {
      page: 0,
    }
  }

  onNextPageClick = (e) => {
    e.preventDefault();
    this.setState({
      page: this.state.page + 1
    });
  }

  onPreviousPageClick = (e) => {
    e.preventDefault();
    this.setState({
      page: this.state.page - 1
    })
  }

  currentRows = () => {
    const start = this.props.perPage * this.state.page
    return this.props.rows.slice(start, start + this.props.perPage)
  }

  _pagenationInfo = () => {
    const start = this.props.perPage * this.state.page
    const totalRows = this.props.rows.length
    const perPage = this.props.perPage

    if (start + perPage >= totalRows) {
      return `Showing ${start}-${totalRows} of ${totalRows} routes`
    } else {
      return `Showing ${start}-${start + perPage} of ${totalRows} routes`
    }
  }

  _nextPageWillBeEmpty = () => {
    return (this.props.perPage * (this.state.page +1 )) >= this.props.rows.length - 1
  }


  render() {
    const format = this.props.format;

    return (
    <div>
    <table className="routes-table">
        <thead>
          <tr>
            {this.props.columns.map((column) => (
                <th key={column.name}>{column.name}</th>
              ))
            }
          </tr>
        </thead>
        <tbody>
          {this.currentRows().map((route) => (
            <tr key={route.airline + route.src + route.dest}>
              <td>{format("airline", route.airline)}</td>
              <td>{format("airport", route.src)}</td>
              <td>{format("airport", route.dest)}</td>
            </tr>
            ))
          }
        </tbody>
      </table>
      <div className="pagination">'
        <p>
        { this._pagenationInfo() }
        </p>
        <p>
          <button onClick={this.onPreviousPageClick} disabled={this.state.page <= 0} >
            Previous Page
          </button>
          <button onClick={this.onNextPageClick} disabled={this._nextPageWillBeEmpty() } >
            Next Page

          </button>
        </p>
      </div>
    </div>

    )
  }
}

export default Table;