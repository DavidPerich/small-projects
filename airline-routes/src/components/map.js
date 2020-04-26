import React, { Component } from 'react'

class Map extends Component {
  render() {
    const routesWithCoordinates = this.props.routes.map((route) => {
        let newRoute = Object.assign({}, route)
        newRoute.src = this.props.airports.find(airport => airport.code === newRoute.src )
        newRoute.dest = this.props.airports.find(airport => airport.code === newRoute.dest )

        return newRoute
      })

    return (
      <svg className="map" viewBox="-180 -90 360 180">
      <g transform="scale(1 -1)">
        <image xlinkHref="equirectangular_world.jpg" href="equirectangular_world.jpg" x="-180" y="-90" height="100%" width="100%" transform="scale(1 -1)"/>

        {routesWithCoordinates.map((route) => (
            <g key={"map-" + route.airline + route.src.code + route.dest.code}>
              <circle className="source" cx={route.src.long} cy={route.src.lat}>
                <title></title>
              </circle>
              <circle className="destination" cx={route.dest.long} cy={route.dest.lat}>
                <title></title>
              </circle>
              <path d={`M${route.src.long} ${route.src.lat} L ${route.dest.long} ${route.dest.lat}`} />
            </g>
          ))
        }

      </g>
    </svg>
    )
  }
}

export default Map
