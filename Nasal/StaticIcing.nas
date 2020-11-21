#############################################################################
# This file is part of FlightGear, the free flight simulator
# http://www.flightgear.org/
#
# Copyright (C) 2009 Torsten Dreyer, Torsten (at) t3r _dot_ de
# modified and used for C182S by B. Hallinger 2020
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#############################################################################

#########################################################################################
# Fail the primary static ports on the fuselage due to icing
# Maintainer: Torsten Dreyer (Torsten at t3r dot de)
#
# inputs
# /systems/static[n]/icing
#
# outputs
# /systems/static/serviceable
#########################################################################################

var StaticIcingHandler = {};
StaticIcingHandler.new = func {
  var m = {};
  m.parents = [StaticIcingHandler];

  m.failAtIcelevel = arg[1];

  m.baseNodeName = "/systems/static[" ~ arg[0] ~ "]";

  print( "creating StaticIcingHandler for " ~ m.baseNodeName );

  m.baseN = props.globals.getNode( m.baseNodeName );

  m.icingN = m.baseN.initNode( "icing", 0.0 );

  m.serviceableN = m.baseN.initNode( "serviceable", 1, "BOOL" );

  setlistener( m.icingN, func { m.listener() } );

  return m;
};

#########################################################################################
# The handler. Check if ice is above threshold, then fail the device
#########################################################################################

StaticIcingHandler.listener = func {

  if( me.icingN.getValue() < me.failAtIcelevel ) {
    # everything is fine

    if( me.serviceableN.getBoolValue() == 0 ) {
      # if the static failed before, re-enable it
      #print( me.baseNodeName ~ " is functional again" );
      me.serviceableN.setBoolValue( 1 );
    }

  } else {
    # static port is iced

    if( me.serviceableN.getBoolValue() != 0 ) {
      # if the indicator was servicable before, fail it now
      #print( me.baseNodeName ~ " is failing" );
      me.serviceableN.setBoolValue( 0 );
    }

  }
};

# Fail static at 0.05" of ice
# Note: without static, the pitot will also block. When only the pitot is iced, it can be heated.
StaticIcingHandler.new( 0, 0.05 );
