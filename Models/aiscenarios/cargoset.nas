# Cargo Towing - Cargo Towing capability for Flightgear
# Written and developer by Wayne Bragg (wlbragg)
# Copyright (C) 2020 Wayne Bragg
# aiscenariocargoset/cargoset.nas
# Version 1.0.0 beta 1/21/2020
# Cargo Towing is licensed under the Gnu Public License v3+ (GPLv3+)

#################### inject ai scenario cargo models into the scene ####################

var modelNum = 0;
foreach(var cargoN; props.globals.getNode("/ai/models", 1).getChildren("aircraft")){

    var desc = "";

    if ((cargoN.getNode("callsign") != nil) and (cargoN.getNode("callsign").getValue() != nil)) {

        modelNum = modelNum + 1;

        desc = cargoN.getNode("callsign").getValue();
        if (desc == "") desc = cargoN.getNode("id").getValue();

        var callsign = "cargo"~modelNum;
        var path = cargoN.getNode("callsign").getParent().getName() ~ "[" ~ cargoN.getNode("callsign").getParent().getIndex() ~ "]";
        var stack = 0;
        var drop = 0.0;
        var weight = 1000;
        var height = 0;
        var harness = 3.5;
        var lat = cargoN.getNode("position/latitude-deg").getValue();
        var lon = cargoN.getNode("position/longitude-deg").getValue();
        var alt = cargoN.getNode("position/altitude-ft").getValue();
        var heading = cargoN.getNode("orientation/true-heading-deg").getValue();
        var pitch = cargoN.getNode("orientation/pitch-deg").getValue();
        var roll = cargoN.getNode("orientation/roll-deg").getValue();
        var ai = cargoN.getNode("callsign").getParent().getIndex();

        place_model(modelNum, modelNum-1, desc, path, stack, drop, weight, height, harness, lat, lon, alt, heading, pitch, roll, ai);

    }
}
cargotimer.restart(0);
