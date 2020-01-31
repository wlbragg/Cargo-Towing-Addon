Cargo Towing - Cargo Towing Addon for Flightgear
Written and developed by Wayne Bragg (wlbragg)
Copyright (C) 2020 Wayne Bragg
Rope animation code by Thorsten Renk (Thorsten)
Copyright (C) 2017 Thorsten Renk
README.md
Version 1.0.0 beta 1/21/2020
Cargo Towing is licensed under the Gnu Public License v3+ (GPLv3+)

Allows for a quick and easy method (addon) to add cargo hauling and stacking capability to any FlightGear aircraft.

##########################################################
Configuration
(not manditory if existing load points are alvailible)
##########################################################

For now, insure the aircraft using this addon has any additional
load points added to the FDM and .set, or use defaults availible
in the existing airceaft configuration.

EXAMPLES... (not manditory if existing load points are alvailible)

YASim
FDM
<weight x="1.364" y="1.623"  z="1.753" mass-prop="/sim/weight[3]/weight-lb"/>
.set
<weight n="3">
	<name>Longline</name>
	<weight-lb>0</weight-lb>
	<max-lb>50000</max-lb>
</weight>


JSBSim
FDM
<pointmass name="Longline">
    <weight unit="LBS"> 0 </weight>
    <location name="POINTMASS" unit="IN">
        <x> 30.29 </x>
        <y>  0 </y>
        <z> 26.6 </z>
    </location>
</pointmass>
.set
<payload>
    <weight>
        <name type="string">Longline</name>
        <weight-lb alias="/fdm/jsbsim/inertia/pointmass-weight-lbs[3]"/>
        <arm-in alias="/fdm/jsbsim/inertia/pointmass-location-X-inches[0]"/>
        <min-lb type="double">0.0</min-lb>
        <max-lb type="double">50000.0</max-lb>
    </weight>
</payload>

See aircraft.xml for list of preset load points you can add to existing aircraft (optional)

##########################################################
Availible global variables for aircraft use
##########################################################
sim/cargo/rope/length
sim/cargo/load/weight

#########################################################
TODO:
#########################################################
Attach a height and weight field to AI scenario models for user input.
Add rope animations to AI scenario models
Fix bug in AI scenario model sync with rope length
Select pre-selections in the lists in the rope configuration GUI
