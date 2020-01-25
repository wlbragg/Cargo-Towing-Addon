# Cargo-Towing-Addon
Allows for a quick and easy method (addon) to add cargo hauling and stacking capability to any FlightGear aircraft.

Configuration required:

For now, insure the aircraft this addon is applied to has the added pointmass entries if needed,including
UH-1, ch47, dauphin 

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
    </offsets>

cargooperations.nas
(lines 320-323)

    <!-- pointmass designated for the cargo weight to be applied to -->

    #AirCrane, ch47, dauphin
    var cargo_load_on_aircraft = props.globals.getNode("sim/weight[3]/weight-lb", 1);
    #UH-1
    var cargo_load_on_aircraft = props.globals.getNode("sim/weight[6]/weight-lb", 1);


TODO:
Add runtim weight pointmasses to all aircraft through a GUI/nasal interface or add permanent pointmas in the aircraft configuration file. 
Add weight values through a GUI interface to all AI scenario entries
