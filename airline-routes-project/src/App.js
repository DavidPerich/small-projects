import React, { Component } from 'react';
import './App.css';
import  DATA from './data'
import Table from './components/table'
import Select from './components/select'
import Map from './components/map'

class App extends Component {
  defaultState = {
      airline: "all",
      airport: "all",
  }

  state = Object.assign({}, this.defaultState)

  formatValue = (property, value) =>  {
    if (property === "airline") {
      return DATA.getAirlineById(value).name
    } else {
      return DATA.getAirportByCode(value).name
    }
  }

  handleAirportChange = (code) => {
    this.setState({ airport: code})
  }

  handleAirlineChange = (id) => {
    if (id !== "all") { id =  Number(id) }
    this.setState({ airline: id})
  }

  clearFilters = () => {
    this.setState(Object.assign({}, this.defaultState))
  }

  routeHasCurrentAirline = (route) => {
    return this.state.airline === route.airline || this.state.airline === "all"
  }

  routeHasCurrentAirport = (route) => {
    return this.state.airport === "all" || this.state.airport === route.src || this.state.airport === route.dest
  }

  render() {
    const filteredRoutes = DATA.routes.filter((route) => {
         return this.routeHasCurrentAirline(route) && this.routeHasCurrentAirport(route)
      });

    const filteredAirlines = DATA.airlines.map( (airline) => {
      if (filteredRoutes.some( (route) => route.airline === airline.id )) {
        return Object.assign({}, airline, { disabledKey: false });
      } else {
        return Object.assign({}, airline, { disabledKey: true });
      }
    });

    const filteredAirports = DATA.airports.map( (airport) => {
      if (filteredRoutes.some( (route) => route.src === airport.code || route.dest === airport.code )) {
        return Object.assign({}, airport, { disabledKey: false });
      } else {
        return Object.assign({}, airport, { disabledKey: true });
      }
    });


    const columns = [
      {name: 'Airline', property: 'airline'},
      {name: 'Source Airport', property: 'src'},
      {name: 'Destination Airport', property: 'dest'},
    ];

    return (
      <div className="app">
        <header className="header">
          <h1 className="title">Airline Routes</h1>
        </header>
        <br/>
        <section>
          <Map
          routes={filteredRoutes}
          airports={filteredAirports}
        />
        <p>
            Show routes on
            <Select
                options={filteredAirlines}
                valueKey="id"
                titleKey="name"
                disabledKey="active"
                allTitle="All Airlines"
                value={this.state.airline}
                onSelect={this.handleAirlineChange}
            />
            flying in or out of
            <Select
                options={filteredAirports}
                valueKey="code"
                titleKey="name"
                disabledKey="active"
                allTitle="All Airports"
                value={this.state.airport}
                onSelect={this.handleAirportChange}
            />
            <button onClick={this.clearFilters} >Show All Routes</button>
          </p>
        </section>
        <section>
          <h3>Number of Matching Routes: {filteredRoutes.length}</h3>
        </section>
        <section>
            < Table
              columns={columns}
              rows={filteredRoutes}
              format={this.formatValue}
              perPage={25}
            />
        </section>

      </div>
    );
  }
}

export default App;