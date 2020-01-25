# Cargo-Towing-Addon
Allows for a quick and easy method (addon) to add cargo hauling and stacking capability to any FlightGear aircraft.

Configuration required:

addon-config.xml
(lines 40-46)

    <!-- offset from wheelbase to top of rope in meters -->

    <!-- AirCrane -->
    <!-- offset type="double">2.87</offset-->
    <!-- UH-1 -->
    <offset type="double">2.855</offset>

cargotow.xml
(lines 16-24)

    <!-- position the rope model at the airframe-->

    <offsets>
        <!-- AirCrane -->
        <!--x-m>0.0</x-m>
        <y-m>0.0</y-m>
        <z-m>0.0</z-m-->
        <!-- UH-1 -->
        <x-m>-2.5 </x-m>
        <y-m> 0.0 </y-m>
        <z-m> 0.05</z-m>
    </offsets>

cargooperations.nas
(lines 320-323)

    <!-- pointmass designated for the cargo weight to be applied to -->

    #AirCrane
    #var cargo_load_on_aircraft = props.globals.getNode("sim/weight[3]/weight-lb", 1);
    #UH-1
    var cargo_load_on_aircraft = props.globals.getNode("sim/weight[6]/weight-lb", 1);


