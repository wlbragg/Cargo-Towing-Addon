# Cargo Towing - Cargo Towing capability for Flightgear
# Written and developer by Wayne Bragg (wlbragg)
# Copyright (C) 2020 Wayne Bragg
# cargooperations.nas
# Launcher script
# Version 1.0.0 beta 1/21/2020
# Cargo Towing is licensed under the Gnu Public License v3+ (GPLv3+)

#################### cargo hauling ####################

var AircraftCargo = {};
var parents = [AircraftCargo];
var cargoParent = "";
var cargoName = "";
var isAI = -1;
#hookHeight (in meters)
var hookHeight = 15;
var hooked = 0;
var cargoReleased = 0;
var currentYaw = 0;
var originalYaw = 0;
var hitchOffset = 1.1;
var cargoHeight = 0;
var cargoWeight = 0;
var cargoHarness = 0;
var cargoElevation = 0;
var cargoGroundElevFt = 0;
var haulable = 0;
var stack = 0;
var stackConnected = 0;
var path = "";
var currentLat = 0;
var currentLon = 0;
var asinInput = 0;
var cargo_pos = geo.Coord.new();
var stack_pos = geo.Coord.new();
var bearing = 0.0;
var cargo_dist = 0.0;

var size = props.globals.getNode("sim/gui/dialogs/rope-dialog/settings/size", 1);
var ropeSegments = props.globals.getNode("sim/cargo/rope/segments", 1);
var seg_length = props.globals.getNode("sim/cargo/rope/factor", 1);
seg_length.setValue(seg_length.getValue() * size.getValue());
var n_seg_reeled = props.globals.getNode("sim/cargo/rope/segments-reeled-in", 1);
var offset = props.globals.getNode("sim/cargo/rope/coil-angle", 1);
var ropeLength = (ropeSegments.getValue() - n_seg_reeled.getValue()) * seg_length.getValue();

var aircraftName = props.globals.getNode("sim/gui/dialogs/rope-dialog/settings/aircraft-name", 1);
var index = props.globals.getNode("sim/gui/dialogs/rope-dialog/settings/index", 1);

var location = "sim";
var fdm = getprop("sim/flight-model");
if (fdm == "jsb") location = "payload";

var existingPointWeight = props.globals.getNode("sim/model/"~aircraftName.getValue()~"/weight-points/pointname["~index.getValue()~"]/weight-lb", 1);
var aircraftPointmass = props.globals.getNode(location~"/weight["~index.getValue()~"]/weight-lb", 1);
var existingPointLimit = props.globals.getNode("sim/model/"~aircraftName.getValue()~"/weight-points/pointname["~index.getValue()~"]/max-lb", 1);
var aircraftPointlimit = props.globals.getNode(location~"/weight["~index.getValue()~"]/max-lb", 1);

var rope_length = props.globals.getNode("sim/cargo/rope/length", 1);
var load_weight = props.globals.getNode("sim/cargo/load/weight", 1);

var rope_damping = props.globals.getNode("sim/cargo/rope/damping", 1);
var load_damping = props.globals.getNode("sim/cargo/rope/load-damping", 1);
var pulling_cargo = props.globals.getNode("sim/cargo/rope/pulling", 1);

var cargo_harness = props.globals.getNode("sim/cargo/cargoharness", 1);
var cargo_height = props.globals.getNode("sim/cargo/cargoheight", 1);
var cargo_alt = props.globals.getNode("sim/cargo/cargoalt", 1);
var harness_alt = props.globals.getNode("sim/cargo/harnessalt", 1);

var current_yaw = props.globals.getNode("sim/cargo/currentyaw", 1);

