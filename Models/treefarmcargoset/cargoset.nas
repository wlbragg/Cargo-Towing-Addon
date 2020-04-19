# Cargo Towing - Cargo Towing capability for Flightgear
# Written and developer by Wayne Bragg (wlbragg)
# Copyright (C) 2020 Wayne Bragg
# treefarmcargoset/cargoset.nas
# Version 1.0.0 beta 1/21/2020
# Cargo Towing is licensed under the Gnu Public License v3+ (GPLv3+)

#################### inject cargo models into the scene ####################

var cargo1 = {};
var cargo2 = {};
var cargo3 = {};
var cargo4 = {};
var cargo5 = {};
var cargo6 = {};

  #set initial position of the cargo models out of site and out of range
  var lat = getprop("/position/latitude-deg")-.0002;
  var lon = getprop("/position/longitude-deg")-.0002;
  var alt = -999;

  #property tree location of cargo models
  var model_path = "[addon=org.flightgear.addons.CGTOW]Models/treefarmcargoset/";

  #                      offset ft      cargoheight m     harnessheight m
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
  cargo1 = place_model("1",    0, "pine-tree",        model_path,  5,     0.0,     150, 2.08, 6.12, lat, lon, alt,    0, 0, 0, -1);
  cargo2 = place_model("2",    1, "pine-tree",        model_path,  5,     0.0,     150, 2.08, 6.12, lat, lon, alt,    0, 0, 0, -1);
  cargo3 = place_model("3",    2, "pine-tree",        model_path,  5,     0.0,     150, 2.08, 6.12, lat, lon, alt,    0, 0, 0, -1);
  cargo4 = place_model("4",    3, "pine-tree",        model_path,  5,     0.0,     150, 2.08, 6.12, lat, lon, alt,    0, 0, 0, -1);
  cargo5 = place_model("5",    4, "pine-tree",        model_path,  5,     0.0,     150, 2.08, 6.12, lat, lon, alt,    0, 0, 0, -1);
  cargo6 = place_model("6",    5, "dump-truck",       model_path,  0,      .5,   10000, 5.69,15.45, lat, lon, alt-90, 0, 0, 0, -1);

  cargo_init();
