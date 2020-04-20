import React, { Component } from 'react'
import PropTypes from 'prop-types';

class Select extends Component {
  static propTypes = {
    title: PropTypes.string,
    selected: PropTypes.object,
    data: PropTypes.array,
    // onSelectChange: PropTypes.function
  };

  handleChange = (e) => {
    e.preventDefault()
    this.props.onSelect( e.target.value )
  }


  render() {
    const  sortedOptions = this.props.options.sort((opt1, opt2) => {
        if (opt1.disabledKey === opt2.disabledKey) {
          if (opt1[this.props.titleKey] < opt2[this.props.titleKey]) { return -1 }
          if (opt1[this.props.titleKey] > opt2[this.props.titleKey]) { return 1 }
          return 0
        } else {
          return opt1.disabledKey - opt2.disabledKey
        }




    })

    let options = sortedOptions.map( (option) => {
      const value = option[this.props.valueKey];
      return <option key={value} value={value} disabled={option.disabledKey} >
          { option[this.props.titleKey] }
        </option>;
    });
    options.unshift(<option key="all" value="all">{this.props.allTitle}</option>);

    return (
      <select value={this.props.value} onChange={this.handleChange}>
        { options }
      </select>
    );
  }
}



export default Select;