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
var cargo7 = {};
var cargo8 = {};
var cargo9 = {};
var cargo10 = {};
var cargo11 = {};
var cargo12 = {};
var cargo13 = {};
var cargo14 = {};
var cargo15 = {};
var cargo16 = {};
var cargo17 = {};
var cargo18 = {};
var cargo19 = {};
var cargo20 = {};
var cargo21 = {};
var cargo22 = {};
var cargo23 = {};
var cargo24 = {};
var cargo25 = {};
var cargo26 = {};
var cargo27 = {};
var cargo28 = {};

#setlistener("/sim/signals/fdm-initialized", func (n) {

  #set initial position of the cargo models out of site and out of range
  var lat = getprop("/position/latitude-deg")-.0002;
  var lon = getprop("/position/longitude-deg")-.0002;
  var alt = -999;

  #property tree location of cargo models
  var model_path = "[addon=org.flightgear.addons.CGTOW]Models/stackablecargoset/";

  #                            offset ft    cargoheight m     harnessheight m
  #container-big    -3.879 m = 12.72        2.66              6.10
  #cub-ground       -3.209 m = 10.53        1.83              5.98
  #ground-tank      -3.737 m = 12.26        2.42              6.44
  #ground-tank-lg   -5.884 m = 18.58        4.18              6.02
  #ground-tank-tall -4.976 m = 16.32        3.69              6.02
  #tank-stand       -3.562 m = 11.68        2.12              6.08
  #pine-tree        -3.334 m = 10.93        2.08              6.12
  #dump-truck       -6.937 m = 22.76        9.3              10.59
  #micro-relay      -7.257 m = 23.81        5.98              6.06
  #micro-wave       -8.101 m = 26.58        5.99              6.99
  #tower-sec-one   -14.053 m = 46.14       12.81              8.52
  #tower-sec-two   -14.129 m = 46.35       12.94              8.52
  #tower-sec-three -14.323 m = 46.99       13.06              8.52
  #tower-sec-four  -14.416 m = 47.29       13.24              8.52
  #tower-sec-five  -14.436 m = 47.36       13.22              8.52
  #tower-sec-six   -14.435 m = 47.35       13.22              8.52
  #tower-sec-seven -14.469 m = 47.47       13.25              8.52
  #tower-radio    -162.331 m =532.58      173.63              8.52
  #radio-tower-sec -26.058 m = 85.49       24.84             16.75
  #mobile-pod       -4.059 m = 13.32        2.86             14.39

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
  cargo1 =  place_model( "1",    0, "container-big",    model_path,  2,     2.66,   1500, 2.66, 6.10, lat, lon, alt,    0, 0, 0, -1);
  cargo2 =  place_model( "2",    1, "container-big",    model_path,  0,     2.66,   1000, 2.66, 6.10, lat, lon, alt,    0, 0, 0, -1);
  cargo3 =  place_model( "3",    2, "container-big",    model_path,  1,     2.66,   5000, 2.66, 6.10, lat, lon, alt,    0, 0, 0, -1);
  cargo4 =  place_model( "4",    3, "ground-tank",      model_path, 15,     6.44,   2000, 2.42, 6.44, lat, lon, alt,    0, 0, 0, -1);
  cargo5 =  place_model( "5",    4, "ground-tank-lg",   model_path, 15,     6.02,   4200, 4.18, 6.02, lat, lon, alt-90, 0, 0, 0, -1);
  cargo6 =  place_model( "6",    5, "ground-tank-tall", model_path, 15,     6.02,   3000, 3.69, 6.02, lat, lon, alt-90, 0, 0, 0, -1);
  cargo7 =  place_model( "7",    6, "tank-stand",       model_path,  0,     6.08,    250, 2.12, 6.08, lat, lon, alt-90, 0, 0, 0, -1);
  cargo8 =  place_model( "8",    7, "micro-relay",      model_path, 12,      0.0,    400, 5.98, 6.06, lat, lon, alt-90, 0, 0, 0, -1);
  cargo9 =  place_model( "9",    8, "micro-wave",       model_path, 13,      0.0,    400, 5.99, 6.99, lat, lon, alt-90, 0, 0, 0, -1);
  cargo10 = place_model("10",    9, "tower-sec-one",    model_path,  0,    12.81,   1400,12.81, 8.52, lat, lon, alt-90, 0, 0, 0, -1);
  cargo11 = place_model("11",   10, "tower-sec-two",    model_path,  9,    12.94,   1300,12.94, 8.52, lat, lon, alt-90, 0, 0, 0, -1);
  cargo12 = place_model("12",   11, "tower-sec-three",  model_path, 10,    13.06,   1200,13.06, 8.52, lat, lon, alt-90, 0, 0, 0, -1);
  cargo13 = place_model("13",   12, "tower-sec-four",   model_path, 11,    13.24,   1100,13.24, 8.52, lat, lon, alt-90, 0, 0, 0, -1);
  cargo14 = place_model("14",   13, "tower-sec-five",   model_path, 12,    13.22,   1000,13.22, 8.52, lat, lon, alt-90, 0, 0, 0, -1);
  cargo15 = place_model("15",   14, "tower-sec-six",    model_path, 13,    13.22,    950,13.22, 8.52, lat, lon, alt-90, 0, 0, 0, -1);
  cargo16 = place_model("16",   15, "tower-sec-seven",  model_path, 14,    13.25,    900,13.25, 8.52, lat, lon, alt-90, 0, 0, 0, -1);
  cargo17 = place_model("17",   16, "radio-tower-sec",  model_path, 22,    24.84,    500,24.84, 8.52, lat, lon, alt-90, 0, 0, 0, -1);
  cargo18 = place_model("18",   17, "radio-tower-sec",  model_path, 16,    24.84,    500,24.84, 8.52, lat, lon, alt-90, 0, 0, 0, -1);
  cargo19 = place_model("19",   18, "radio-tower-sec",  model_path, 17,    24.84,    500,24.84, 8.52, lat, lon, alt-90, 0, 0, 0, -1);
  cargo20 = place_model("20",   19, "radio-tower-sec",  model_path, 18,    24.84,    500,24.84, 8.52, lat, lon, alt-90, 0, 0, 0, -1);
  cargo21 = place_model("21",   20, "radio-tower-sec",  model_path, 19,    24.84,    500,24.84, 8.52, lat, lon, alt-90, 0, 0, 0, -1);
  cargo22 = place_model("22",   21, "radio-tower-sec",  model_path, 20,    24.84,    500,24.84, 8.52, lat, lon, alt-90, 0, 0, 0, -1);
  cargo23 = place_model("23",   22, "radio-tower-sec",  model_path, 21,    24.84,    500,24.84, 8.52, lat, lon, alt-90, 0, 0, 0, -1);
  cargo24 = place_model("24",   23, "wind-tower-base",  model_path,  0,    14.96,    600,14.96, 8.52, lat, lon, alt-90, 0, 0, 0, -1);
  cargo25 = place_model("25",   24, "wind-tower",       model_path, 23,    44.04,   1200,44.04, 8.52, lat, lon, alt-90, 0, 0, 0, -1);
  cargo26 = place_model("26",   25, "wind-tower-gen",   model_path, 24,     4.90,   1200, 4.90, 8.52, lat, lon, alt-90, 0, 0, 0, -1);
  cargo27 = place_model("27",   26, "wind-tower-hub",   model_path, 25,    37.83,   1200,60.91, 8.52, lat, lon, alt-90, 0, 0, 0, -1);
  cargo28 = place_model("28",   27, "tank",             model_path,  6,     1.00,    500, 3.00, 6.08, lat, lon, alt-90, 0, 0, 0, -1);

  cargo_init();

#});