var cargo_tow = func () {

    existingPointWeight.getValue();
    aircraftPointmass.getValue();
    existingPointLimit.getValue();
    aircraftPointlimit.getValue();

    # global for aircraft instruments
    rope_length.setValue(ropeLength * 3.28);

    var hookNode = props.globals.getNode("sim/cargo/cargo-hook", 1);
    var autoHookNode = props.globals.getNode("sim/cargo/cargo-auto-hook", 1);
    var onHookNode = props.globals.getNode("sim/cargo/cargo-on-hook", 1);
    var releaseNode = props.globals.getNode("controls/cargo-release", 1);

    #use only geo?
    var lonNode = props.globals.getNode("position/longitude-deg", 1);
    var latNode = props.globals.getNode("position/latitude-deg", 1);
    var aircraft_pos = geo.aircraft_position();

    var headNode = props.globals.getNode("orientation/heading-deg", 1);
    var pitchNode = props.globals.getNode("orientation/pitch-deg", 1);
    var rollNode = props.globals.getNode("orientation/roll-deg", 1);

    #var onGround = props.globals.getNode("gear/gear/wow", 1).getValue() * props.globals.getNode("gear/gear[1]/wow", 1).getValue() * props.globals.getNode("gear/gear[2]/wow", 1).getValue();
    var onGround = getprop("gear/gear/wow") * getprop("gear/gear[1]/wow") * getprop("gear/gear[2]/wow");
    var cargoOnGround = props.globals.getNode("sim/cargo/hitsground", 1);
    var overland = getprop("gear/gear/ground-is-solid");
    if (getprop("sim/flight-model") == "jsb")
        overland = getprop("fdm/jsbsim/ground/solid");

    var longline = props.globals.getNode("sim/gui/dialogs/aicargo-dialog/connection", 1);

    var aircraftPos = props.globals.getNode("position/altitude-ft", 1);
    #var altNode = getprop("/position/altitude-agl-ft"); can't use because of collision #
    var aircraft_alt_ft = aircraftPos.getValue() - offset.getValue();
    var true_grnd_elev_ft = geo.elevation(latNode.getValue(), lonNode.getValue()) * 3.28;
    var altNode =  aircraft_alt_ft - true_grnd_elev_ft;

    var aircraftTrueAgl = props.globals.getNode("position/true-agl-ft", 1);
    aircraftTrueAgl.setValue(altNode);

    var aircraftGrndElevFt = props.globals.getNode("position/ground-elev-ft", 1);
    var aircraftGrndAltAglFt = props.globals.getNode("position/altitude-agl-ft", 1);

    var elvPos = aircraftGrndElevFt.getValue() + aircraftGrndAltAglFt.getValue() - 3.9;

    if (longline.getValue()){
        hookHeight = ropeLength * 3.28;
    }else{
        hookHeight = 15;
    }

	if(onHookNode.getValue() == 0 and cargoReleased == 0 and hooked == 0) {

var cargo_last=0;
var cargo_comp=0;
var cargo_closest=0;

        #gui.popupTip("In ranging", 1);
        foreach(var cargoN; props.globals.getNode("/models/cargo", 1).getChildren("cargo")) {

            existingPointWeight = props.globals.getNode("sim/model/"~aircraftName.getValue()~"/weight-points/pointname["~index.getValue()~"]/weight-lb", 1);
            aircraftPointmass = props.globals.getNode(location~"/weight["~index.getValue()~"]/weight-lb", 1);
            existingPointLimit = props.globals.getNode("sim/model/"~aircraftName.getValue()~"/weight-points/pointname["~index.getValue()~"]/max-lb", 1);
            aircraftPointlimit = props.globals.getNode(location~"/weight["~index.getValue()~"]/max-lb", 1);

            cargoElevation = cargoN.getNode("elevation-ft").getValue();
            #cargoGroundElevFt = cargoElevation - cargoN.getNode("height").getValue();

            if (altNode - (hookHeight + offset.getValue()) < cargoElevation - cargoGroundElevFt) {

setprop("/sim/cargo/current-cargo-elevation", cargoElevation - cargoGroundElevFt);
setprop("/sim/cargo/current-cargo-elevation-two", altNode - ropeLength);

                if (string.match(cargoN.getNode("callsign").getValue(), "cargo*")){
                    cargo_pos.set_latlon(cargoN.getNode("latitude-deg").getValue(), cargoN.getNode("longitude-deg").getValue());
                    cargo_dist = aircraft_pos.distance_to(cargo_pos);

if(cargo_comp == 0) {
  cargo_last = cargo_dist;
  cargo_comp = 1;
} else {
  if(cargo_dist < cargo_last) {
    cargo_closest=cargo_dist;
  } else {    
    cargo_last = cargo_dist;
  }
  setprop("/sim/cargo/current-cargo-distance", cargo_closest);
}

                    if (cargo_dist <= (hookHeight + 5)/3.281) {
                        cargoGroundElevFt = geo.elevation(cargoN.getNode("latitude-deg").getValue(), cargoN.getNode("longitude-deg").getValue()) * 3.28;
                        if (cargoN.getNode("elevation-ft").getValue() > -999){
                            gui.popupTip(cargoN.getNode("callsign").getValue()~" in range", 1);
		                        if (hookNode.getValue() == 1 or autoHookNode.getValue() == 1) {
			                          hooked = 1;
                                autoHookNode.setValue(0);
                                cargoParent = cargoN.getNode("callsign").getParent().getName() ~ "[" ~ cargoN.getNode("callsign").getParent().getIndex() ~ "]";
                                cargoName = cargoN.getNode("callsign").getValue();
                                #maybe condition to only if longline
                                currentYaw = (headNode.getValue()+(headNode.getValue()-cargoN.getNode("heading-deg").getValue()))-headNode.getValue();
                                originalYaw = cargoN.getNode("heading-deg").getValue();
                                if (currentYaw > 360) currentYaw = currentYaw - 360;
                                if (currentYaw < 0) currentYaw = currentYaw + 360;
                                current_yaw.setValue(currentYaw);

                                cargoHeight = props.globals.getNode("/models/cargo/" ~ cargoParent ~ "/height").getValue();
                                cargoWeight = props.globals.getNode("/models/cargo/" ~ cargoParent ~ "/weight").getValue();
                                cargoHarness = props.globals.getNode("/models/cargo/" ~ cargoParent ~ "/harness").getValue();
                                cargoElevation = props.globals.getNode("/models/cargo/" ~ cargoParent ~ "/elevation-ft").getValue();
                                cargoGroundElevFt = geo.elevation(props.globals.getNode("/models/cargo/" ~ cargoParent ~ "/latitude-deg").getValue(), props.globals.getNode("/models/cargo/" ~ cargoParent ~ "/longitude-deg").getValue()) * 3.28;
                                stack = props.globals.getNode("/models/cargo/" ~ cargoParent ~ "/stack").getValue();

                                if (cargoHeight < 3.12)
                                  haulable = 1;
                                else
                                  haulable = 0;
						                    
                                if (longline.getValue() or haulable) {
                                    longline_animation(1, cargoWeight, seg_length.getValue());
                                    currentLat = props.globals.getNode("/models/cargo/" ~ cargoParent ~ "/latitude-deg").getValue();
                                    currentLon = props.globals.getNode("/models/cargo/" ~ cargoParent ~ "/longitude-deg").getValue();

                                    cargo_harness.setValue(-cargoHarness);
                                    cargo_height.setValue(-cargoHeight);

                                    if (!longline.getValue()) {
                                        props.globals.getNode("/models/cargo/" ~ cargoParent ~ "/elevation-ft").setDoubleValue(elvPos);
                                        props.globals.getNode("/models/cargo/" ~ cargoParent ~ "/latitude-deg").setDoubleValue(latNode.getValue());
                                        props.globals.getNode("/models/cargo/" ~ cargoParent ~ "/longitude-deg").setDoubleValue(lonNode.getValue());
                                        props.globals.getNode("/models/cargo/" ~ cargoParent ~ "/heading-deg").setDoubleValue(headNode.getValue());
                                        props.globals.getNode("/models/cargo/" ~ cargoParent ~ "/pitch-deg").setDoubleValue(pitchNode.getValue());
                                        props.globals.getNode("/models/cargo/" ~ cargoParent ~ "/roll-deg").setDoubleValue(rollNode.getValue());
                                    }
                                }

                                setprop("sim/cargo/"~cargoName~"-onhook", 1);
                                onHookNode.setValue(1);
                            }
					    }
				    }
			    }
            }
        } #for
    }
setprop("/sim/cargo/current-cargo-name", cargoName);
    if (hooked == 1) {
        cargoHeight = getprop("/models/cargo/" ~ cargoParent ~ "/height");
        isAI = getprop("/models/cargo/" ~ cargoParent ~ "/ai");

        if (!longline.getValue()) {
            if (haulable) {
                # TODO: -optimize- some of this this may need to only happen once, each time the condition becomes true VS every loop

                currentYaw = (headNode.getValue()+(headNode.getValue()-originalYaw))-headNode.getValue();
                if (currentYaw > 360) currentYaw = currentYaw - 360;
                if (currentYaw < 0) currentYaw = currentYaw + 360;
                current_yaw.setValue(currentYaw);

                cargo_alt.setValue(0);

                aircraftPointmass.setValue(cargoWeight+existingPointWeight.getValue());
                aircraftPointlimit.setValue(cargoWeight+existingPointLimit.getValue());
                load_weight.setValue(cargoWeight);

                props.globals.getNode("/models/cargo/" ~ cargoParent ~ "/elevation-ft").setDoubleValue(elvPos);
                props.globals.getNode("/models/cargo/" ~ cargoParent ~ "/latitude-deg").setDoubleValue(latNode.getValue());
                props.globals.getNode("/models/cargo/" ~ cargoParent ~ "/longitude-deg").setDoubleValue(lonNode.getValue());
                props.globals.getNode("/models/cargo/" ~ cargoParent ~ "/heading-deg").setDoubleValue(headNode.getValue());
                props.globals.getNode("/models/cargo/" ~ cargoParent ~ "/pitch-deg").setDoubleValue(pitchNode.getValue());
                props.globals.getNode("/models/cargo/" ~ cargoParent ~ "/roll-deg").setDoubleValue(rollNode.getValue());

            } else {
                gui.popupTip("Cargo too tall use rope", 3);
                hooked = 0;
                hookNode.setValue(0);
                onHookNode.setValue(0);
			    setprop("sim/cargo/"~cargoName~"-onhook", 0);
            }
        } else {
            if (longline.getValue() and cargoOnGround.getValue() == 0) {
                rope_damping.setValue(0.1);
                load_damping.setValue(0.9);
                pulling_cargo.setValue(0);

                currentYaw = (headNode.getValue()+(headNode.getValue()-originalYaw))-headNode.getValue();
                if (currentYaw > 360) currentYaw = currentYaw - 360;
                if (currentYaw < 0) currentYaw = currentYaw + 360;
                current_yaw.setValue(currentYaw);

                cargo_alt.setValue((-cargoHarness + -hitchOffset + -ropeLength) - (n_seg_reeled.getValue()*.19));
                harness_alt.setValue((-hitchOffset + -ropeLength) - (n_seg_reeled.getValue()*.19));

                aircraftPointmass.setValue(cargoWeight+existingPointWeight.getValue());
                aircraftPointlimit.setValue(cargoWeight+existingPointLimit.getValue());
                load_weight.setValue(cargoWeight);

#setprop("aircraftPointmass", aircraftPointmass.getValue());
#setprop("aircraftPointlimit", aircraftPointlimit.getValue());
#setprop("aircraftexistingPointWeight", existingPointWeight.getValue());
#setprop("aircraftexistingPointLimit", existingPointLimit.getValue());
#setprop("aircraftLoadweight", load_weight.getValue());

                currentLat = latNode.getValue();
                currentLon = lonNode.getValue();
                setprop("/models/cargo/" ~ cargoParent ~ "/latitude-deg", currentLat);
                setprop("/models/cargo/" ~ cargoParent ~ "/longitude-deg", currentLon);

                #AI
                if (isAI != -1) {
                    setprop("/ai/models/aircraft[" ~ isAI ~ "]/position/altitude-ft", (aircraft_alt_ft + offset.getValue()) - ((ropeLength + cargoHarness + cargoHeight) * 3.28) + (n_seg_reeled.getValue() * .19));
                    setprop("/ai/models/aircraft[" ~ isAI ~ "]/position/latitude-deg", currentLat);
                    setprop("/ai/models/aircraft[" ~ isAI ~ "]/position/longitude-deg", currentLon);
                }

                #if (stack > 0) {
if (stack > -1) {
                    var cargoBaseHeight = (aircraft_alt_ft + offset.getValue()) - ((ropeLength + cargoHarness + cargoHeight) * 3.28);
                    var stackTopHeight = getprop("/models/cargo/cargo[" ~ stack ~ "]/elevation-ft");

                    setprop("/sim/cargo/current-cargo-elevation", stackTopHeight);
                    setprop("/sim/cargo/current-cargo-elevation-two", cargoBaseHeight);

                    var verticalDist = cargoBaseHeight - stackTopHeight;
                    stack_pos.set_latlon(getprop("/models/cargo/cargo[" ~ stack ~ "]/latitude-deg"), getprop("/models/cargo/cargo[" ~ stack ~ "]/longitude-deg"));
                    cargo_pos.set_latlon(currentLat, currentLon);
                    cargo_dist = cargo_pos.distance_to(stack_pos);

setprop("/sim/cargo/current-connection-distance", cargo_dist);

                    if (cargo_dist <= 10 and (verticalDist > -1 and verticalDist < 2)) {
                        gui.popupTip(cargoName~" Connection in range", 1);
                        stackConnected = 1;
                    } else
                        stackConnected = 0;
                }

            } else {
                rope_damping.setValue(0.6);
                load_damping.setValue(1.0);

                longline_animation(1, cargoWeight, seg_length.getValue());
                pulling_cargo.setValue(1);

                currentYaw = (headNode.getValue()+(headNode.getValue()-originalYaw))-headNode.getValue();
                if (currentYaw > 360) currentYaw = currentYaw - 360;
                if (currentYaw < 0) currentYaw = currentYaw + 360;
                current_yaw.setValue(currentYaw);
               
                aircraftPointmass.setValue(existingPointWeight.getValue());
                aircraftPointlimit.setValue(existingPointLimit.getValue());
                load_weight.setValue(0);

                cargo_pos.set_latlon(currentLat, currentLon);
                cargo_dist = aircraft_pos.distance_to(cargo_pos);

                var lMin = -(cargoHeight*3.28)/((ropeLength + (cargoHarness * .5))*3.28);
                var lMax = ((ropeLength + (cargoHarness * .5) + cargoHeight) * 3.28)/((ropeLength + (cargoHarness * .5))*3.28);
                var iput = (altNode-(cargoHeight*3.28))/((ropeLength + (cargoHarness * .5))*3.28);

                if (iput > lMax) iput = lMax;
                if (iput < lMin) iput = lMin;
                asinInput = normalize_h(iput, lMax, lMin);
                setprop("/sim/cargo/rope/pull-factor-pitch", (math.asin(asinInput)*57.2958)*-1);

                bearing = aircraft_pos.course_to(cargo_pos);
                var rel_bearing =  (headNode.getValue() - 180.0) - bearing;
                setprop("/sim/cargo/rope/yaw1", rel_bearing);       
                
                if (cargo_dist > (ropeLength + 3)) {
                    pulling_cargo.setValue(2);

                    aircraftPointmass.setValue(cargoWeight+existingPointWeight.getValue());
                    aircraftPointlimit.setValue(cargoWeight+existingPointLimit.getValue());
                    load_weight.setValue(cargoWeight);
           
                    #x and y transformation to move cargo (incrementally) towards aircraft as rope is taut and pulling cargo
                    #this needs to be calculated precisely
                    currentLat = currentLat - ((currentLat-latNode.getValue())*.03);
                    currentLon = currentLon - ((currentLon-lonNode.getValue())*.03);

                    setprop("/models/cargo/" ~ cargoParent ~ "/latitude-deg", currentLat);
                    setprop("/models/cargo/" ~ cargoParent ~ "/longitude-deg", currentLon);

                    #AI
                    if (isAI != -1) {
                        setprop("/ai/models/aircraft[" ~ isAI ~ "]/position/latitude-deg", currentLat);
                        setprop("/ai/models/aircraft[" ~ isAI ~ "]/position/longitude-deg", currentLon);
                    }
                }
                
                if (cargo_dist > (ropeLength + 6)) {
                    releaseNode.setValue(1);
                }

                setprop("/models/cargo/"~cargoParent~"/elevation-ft", (geo.elevation(currentLat, currentLon) + cargoHeight) * 3.2808);

                #AI
                if (isAI != -1) {
                    setprop("/ai/models/aircraft[" ~ isAI ~ "]/position/altitude-ft", (geo.elevation(currentLat, currentLon) + cargoHeight) * 3.2808);
                }

            }
        }
        #gui.popupTip(cargoName~" in tow", 1);
setprop("/sim/cargo/current-cargo-name", cargoName);
        if ((releaseNode.getValue() == 1 or autoHookNode.getValue() == 1) and onHookNode.getValue() == 1) {            
            if (onGround or (longline.getValue() and cargoOnGround.getValue()) or (stack and stackConnected) or overland == 0) {
                onHookNode.setValue(0);
                releaseNode.setValue(0);
	              hooked = 0;
                hookNode.setValue(0);
	              cargoReleased = 1;
                if (pulling_cargo.getValue() == 2) {
	                  gui.popupTip("Drag force exceeded", 3);
                } else 
                    gui.popupTip("Cargo released", 3);
                pulling_cargo.setValue(0);
	              setprop("sim/cargo/"~cargoName~"-onhook", 0);
	              setprop("controls/release-"~cargoName, 1);
                if (stackConnected)
                    gui.popupTip(cargoName~" Connected", 1);
            } else {
                if (autoHookNode.getValue() == 0)
                    gui.popupTip("Cargo not on ground or out of position", 1);
                releaseNode.setValue(cargoReleased = 0);
            }
        }
    } else {
        if (autoHookNode.getValue() == 1) {
            gui.popupTip("Auto hook engaged", 1);
        }
        #release auto.hook by pressing hook
        if (hookNode.getValue() == 1 and autoHookNode.getValue() == 1) {
            autoHookNode.setValue(0);
            hookNode.setValue(0);
        }
    }
    if (cargoReleased == 1) {
        aircraftPointmass.setValue(existingPointWeight.getValue());
        aircraftPointlimit.setValue(existingPointLimit.getValue());
        load_weight.setValue(0);
        autoHookNode.setValue(0);

        rope_damping.setValue(0.6);
        load_damping.setValue(1.0);

        #use to offset cargo behind aircraft
        #var x = math.cos((headNode.getValue()+90)*0.0174533);
        #var y = math.sin((headNode.getValue()+90)*0.0174533);
        #y = y * -1;
        #x = x * .0000239;
        #y = y * .0000239;

        if (!longline.getValue()) {

            if (stack == -1) {
                setprop("/models/cargo/"~cargoParent~"/elevation-ft", (getprop("/position/altitude-ft") + 13.8) - (cargoHeight * 3.28));
                setprop("/models/cargo/"~cargoParent~"/heading-deg", headNode.getValue());
                setprop("/models/cargo/"~cargoParent~"/latitude-deg", latNode.getValue());
                setprop("/models/cargo/"~cargoParent~"/longitude-deg", lonNode.getValue());
            } else {
                        setprop("/models/cargo/"~cargoParent~"/elevation-ft", (geo.elevation(latNode.getValue(), lonNode.getValue()) + cargoHeight) * 3.2808);
                        setprop("/models/cargo/"~cargoParent~"/heading-deg", headNode.getValue());
                        setprop("/models/cargo/"~cargoParent~"/latitude-deg", latNode.getValue());
                        setprop("/models/cargo/"~cargoParent~"/longitude-deg", lonNode.getValue());
            }
        } else {
            setprop("/models/cargo/"~cargoParent~"/heading-deg", originalYaw);
            if (stack and stackConnected) {
                setprop("/models/cargo/"~cargoParent~"/elevation-ft", getprop("/models/cargo/cargo[" ~ stack ~ "]/elevation-ft") + (getprop("/models/cargo/" ~ cargoParent ~ "/drop") * 3.28));
                setprop("/models/cargo/"~cargoParent~"/latitude-deg", getprop("/models/cargo/cargo[" ~ stack ~ "]/latitude-deg"));
                setprop("/models/cargo/"~cargoParent~"/longitude-deg", getprop("/models/cargo/cargo[" ~ stack ~ "]/longitude-deg"));
            } else
                setprop("/models/cargo/"~cargoParent~"/elevation-ft", (geo.elevation(latNode.getValue(), lonNode.getValue()) + cargoHeight) * 3.2808);
        }

        var setselected = getprop("sim/cargo/setselectedname");

        if (getprop("/sim/model/"~aircraftName.getValue()~"/"~setselected~"/"~cargoName~"/saved")  == 1) {
            #gui.popupTip(cargoName~" position saved", 1);
            setprop("/sim/model/"~aircraftName.getValue()~"/"~setselected~"/"~cargoName~"/position/latitude-deg", getprop("/models/cargo/" ~ cargoParent ~ "/latitude-deg"));
            setprop("/sim/model/"~aircraftName.getValue()~"/"~setselected~"/"~cargoName~"/position/longitude-deg", getprop("/models/cargo/" ~ cargoParent ~ "/longitude-deg"));
            setprop("/sim/model/"~aircraftName.getValue()~"/"~setselected~"/"~cargoName~"/position/altitude-ft", getprop("/models/cargo/" ~ cargoParent ~ "/elevation-ft"));
            setprop("/sim/model/"~aircraftName.getValue()~"/"~setselected~"/"~cargoName~"/orientation/true-heading-deg", getprop("/models/cargo/" ~ cargoParent ~ "/heading-deg"));
            setprop("/sim/model/"~aircraftName.getValue()~"/"~setselected~"/"~cargoName~"/ai", getprop("/models/cargo/" ~ cargoParent ~ "/ai"));
            aircraft.data.add(
                "/sim/model/"~aircraftName.getValue()~"/"~setselected~"/"~cargoName~"/position/latitude-deg",
                "/sim/model/"~aircraftName.getValue()~"/"~setselected~"/"~cargoName~"/position/longitude-deg",
                "/sim/model/"~aircraftName.getValue()~"/"~setselected~"/"~cargoName~"/position/altitude-ft",
                "/sim/model/"~aircraftName.getValue()~"/"~setselected~"/"~cargoName~"/orientation/true-heading-deg",
                "/sim/model/"~aircraftName.getValue()~"/"~setselected~"/"~cargoName~"/ai",
                "/sim/model/"~aircraftName.getValue()~"/"~setselected~"/"~cargoName~"/saved");
            aircraft.data.save();
        }
        cargoName="";
        cargoReleased=0;

    }

    if (hookNode.getValue())
        hookNode.setValue(0);
    if (releaseNode.getValue())
        releaseNode.setValue(0);

    longline_animation(0, cargoWeight, seg_length.getValue());

}
var interval = 0;
var cargotimer = maketimer(interval, cargo_tow);

