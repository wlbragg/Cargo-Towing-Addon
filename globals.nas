# Cargo Towing - Cargo Towing capability for Flightgear
# Written and developer by Wayne Bragg wlbragg
# Copyright (C) 2020 Wayne Bragg
# global.nas
# Launcher script
# Version 1.0.0 beta 1/21/2020
# Cargo Towing is licensed under the Gnu Public License v3+ (GPLv3+)

var RGAtcTitle = "Red Griffin ATC";

var min_distance = 0.25;
var min_near_distance = 0.1;
var max_runway_alignment_degrees = 5;
var min_ground_altitude = 30;
var max_airport_range = 3;
var atc_callback_seconds_counter = -1;
var atc_callback_wait_seconds = -1;
var timer_interval = 2;
var departure_extra_time = 0;
var max_radios = 20;
var radioButton = [];
var radioButtonFrequency = [];

var auto_reply_off = -1;
var min_cleared_takeoff_secs = 12;
var max_cleared_takeoff_secs = 40 - min_cleared_takeoff_secs;
var wait_after_take_off = 15;
var max_departure_secs = 120;
var extra_departure_secs = 120;
var max_take_off_secs = 60;
var land_check_secs = 15;
var welcome_airport_secs = 15;

var com1quality = nil;
var com1volume = nil;
var com1serviceable = nil;
var com2quality = nil;
var com2volume = nil;
var com2serviceable = nil;
var selectedComRadio = "";

var initialized = 0;
var callsign = "";
var aircraftManufacturer = "";
var availableRadio = {};
var currentRadioStationId = "";
var radioListHasChanged = 0;

var qualityThreshold = 0.01;

var airportRunwayInUse = "";
var airportRunwayInUseILS = nil;

var approach_point_altitude = 3000;
var approach_point_distance = -10;
var min_distance_for_altitude_change = 8;
var miles_altitude_step = 10;
var feet_altitude_step = 1000;

var last_key = 0;
var reset_key_interval = 10;
var key_press_counter = 0;
var binding_key_num = 92;
var binding_key_name = "\\";
var binding_key_description = "backslash";
var binding_key_num_msg1 = 28;
var binding_key_num_msg2 = 29;
var binding_key_num_msg3 = 30;
var binding_key_num_msg4 = 31;

var update_dialog = 0;
var update_popup = 1;
var update_data_only = 2;

var position_unknown = -1;
var position_ground = 1;
var position_runway = 2;
var position_flying = 3;

var status_going_around = 1;
var status_ready_for_departure = 2;
var status_cleared_for_takeoff = 3;
var status_took_off = 4;
var status_flying = 5;
var status_requested_approach = 6;
var status_requested_ils = 7;
var status_cleared_for_land = 8;
var status_landed = 9;

var aircraft_status = status_going_around;

var radio_station_type_unknown = -1;
var radio_station_type_ground = 1;
var radio_station_type_tower = 2;
var radio_station_type_atis = 3;
var radio_station_type_approach_departure = 4;
var radio_station_type_clearance = 5;

var radio_station_type = nil;
var radio_station_airport_id = nil;
var radio_station_name = nil;
var radio_station_frequency = nil;
var radio_station_distance = nil;
var radio_station_bearing = nil;
var radio_signal_quality = nil;

var radio_type_exact_match = 1;
var radio_type_any = 2;

var meteo_type_full = 1;
var meteo_type_wind = 2;

var runway_take_off = 1;
var runway_landing = 2;

var spell_text = 1;
var spell_number = 2;
var spell_number_to_literal = 3;
var spell_runway = 4;

var message_none = -1;
var message_radio_check = 1;
var message_engine_start = 2;
var message_departure_information = 3;
var message_request_taxi = 4;
var message_ready_departure = 5;
var message_request_approach = 6;
var message_request_ils = 7;
var message_airfield_in_sight = 8;
var message_ils_established = 9;

