# Cargo-Towing-Addon
Allows for a quick and easy method (addon) to add cargo hauling and stacking capability to any FlightGear aircraft.

Configuration required:

For now, insure the aircraft this addon is applied to has the added pointmass entries if needed, including
UH-1, ch47, dauphin, H-C21

addon-config.xml
(lines 40-46)

    <!-- offset from wheelbase to top of rope in meters -->

    <!-- AirCrane -->
    <offset type="double">2.87</offset>
    <!-- UH-1 -->
    <offset type="double">2.86</offset>
    <!-- ch47 -->
    <offset type="double">2.86</offset>
    <!-- Dauphin -->
    <offset type="double">2.84</offset>
    <!-- H-C21 -->
    <offset type="double">5.1</offset>

cargotow.xml
(lines 16-24)

    <!-- position the rope model at the airframe-->

    <offsets>
        <!-- AirCrane -->
        <x-m>0.0</x-m>
        <y-m>0.0</y-m>
        <z-m>0.0</z-m>
        <!-- UH-1 -->
        <x-m>-2.5 </x-m>
        <y-m> 0.0 </y-m>
        <z-m> 0.05</z-m>
        <!-- ch47 -->
        <x-m>2.2</x-m>
        <y-m>0.0</y-m>
        <z-m>0.0</z-m>
        <!-- dauphin -->
        <x-m>0.7</x-m>
        <y-m>0.0</y-m>
        <z-m>0.0</z-m>
        <!-- H-C21 -->
        <x-m>-3.55</x-m>
        <y-m>1.6</y-m>
        <z-m>2.0</z-m>
    </offsets>

cargooperations.nas
(lines 320-323)

    <!-- pointmass designated for the cargo weight to be applied to -->

    #JSBSim -
    var aircraftPointmass = props.globals.getNode("/fdm/jsbsim/inertia/pointmass-weight-lbs[1]", 1);

    #YASim -
    #AirCrane, ch47, dauphin
    var aircraftPointmass = props.globals.getNode("sim/weight[3]/weight-lb", 1);
    #UH-1
    var aircraftPointmass = props.globals.getNode("sim/weight[6]/weight-lb", 1);
    #H-C21
    var aircraftPointmass = props.globals.getNode("sim/weight[5]/weight-lb", 1);

TODO:
Add runtime weight pointmasses to all aircraft through a GUI/nasal interface or add permanent pointmas in the aircraft configuration file. 
Add weight values through a GUI interface to all AI scenario entries
GUI rope scale adjustment
GUI per aircraft rope positioning dropdown configuration
GUI slider rope positioning configuration
