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
    setlistener("/sim/signals/fdm-initialized", func {

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
        var aircraftNames = props.globals.getNode("sim/gui/dialogs/rope-dialog/settings/", 1).getChildren("aircraft");
        forindex (var ctr; aircraftNames) {
            var ac = aircraftNames[ctr];
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
    }, 0, 1);

    setlistener("/sim/gui/show-range", func (node) {      
        if (node.getBoolValue()) {
            fgcommand("dialog-show", props.Node.new({"dialog-name": "range-dialog"}));
        } else {
            fgcommand("dialog-close", props.Node.new({"dialog-name": "range-dialog"}));
        }
    }, 0, 1);

    setlistener("/sim/signals/click", func {
        if (__kbd.shift.getBoolValue()) {
            var click_pos = geo.click_position();
            if (__kbd.ctrl.getBoolValue()) {
                return;
            } else {
                var aic = getprop("/sim/gui/dialogs/aicargo-dialog/ai-path");
                if (aic != nil) {
                    var pos_lat = click_pos.lat();
                    var pos_lon = click_pos.lon();
                    var click_alt = geo.elevation(click_pos.lat(), click_pos.lon());
                    var alt_offset = getprop("/models/cargo/"~aic~"/height");
                    setprop("/models/cargo/"~aic~"/latitude-deg", pos_lat);
                    setprop("/models/cargo/"~aic~"/longitude-deg", pos_lon);
                    setprop("/models/cargo/"~aic~"/elevation-ft/", (click_alt + alt_offset) * 3.28);
                    setprop("/sim/gui/dialogs/aicargo-dialog/selected-cargo-lat", pos_lat);
                    setprop("/sim/gui/dialogs/aicargo-dialog/selected-cargo-lon", pos_lon);
                    setprop("/sim/gui/dialogs/aicargo-dialog/selected-cargo-alt", (click_alt + alt_offset) * 3.28);
                    setprop("/sim/gui/dialogs/aicargo-dialog/selected-cargo-head", getprop("/models/cargo/"~aic~"/heading-deg"));
                    setprop("/sim/gui/dialogs/aicargo-dialog/selected-cargo-ai", getprop("/models/cargo/"~aic~"/ai"));

                    var cargo = getprop("/sim/gui/dialogs/aicargo-dialog/selected-cargo");
                    aic = string.trim(cargo, -1, string.isalpha)-1;
                    var setselected = getprop("sim/cargo/setselectedname");
                    #if (aic > 37) {
                    if (setselected == "AIScenarios") {
                        setprop("/ai/models/aircraft[" ~ getprop("/models/cargo/cargo["~aic~"]/ai") ~ "]/position/altitude-ft", (click_alt + alt_offset) * 3.28);
                        setprop("/ai/models/aircraft[" ~ getprop("/models/cargo/cargo["~aic~"]/ai") ~ "]/position/latitude-deg", pos_lat);
                        setprop("/ai/models/aircraft[" ~ getprop("/models/cargo/cargo["~aic~"]/ai") ~ "]/position/longitude-deg", pos_lon);
                        setprop("/ai/models/aircraft[" ~ getprop("/models/cargo/cargo["~aic~"]/ai") ~ "]/orientation/true-heading-deg", getprop("/sim/gui/dialogs/aicargo-dialog/selected-cargo-head"));
                    }

                    var aircraftName = getprop("/sim/gui/dialogs/rope-dialog/settings/aircraft-name");
                    if (getprop("/sim/gui/dialogs/aicargo-dialog/save")) {
                        setprop("/sim/model/"~aircraftName~"/"~setselected~"/"~cargo~"/saved", 1);
                        setprop("/sim/model/"~aircraftName~"/"~setselected~"/"~cargo~"/position/latitude-deg", getprop("/sim/gui/dialogs/aicargo-dialog/selected-cargo-lat"));
                        setprop("/sim/model/"~aircraftName~"/"~setselected~"/"~cargo~"/position/longitude-deg", getprop("/sim/gui/dialogs/aicargo-dialog/selected-cargo-lon"));
                        setprop("/sim/model/"~aircraftName~"/"~setselected~"/"~cargo~"/position/altitude-ft", getprop("/sim/gui/dialogs/aicargo-dialog/selected-cargo-alt"));
                        setprop("/sim/model/"~aircraftName~"/"~setselected~"/"~cargo~"/orientation/true-heading-deg", getprop("/sim/gui/dialogs/aicargo-dialog/selected-cargo-head"));
                        setprop("/sim/model/"~aircraftName~"/"~setselected~"/"~cargo~"/ai", getprop("/sim/gui/dialogs/aicargo-dialog/selected-cargo-ai"));
                        aircraft.data.add(
                            "/sim/model/"~aircraftName~"/"~setselected~"/"~cargo~"/ai",
                            "/sim/model/"~aircraftName~"/"~setselected~"/"~cargo~"/saved",
                            "/sim/model/"~aircraftName~"/"~setselected~"/"~cargo~"/position/latitude-deg",
                            "/sim/model/"~aircraftName~"/"~setselected~"/"~cargo~"/position/longitude-deg",
                            "/sim/model/"~aircraftName~"/"~setselected~"/"~cargo~"/position/altitude-ft",
                            "/sim/model/"~aircraftName~"/"~setselected~"/"~cargo~"/orientation/true-heading-deg");
                        aircraft.data.save();
                    }
                } else {
                    gui.popupTip("No Cargo Selected, first select cargo to move in the Cargo Towing Menu", 3);
                }
            }
        }
    }, 0, 1);

}