var (dialogWidth, dialogHeight) = (450, 120);
var popup_window_bg_color = [0.0, 0.0, 0.0, 0.35];
var popup_window_fg_color = [1.0, 1.0, 0.5, 1];
var popup_top_position = -20;
var dlgWindow = nil;
var dlgCanvas = nil;
var dlgRoot = nil;
var dlgLayout = nil;
var radioBox = nil;
var radioList = nil;
var radioScroll = nil;
var radioScrollContent = nil;
var txtAirport = nil;
var txtAirportPosition = nil;
var txtCurrentRadio = nil;
var txtCurrentRadioSpecs = nil;
var btnMessage = [nil, nil, nil, nil];
var btnAvailableRadio = nil;
var dialogOpened = 0;
var currentAirport = nil;
var currentRunway = "";
var alignedOnRunway = 0;
var nearRunway = 0;
var atcMessageType = [message_none, message_none, message_none, message_none];

var atcMessageRequest = {
                         radio_check:"Radio Check",
                         engine_start:"Request Engine Start",
                         departure_information:"Departure Information",
                         request_taxi:"Request Taxi",
                         ready_departure:"Ready for Departure",
                         request_approach:"Request Approach",
                         request_ils:"Request ILS",
                         airfield_in_sight:"Airfield in Sight",
                         ils_established:"ILS Established"
                        };

var atcMessageReply = {
                       radio_check:"%s %s, %s, Reading you %s.%s",
                       engine_start:"%s %s, %s, Start up approved.\nDeparture Runway %s, QNH %s %s or %s %s.\nReport when ready to taxi.",
                       departure_information:"%s %s, %s.\nDeparture Runway %s, %s.\nCorrect time %s.",
                       request_taxi:"%s %s, %s.\nTaxi to hold short of runway %s.\n%s.",
                       ready_departure:"%s %s, %s.\nLine up and wait. Get ready for departure.",
                       request_pattern_approach:"%s %s, %s. Cleared to approach.\n%sHeading %s for %s miles to join %s pattern,\nthen turn %s and then turn %s to final %srunway %s with %s feet.\n%s",
                       request_approach:"%s %s, %s. Cleared to approach.\n%sHeading %s for %s miles then turn to %s final %srunway %s with %s feet.\n%s",
                       request_pattern_ils:"%s %s, %s.\n%sHeading %s for %s miles to join %s pattern,\nthen turn %s to intercept the %slocalizer.\nCleared %s runway %s, maintain %s feet until established.\n%s",
                       request_ils:"%s %s, %s.\n%sHeading %s for %s miles to intercept the %slocalizer.\nCleared %s runway %s, maintain %s feet until established.\n%s",
                       airfield_in_sight:"%s %s, %s. %s. Cleared to land runway %s."
                      };

var phoneticLetter = {
                      A:"Alpha",
                      B:"Bravo",
                      C:"Charlie",
                      D:"Delta",
                      E:"Echo",
                      F:"Fox trot",
                      G:"Golf",
                      H:"Hotel",
                      I:"India",
                      J:"Juliet",
                      K:"Kilo",
                      L:"Leema",
                      M:"Mike",
                      N:"November",
                      O:"Oscar",
                      P:"Papa",
                      Q:"Quebec",
                      R:"Romeo",
                      S:"Sierra",
                      T:"Tango",
                      U:"Uniform",
                      V:"Victor",
                      W:"Whiskey",
                      X:"X ray",
                      Y:"Yankee",
                      Z:"Zulu"
                     };

var phoneticDigit = {
                     0:"Zero",
                     1:"One",
                     2:"Two",
                     3:"Three",
                     4:"Fower",
                     5:"Five",
                     6:"Six",
                     7:"Seven",
                     8:"Eight",
                     9:"Niner"
                    };

var phoneticNumber = {
                        0:"Zero",
                        1:"One",
                        2:"Two",
                        3:"Three",
                        4:"Fower",
                        5:"Five",
                        6:"Six",
                        7:"Seven",
                        8:"Eight",
                        9:"Niner",
                       10:"Ten",
                       11:"Eleven",
                       12:"Twelve",
                       13:"Thirteen",
                       14:"Fourteen",
                       15:"Fifteen",
                       16:"Sixteen",
                       17:"Seventeen",
                       18:"Eighteen",
                       19:"Nineteen"
                     };

var phoneticTen = {
                    0:"",
                    1:"Ten",
                    2:"Twenty",
                    3:"Thirty",
                    4:"Forty",
                    5:"Fifty",
                    6:"Sixty",
                    7:"Seventy",
                    8:"Eighty",
                    9:"Ninety"
                  };