#################### inject cargo models into the scene (helper) ####################

var place_model = func(number, position, desc, path, stack, drop, weight, height, harness, lat, lon, alt, heading, pitch, roll, ai) {

  var m = props.globals.getNode("models", 1);
  for (var i = 0; 1; i += 1)
	  if (m.getChild("model", i, 0) == nil)
		  break;
  var model = m.getChild("model", i, 1);

  setprop("/models/cargo/cargo["~position~"]/latitude-deg", lat);
  setprop("/models/cargo/cargo["~position~"]/longitude-deg", lon);
  setprop("/models/cargo/cargo["~position~"]/elevation-ft", alt);
  setprop("/models/cargo/cargo["~position~"]/heading-deg", heading);
  setprop("/models/cargo/cargo["~position~"]/pitch-deg", pitch);
  setprop("/models/cargo/cargo["~position~"]/roll-deg", roll);
  setprop("/models/cargo/cargo["~position~"]/callsign", "cargo"~number);
  setprop("/models/cargo/cargo["~position~"]/description", desc);
  setprop("/models/cargo/cargo["~position~"]/weight", weight);
  setprop("/models/cargo/cargo["~position~"]/height", height);
  setprop("/models/cargo/cargo["~position~"]/harness", harness);
  setprop("/models/cargo/cargo["~position~"]/stack", stack);
  setprop("/models/cargo/cargo["~position~"]/drop", drop);
  setprop("/models/cargo/cargo["~position~"]/ai", ai);

  var cargomodel = props.globals.getNode("/models/cargo/cargo["~position~"]", 1);
  var latN = cargomodel.getNode("latitude-deg",1);
  var lonN = cargomodel.getNode("longitude-deg",1);
  var altN = cargomodel.getNode("elevation-ft",1);
  var headN = cargomodel.getNode("heading-deg",1);
  var pitchN = cargomodel.getNode("pitch-deg",1);
  var rollN = cargomodel.getNode("roll-deg",1);
  var callsignN = cargomodel.getNode("callsign",1);
  var descriptionN = cargomodel.getNode("description",1);
  var weightN = cargomodel.getNode("weight",1);
  var heightN = cargomodel.getNode("height",1);
  var harnessN = cargomodel.getNode("harness",1);
  var stackN = cargomodel.getNode("stack",1);
  var dropN = cargomodel.getNode("drop",1);
  var aiN = cargomodel.getNode("ai",1);

  model.getNode("path", 1).setValue(path~"cargo"~number~".xml");
  model.getNode("latitude-deg-prop", 1).setValue(latN.getPath());
  model.getNode("longitude-deg-prop", 1).setValue(lonN.getPath());
  model.getNode("elevation-ft-prop", 1).setValue(altN.getPath());
  model.getNode("heading-deg-prop", 1).setValue(headN.getPath());
  model.getNode("pitch-deg-prop", 1).setValue(pitchN.getPath());
  model.getNode("roll-deg-prop", 1).setValue(rollN.getPath());
  model.getNode("callsign-prop", 1).setValue(callsignN.getPath());
  model.getNode("description-prop", 1).setValue(descriptionN.getPath());
  model.getNode("weight-prop", 1).setValue(weightN.getPath());
  model.getNode("height-prop", 1).setValue(heightN.getPath());
  model.getNode("harness-prop", 1).setValue(harnessN.getPath());
  model.getNode("stack-prop", 1).setValue(stackN.getPath());
  model.getNode("drop-prop", 1).setValue(dropN.getPath());
  model.getNode("ai-prop", 1).setValue(aiN.getPath());
  model.getNode("load", 1).remove();

  return model;
}

