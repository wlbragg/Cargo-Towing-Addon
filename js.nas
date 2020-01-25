# Cargo Towing - Cargo Towing capability for Flightgear
# Written and developer by Wayne Bragg (wlbragg)
# Copyright (C) 2020 Wayne Bragg
# js.nas
# Launcher script
# Version 1.0.0 beta 1/21/2020
# Cargo Towing is licensed under the Gnu Public License v3+ (GPLv3+)

var autostart = func (msg=1) {
    aircrane.autostart();
};

var slewProp = func(prop, delta) {
    #delta *= getprop("/sim/time/delta-realtime-sec");
    var limit = getprop("/sim/cargo/rope/segments-reeled-in") + delta;
    if (0 <= limit and limit <= 86) {
        setprop(prop, getprop(prop) + delta);
        return getprop(prop); # must read again because of clamping
    }
}