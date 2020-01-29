# Cargo-Towing-Addon
Allows for a quick and easy method (addon) to add cargo hauling and stacking capability to any FlightGear aircraft.

Configuration required:

For now, insure the aircraft this addon is applied to has the added pointmass or weight entries needed.

EXAMPLES...

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

ADDON
cargooperations.nas
(lines 320-323)

    <!-- pointmass designated for the cargo weight to be applied to -->

    #JSBSim -
    var aircraftPointmass = props.globals.getNode("/fdm/jsbsim/inertia/pointmass-weight-lbs[1]", 1);

These weight designation positions are entries I have been making to aircraft in fgaddon locally to my FlightGear.
Eventually I may push them to fgaddon so users don't have to configure it.

    #AirCrane, ch47, dauphin, Lynx WG13
    var aircraftPointmass = props.globals.getNode("sim/weight[3]/weight-lb", 1);
    #UH-1, bo105, ec135, OH-1
    var aircraftPointmass = props.globals.getNode("sim/weight[6]/weight-lb", 1);
    #H-21C
    var aircraftPointmass = props.globals.getNode("sim/weight[5]/weight-lb", 1);
    #ka50
    var aircraftPointmass = props.globals.getNode("sim/weight[4]/weight-lb", 1);


TODO:
Add permanent pointmas in the aircraft configuration file. 
Add weight values through a GUI interface to all AI scenario entries
Model a winch swing arm
GUI positioning of the winch swing arm
Set default rope config after scaling rope to fit aircraft size