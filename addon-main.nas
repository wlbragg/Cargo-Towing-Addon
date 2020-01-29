# Cargo Towing - Cargo Towing capability for Flightgear
# Written and developer by Wayne Bragg (wlbragg)
# Copyright (C) 2020 Wayne Bragg
# addon-main.nas
# Launcher script
# Version 1.0.0 beta 1/21/2020
# Cargo Towing is licensed under the Gnu Public License v3+ (GPLv3+)

var main = func(addon) {

    printlog("alert", "CGTOW addon initialized from path ", addon.basePath);

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
                    setprop("/sim/gui/dialogs/aicargo-dialog/selected_cargo_lat", pos_lat);
                    setprop("/sim/gui/dialogs/aicargo-dialog/selected_cargo_lon", pos_lon);
                    setprop("/sim/gui/dialogs/aicargo-dialog/selected_cargo_alt", (click_alt + alt_offset) * 3.28);
                    setprop("/sim/gui/dialogs/aicargo-dialog/selected_cargo_head", getprop("/models/cargo/"~aic~"/heading-deg"));
                    setprop("/sim/gui/dialogs/aicargo-dialog/selected_cargo_ai", getprop("/models/cargo/"~aic~"/ai"));

                    var cargo = getprop("/sim/gui/dialogs/aicargo-dialog/selected-cargo");
                    aic = string.trim(cargo, -1, string.isalpha)-1;
                    if (aic > 37) {
                        setprop("/ai/models/aircraft[" ~ getprop("/models/cargo/cargo["~aic~"]/ai") ~ "]/position/altitude-ft", (click_alt + alt_offset) * 3.28);
                        setprop("/ai/models/aircraft[" ~ getprop("/models/cargo/cargo["~aic~"]/ai") ~ "]/position/latitude-deg", pos_lat);
                        setprop("/ai/models/aircraft[" ~ getprop("/models/cargo/cargo["~aic~"]/ai") ~ "]/position/longitude-deg", pos_lon);
                        setprop("/ai/models/aircraft[" ~ getprop("/models/cargo/cargo["~aic~"]/ai") ~ "]/orientation/true-heading-deg", getprop("/sim/gui/dialogs/aicargo-dialog/selected_cargo_head"));
                    }

                    if (getprop("/sim/gui/dialogs/aicargo-dialog/save")) {
                        setprop("/sim/model/aircrane/"~cargo~"/saved", 1);
                        setprop("/sim/model/aircrane/"~cargo~"/position/latitude-deg", getprop("/sim/gui/dialogs/aicargo-dialog/selected_cargo_lat"));
                        setprop("/sim/model/aircrane/"~cargo~"/position/longitude-deg", getprop("/sim/gui/dialogs/aicargo-dialog/selected_cargo_lon"));
                        setprop("/sim/model/aircrane/"~cargo~"/position/altitude-ft", getprop("/sim/gui/dialogs/aicargo-dialog/selected_cargo_alt"));
                        setprop("/sim/model/aircrane/"~cargo~"/orientation/true-heading-deg", getprop("/sim/gui/dialogs/aicargo-dialog/selected_cargo_head"));
                        setprop("/sim/model/aircrane/"~cargo~"/ai", getprop("/sim/gui/dialogs/aicargo-dialog/selected_cargo_ai"));
                        aircraft.data.add("/sim/model/aircrane/"~cargo~"/position/latitude-deg",
                        "/sim/model/aircrane/"~cargo~"/position/longitude-deg",
                        "/sim/model/aircrane/"~cargo~"/position/altitude-ft",
                        "/sim/model/aircrane/"~cargo~"/orientation/true-heading-deg",
                        "/sim/model/aircrane/"~cargo~"/ai");
                        aircraft.data.save();
                    }
                } else {
                    gui.popupTip("No Cargo Selected, first select cargo to move in the AirCrane's Cargo Menu", 3);
                }
            }
        }
    });

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

                setprop("/sim/cargo/rope/offset", ac.getNode("offset").getValue());

                # Save assigned weights for availible pointmass
                var loadpoints = props.globals.getNode("/sim", 1).getChildren("weight");
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

            printlog("alert", "Load ", fname, " module");
            io.load_nasal(fname, "CGTOW");
        }

    });

    setlistener("/sim/gui/show-range", func (node) {      
        if (node.getBoolValue()) {
            fgcommand("dialog-show", props.Node.new({"dialog-name": "range-dialog"}));
        } else {
            fgcommand("dialog-close", props.Node.new({"dialog-name": "range-dialog"}));
        }
    }, 0, 0);
}