var cargo_init = func () {

    var aircraftName = getprop("/sim/gui/dialogs/rope-dialog/settings/aircraft-name");
    var ct=0;
    foreach(var cargoN; props.globals.getNode("/models/cargo", 1).getChildren("cargo")){

        if (string.match(cargoN.getNode("callsign").getValue(), "cargo*")){
	        ct+=.001;

            setprop("sim/cargo/"~cargoN.getNode("callsign").getValue()~"-onhook", 0);
            setprop("controls/release-"~cargoN.getNode("callsign").getValue(), 0);

            var setselected = getprop("sim/cargo/setselectedname");
            if (getprop("sim/model/"~aircraftName~"/"~setselected~"/"~cargoN.getNode("callsign").getValue()~"/saved") == 1) {

                #AI
                var isAI = cargoN.getNode("ai").getValue();
                if (isAI != -1) {
                    setprop("/ai/models/aircraft[" ~ getprop("/sim/model/"~aircraftName~"/"~cargoN.getNode("callsign").getValue()~"/ai") ~ "]/position/latitude-deg", getprop("/sim/model/"~aircraftName~"/"~cargoN.getNode("callsign").getValue()~"/position/latitude-deg"));
                    setprop("/ai/models/aircraft[" ~ getprop("/sim/model/"~aircraftName~"/"~cargoN.getNode("callsign").getValue()~"/ai") ~ "]/position/longitude-deg", getprop("/sim/model/"~aircraftName~"/"~cargoN.getNode("callsign").getValue()~"/position/longitude-deg"));	
                    setprop("/ai/models/aircraft[" ~ getprop("/sim/model/"~aircraftName~"/"~cargoN.getNode("callsign").getValue()~"/ai") ~ "]/position/altitude-ft", getprop("/sim/model/"~aircraftName~"/"~cargoN.getNode("callsign").getValue()~"/position/altitude-ft"));
                    setprop("/ai/models/aircraft[" ~ getprop("/sim/model/"~aircraftName~"/"~cargoN.getNode("callsign").getValue()~"/ai") ~ "]/orientation/true-heading-deg", getprop("/sim/model/"~aircraftName~"/"~cargoN.getNode("callsign").getValue()~"/orientation/true-heading-deg"));
                }

                cargoN.getNode("latitude-deg").setDoubleValue(getprop("/sim/model/"~aircraftName~"/"~setselected~"/"~cargoN.getNode("callsign").getValue()~"/position/latitude-deg"));
                cargoN.getNode("longitude-deg").setDoubleValue(getprop("/sim/model/"~aircraftName~"/"~setselected~"/"~cargoN.getNode("callsign").getValue()~"/position/longitude-deg"));	
                cargoN.getNode("elevation-ft").setDoubleValue(getprop("/sim/model/"~aircraftName~"/"~setselected~"/"~cargoN.getNode("callsign").getValue()~"/position/altitude-ft"));
                cargoN.getNode("heading-deg").setDoubleValue(getprop("/sim/model/"~aircraftName~"/"~setselected~"/"~cargoN.getNode("callsign").getValue()~"/orientation/true-heading-deg"));
                cargoN.getNode("ai").setDoubleValue(getprop("/sim/model/"~aircraftName~"/"~setselected~"/"~cargoN.getNode("callsign").getValue()~"/ai"));

                aircraft.data.add(
                    "/sim/model/"~aircraftName~"/"~setselected~"/"~cargoN.getNode("callsign").getValue()~"/position/latitude-deg",
                    "/sim/model/"~aircraftName~"/"~setselected~"/"~cargoN.getNode("callsign").getValue()~"/position/longitude-deg",
                    "/sim/model/"~aircraftName~"/"~setselected~"/"~cargoN.getNode("callsign").getValue()~"/position/altitude-ft",
                    "/sim/model/"~aircraftName~"/"~setselected~"/"~cargoN.getNode("callsign").getValue()~"/orientation/true-heading-deg",
                    "/sim/model/"~aircraftName~"/"~setselected~"/"~cargoN.getNode("callsign").getValue()~"/ai",
                    "/sim/model/"~aircraftName~"/"~setselected~"/"~cargoN.getNode("callsign").getValue()~"/saved");
                aircraft.data.save();
            } else
                  if (getprop("/sim/model/"~aircraftName~"/"~setselected~"/"~cargoN.getNode("callsign").getValue()~"/random") == 1) {
                    var factor = ct + rand() * .001;
	                  var heading = getprop("orientation/heading-deg") + 90;
                        var x = math.cos(heading*0.0174533);
                        var y = math.sin(heading*0.0174533);
                        y = y * -1;
                        x = x * factor;
                        y = y * factor;
                    cargoN.getNode("latitude-deg").setDoubleValue(getprop("position/latitude-deg")+y);
                    cargoN.getNode("longitude-deg").setDoubleValue(getprop("position/longitude-deg")+x);
                    cargoN.getNode("heading-deg").setDoubleValue(rand()*360);
                    var elev_m = geo.elevation(cargoN.getNode("latitude-deg").getValue(), cargoN.getNode("longitude-deg").getValue());
                    cargoN.getNode("elevation-ft").setDoubleValue(elev_m * 3.2808);
                  }

            print("\nCargo Created:\n" ~
              cargoN.getNode("callsign").getValue() ~ "\n" ~
              cargoN.getNode("description").getValue() ~ "\n" ~
              cargoN.getNode("latitude-deg").getValue() ~ "/" ~
              cargoN.getNode("longitude-deg").getValue() ~ "\nElev-ft:" ~
              cargoN.getNode("elevation-ft").getValue() ~ "\nHead:" ~
              cargoN.getNode("heading-deg").getValue() ~ "\nStack:" ~
              cargoN.getNode("ai").getValue() ~ "\n");
        }
    }

	#gui.fpsDisplay(1);
    if (!ct) {
      print("No AI Cargo, exiting cargo.nas!");
      return;
    } else {
      cargotimer.restart(0);
    }
}

