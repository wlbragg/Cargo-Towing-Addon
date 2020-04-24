# Cargo Towing - Cargo Towing capability for Flightgear
# Written and developer by Wayne Bragg (wlbragg)
# Copyright (C) 2020 Wayne Bragg
# addon-main.nas
# Launcher script
# Version 1.0.0 beta 1/21/2020
# Cargo Towing is licensed under the Gnu Public License v3+ (GPLv3+)

var main = func(addon) {

    logprint("alert", "CGTOW addon initialized from path ", addon.basePath);

    # initialization

    if (getprop("/sim/gui/show-range")) {
        fgcommand("dialog-show", props.Node.new({"dialog-name": "range-dialog"}));
    } else {
        fgcommand("dialog-close", props.Node.new({"dialog-name": "range-dialog"}));
    }

    # Find loaded aircraft name
    var aircraftName = split(".", getprop("/sim/aircraft"));
    forindex(var ctr; aircraftName) {
        setprop("/sim/gui/dialogs/rope-dialog/settings/aircraft-name", aircraftName[ctr]);
    }

    # Adjust rope for loaded aircraft
    var aircraft = props.globals.getNode("sim/gui/dialogs/rope-dialog/settings/", 1).getChildren("aircraft");
    forindex (var ctr; aircraft) {
        var ac = aircraft[ctr];
        var name = ac.getNode("name").getValue();
        if (name == getprop("/sim/gui/dialogs/rope-dialog/settings/aircraft-name")) {
            setprop("/sim/gui/dialogs/rope-dialog/settings/x-pos", ac.getNode("x-pos").getValue());
            setprop("/sim/gui/dialogs/rope-dialog/settings/y-pos", ac.getNode("y-pos").getValue());
            setprop("/sim/gui/dialogs/rope-dialog/settings/z-pos", ac.getNode("z-pos").getValue());
            setprop("/sim/gui/dialogs/rope-dialog/settings/offset", ac.getNode("offset").getValue());
            setprop("sim/gui/dialogs/rope-dialog/settings/diameter", ac.getNode("diameter").getValue());
            setprop("sim/gui/dialogs/rope-dialog/settings/wincharm", ac.getNode("wincharm").getValue());
            setprop("sim/gui/dialogs/rope-dialog/settings/loadpoint", ac.getNode("loadpoint").getValue());

            setprop("/sim/cargo/rope/offset", ac.getNode("offset").getValue());

            # Save assigned weights for availible pointmass
            var location = "/sim";
            if (getprop("sim/flight-model") == "jsb") location = "/payload";
            var loadpoints = props.globals.getNode(location, 1).getChildren("weight");
            forindex (var loadpoints_index; loadpoints) {
                var lp = loadpoints[loadpoints_index];
                setprop("/sim/model/"~name~"/weight-points/pointname["~loadpoints_index~"]/"~name, lp.getNode("name").getValue());
                setprop("/sim/model/"~name~"/weight-points/pointname["~loadpoints_index~"]/weight-lb", lp.getNode("weight-lb").getValue());
                setprop("/sim/model/"~name~"/weight-points/pointname["~loadpoints_index~"]/max-lb", lp.getNode("max-lb").getValue());
            }
        }
    }

    foreach(var script; ['cargooperations.nas', 'longlineanimation-uc.nas', 'js.nas']) {
        var fname = addon.basePath ~ "/" ~ script;

        logprint("alert", "Load ", fname, " module");
        io.load_nasal(fname, "CGTOW");
    }

    #Fill in availible cargo sets
    var cargoset = props.globals.getNode("/sim/cargo", 1).getChildren("sets");
    forindex (var cargoset_index; cargoset) {
        var cs = cargoset[cargoset_index];
        var cs_id = "unknown";
        if ((cs.getNode("name") != nil) and (cs.getNode("name").getValue() != nil)) {
          if (getprop("/sim/cargo/setselected") == cargoset_index) {
            setprop("/sim/cargo/setselectedname", cs.getNode("name").getValue());
            var fname = addon.basePath ~ "/Models/" ~ cs.getNode("path").getValue() ~ "/cargoset.nas";
            io.load_nasal(fname, "CGTOW");
          }
        }
    }

    setlistener("/sim/gui/show-range", func (node) {      
        if (node.getBoolValue()) {
            fgcommand("dialog-show", props.Node.new({"dialog-name": "range-dialog"}));
        } else {
            fgcommand("dialog-close", props.Node.new({"dialog-name": "range-dialog"}));
        }
    }, 0, 0);

}
