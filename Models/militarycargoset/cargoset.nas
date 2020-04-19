# Cargo Towing - Cargo Towing capability for Flightgear
# Written and developer by Wayne Bragg (wlbragg)
# Copyright (C) 2020 Wayne Bragg
# cargoset.nas
# Version 1.0.0 beta 1/21/2020
# Cargo Towing is licensed under the Gnu Public License v3+ (GPLv3+)

#################### inject cargo models into the scene ####################

var cargo1 = {};
var cargo2 = {};
var cargo3 = {};
var cargo4 = {};
var cargo5 = {};
var cargo6 = {};

#setlistener("/sim/signals/fdm-initialized", func (n) {

  #set initial position of the cargo models out of site and out of range
  var lat = getprop("/position/latitude-deg")-.0002;
  var lon = getprop("/position/longitude-deg")-.0002;
  var alt = -999;

  #property tree location of cargo models
  var model_path = "[addon=org.flightgear.addons.CGTOW]Models/militarycargoset/";

  #                            offset ft    cargoheight m     harnessheight m
  #MVTR             -6.937 m = -10        9.3              10.59
 #Hummvee             -6.937 m = -10        9.3              10.59
 #105mm             -6.937 m = -10        1.4              10.59
 #Scimitar             -6.937 m = -10       2.1              6
 #Jackal             -6.937 m = -10       2.35              6
 #WMIK             -6.937 m = -10       2.0              6

  # there are three types of cargo depending on connection capability
  # 1) long line only
  #     (stack = 0, offset = distance from blender 0 z to cargo bottom z), alt = alt-90)
  # 2) long line and hard docked
  #     (stack = 0, offset = distance from blender 0 z to cargo bottom z), alt = def of -999
  # 3) stackable
  #     (stack = position of object it can stack on)
  #     (can be either 1 or 2 connection type, but is implemented only when in long line) 
  #     TODO: limit stackable to on long line only

  #use height in feet or *3.28 for ground
  #use height in feet or *3.28 or drop height for connection to stack

  #inject new cargo models into the scene                           stack   drop         height                              
  #                     itemnum index name              location    index   height  weight      harness                 
  cargo1 =  place_model( "1",    0, "MVTR",             model_path,  0,      .5,   29100,  3     ,16.9, lat, lon, alt-90, 0, 0, 0, -1);
 cargo2 =  place_model( "2",    1, "Hummvee",           model_path,  0,      .5,   5200,   1.9    ,6.23, lat, lon, alt-90, 0, 0, 0, -1);
 cargo3 =  place_model( "3",    2, "105mm",             model_path,  0,      .5,   4096,   1.4    ,6.1, lat, lon, alt-90, 0, 0, 0, -1);
 cargo4 =  place_model( "4",    3, "Scimitar",          model_path,  0,      .5,   15600,  2.1   ,6.0, lat, lon, alt-90, 0, 0, 0, -1);
 cargo5 =  place_model( "5",    4, "Jackal",            model_path,  0,      .5,   14896,  2.35  ,6.0, lat, lon, alt-90, 0, 0, 0, -1);
 cargo6 =  place_model( "6",    5, "WMIK",              model_path,  0,      .5,   6613,  2.0    ,6.0, lat, lon, alt-90, 0, 0, 0, -1);
  cargo_init();

#});