var place_model = func(number, position, desc, path, stack, drop, weight, height, harness, lat, lon, alt, heading, pitch, roll, ai) {

  var m = props.globals.getNode("models", 1);
  for (var i = 0; 1; i += 1)
	  if (m.getChild("model", i, 0) == nil)
		  break;
  var model = m.getChild("model", i, 1);

  setprop("/models/cargo/cargo["~position~"]/latitude-deg", lat);
  setprop("/models/cargo/cargo["~position~"]/longitude-deg", lon);
  setprop("/models/cargo/cargo["~position~"]/elevation-ft", alt);
  setprop("/models/cargo/cargo["~position~"]/heading-deg", heading);
  setprop("/models/cargo/cargo["~position~"]/pitch-deg", pitch);
  setprop("/models/cargo/cargo["~position~"]/roll-deg", roll);
  setprop("/models/cargo/cargo["~position~"]/callsign", "cargo"~number);
  setprop("/models/cargo/cargo["~position~"]/description", desc);
  setprop("/models/cargo/cargo["~position~"]/weight", weight);
  setprop("/models/cargo/cargo["~position~"]/height", height);
  setprop("/models/cargo/cargo["~position~"]/harness", harness);
  setprop("/models/cargo/cargo["~position~"]/stack", stack);
  setprop("/models/cargo/cargo["~position~"]/drop", drop);
  setprop("/models/cargo/cargo["~position~"]/ai", ai);

  var cargomodel = props.globals.getNode("/models/cargo/cargo["~position~"]", 1);
  var latN = cargomodel.getNode("latitude-deg",1);
  var lonN = cargomodel.getNode("longitude-deg",1);
  var altN = cargomodel.getNode("elevation-ft",1);
  var headN = cargomodel.getNode("heading-deg",1);
  var pitchN = cargomodel.getNode("pitch-deg",1);
  var rollN = cargomodel.getNode("roll-deg",1);
  var callsignN = cargomodel.getNode("callsign",1);
  var descriptionN = cargomodel.getNode("description",1);
  var weightN = cargomodel.getNode("weight",1);
  var heightN = cargomodel.getNode("height",1);
  var harnessN = cargomodel.getNode("harness",1);
  var stackN = cargomodel.getNode("stack",1);
  var dropN = cargomodel.getNode("drop",1);
  var aiN = cargomodel.getNode("ai",1);

  model.getNode("path", 1).setValue(path~"cargo"~number~".xml");
  model.getNode("latitude-deg-prop", 1).setValue(latN.getPath());
  model.getNode("longitude-deg-prop", 1).setValue(lonN.getPath());
  model.getNode("elevation-ft-prop", 1).setValue(altN.getPath());
  model.getNode("heading-deg-prop", 1).setValue(headN.getPath());
  model.getNode("pitch-deg-prop", 1).setValue(pitchN.getPath());
  model.getNode("roll-deg-prop", 1).setValue(rollN.getPath());
  model.getNode("callsign-prop", 1).setValue(callsignN.getPath());
  model.getNode("description-prop", 1).setValue(descriptionN.getPath());
  model.getNode("weight-prop", 1).setValue(weightN.getPath());
  model.getNode("height-prop", 1).setValue(heightN.getPath());
  model.getNode("harness-prop", 1).setValue(harnessN.getPath());
  model.getNode("stack-prop", 1).setValue(stackN.getPath());
  model.getNode("drop-prop", 1).setValue(dropN.getPath());
  model.getNode("ai-prop", 1).setValue(aiN.getPath());
  model.getNode("load", 1).remove();

  return model;
}

#degrees to radians
var deg2rad = func (deg) {
	var rad = deg * math.pi/180;
	return rad;
}

#round
var round = func (pos) {
	return math.round(pos * 1000) / 1000;
}

var normalize_h = func (x, min, max) {
  return (x - min) / (max - min);
}

var normalize_hr = func (x, minI, maxI, minO, maxO) {
  var r = maxO - minO;
  var t = normalize_h(x, minI, maxI);
  return (minO + (r * t));
}


###############################################################################
# On-screen displays
var enableOSD = func {
  var left  = screen.display.new(20, 10);
  var right = screen.display.new(-300, 10);

  left.add("/sim/cargo/state");

  right.add("/controls/switches/app-master");
}
#enableOSD();