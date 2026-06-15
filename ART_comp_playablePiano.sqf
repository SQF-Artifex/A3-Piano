
comment "

    MIT License

    Copyright (c) 2026 SQF Artifex

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the 'Software'), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.

";

ART_pianoCompPos = [0,0,0];
comment "Determine if execution context is composition and delete the helipad.";
if ((!isNull (findDisplay 312)) && (!isNil 'this')) then {
    if (!isNull this) then {
        if (typeOf this == 'Land_HelipadEmpty_F') then {
            ART_pianoCompPos = getPos this;
            deleteVehicle this;
        };
    };
};
if (isServer) then {
    if (!isNil 'this') then {
        if (!isNull this) then {
            if (typeOf this == 'Land_HelipadEmpty_F') then {
                ART_pianoCompPos = getPos this;
                deleteVehicle this;
            };
        };
    };
};
if (!isNull findDisplay 49) then {
    ART_pianoCompPos = getPos player;
};

0 = [] spawn {
    
    private _piano_base = createVehicle ["B_UAV_01_F", ART_pianoCompPos, [], 0, "CAN_COLLIDE"];
    _piano_base allowDamage false;
    "
    createVehicleCrew piano_base;
    piano_ai_group = createGroup [west, true];
    {
        _x allowDamage false;
        [_x] joinSilent piano_ai_group;
    } forEach crew piano_base;
    ";
    [_piano_base, true] remoteExec ['hideObjectGlobal', 2];
    [_piano_base, true] remoteExec ['hideObject']; 
    
    private _piano_p3d = createSimpleObject ["A3\structures_f_enoch\furniture\decoration\piano\piano.p3d", position _piano_base];
    _piano_p3d allowDamage false;
    _piano_p3d attachto [_piano_base, [0,0,0.315]]; 

    private _piano_actionObj = 'Land_InvisibleBarrier_F' createVehicle position _piano_base;
    _piano_actionObj setVariable ['baseCompObj', _piano_base, true];
    _piano_actionObj attachto [_piano_base, [-0.65,-0.77, -1]];  
    private _yaw = 0; 
    private _pitch = 0; 
    private _roll = 90; 
    _piano_actionObj setVectorDirAndUp [ 
    [sin _yaw * cos _pitch, cos _yaw * cos _pitch, sin _pitch], 
    [[sin _roll, -sin _pitch, cos _roll * cos _pitch], -_yaw] call BIS_fnc_rotateVector2D 
    ]; 
    private _piano_objects = [_piano_base, _piano_p3d, _piano_actionObj];

    {[_x, [_piano_objects, true]] remoteExec ['addCuratorEditableObjects', owner _x]} forEach allCurators;

    _piano_objects spawn {
        waitUntil {sleep 0.1;((count (_this select {isNull _x})) > 0)};
        {
            deleteVehicle _x;
        } forEach _this;
    };

    if (isNil 'M9SD_fnc_REinit2_V5') then {
        private _initREpack = [] spawn {
            comment "RE method 2, version 5";
            "REMOTE EXEC USAGE EXMAPLE:
                1. Define function you want to RE
                2. Init function with RE2 method
                3. Use RE2 funtion to run remotely
                1.
                    M9_fnc_someSpicyCode = {
                        ...
                    };
                2.
                    ['M9_fnc_someSpicyCode', 'spawn'] call M9SD_fnc_REinit2_V5;
                3.
                    [[], 'RE2_M9_fnc_someSpicyCodes', player] call M9SD_fnc_RE2_V5;
            ";
            if (!isNil 'M9SD_fnc_RE2_V5') exitWith {};
            comment "Initialize Remote-Execution Package";
            M9SD_fnc_initRE2_V5 = {
                M9SD_fnc_initRE2Functions_V5 = {
                    comment "Prep RE2 functions.";
                    M9SD_fnc_REinit2_V5 = {
                        params [['_functionName', ''], ['_schedule', 'call']];
                        private _functionNameRE2 = '';
                        "
                            if (isNil {
                                _functionNames
                            }) exitWith {
                                ''
                            };
                        ";
                        if !(_functionName isEqualType '') exitWith {
                            ''
                        };
                        "
                            if (count _functionNames == 0) exitWith {
                                ''
                            };
                        ";
                        '
                            private _functionNames = _this;
                        ';
                        private _aString = "";
                        private _namespaces = [missionNamespace, uiNamespace];
                        {
                            if !(_x isEqualType _aString) then {
                                continue
                            };
                            private _functionName = _x;
                            _functionNameRE2 = format ["RE2_%1", _functionName];
                            {
                                private _namespace = _x;
                                with _namespace do {
                                    if (!isNil _functionName) then {
                                        private _fnc = _namespace getVariable [_functionName, {}];
                                        private _fncStr = str _fnc;
                                        private _fncStr2 = "{
                                            " +
                                            "removeMissionEventHandler ['EachFrame', _thisEventHandler];
                                            " +
                                            "(_thisArgs # 0) " + _schedule + " " + _fncStr +
                                            "
                                        }";
                                        private _fncStrArr = _fncStr2 splitString '';
                                        _fncStrArr deleteAt (count _fncStrArr - 1);
                                        _fncStrArr deleteAt 0;
                                        _namespace setVariable [_functionNameRE2, _fncStrArr, true];
                                    };
                                };
                            } forEach _namespaces;
                        } forEach [_functionName];
                        '
                            true;
                        ';
                        _functionNameRE2;
                    };
                    M9SD_fnc_RE2_V5 = {
                        params [["_REarguments", []], ["_REfncName2", ""], ["_REtarget", player], ["_JIPparam", false]];
                        if (!((missionNamespace getVariable [_REfncName2, []]) isEqualType []) &&
                        !((uiNamespace getVariable [_REfncName2, []]) isEqualType [])) exitWith {
                            systemChat "::Error:: remoteExec failed (invalid _REfncName2 - not an array).";
                        };
                        if ((count (missionNamespace getVariable [_REfncName2, []]) == 0) &&
                        (count (uiNamespace getVariable [_REfncName2, []]) == 0)) exitWith {
                            systemChat "::Error:: remoteExec failed (invalid _REfncName2 - empty array).";
                            systemChat str _REfncName2;
                        };
                        if (isNil _REfncName2) then {
                            _REfncName2 = format ["RE2_%1", _REfncName2];
                        };
                        [[_REfncName2, _REarguments], {
                            if (isNil (_this # 0)) exitWith {};
                            addMissionEventHandler ["EachFrame", (missionNamespace getVariable [_this # 0, ['']]) joinString '', [_this # 1]];
                        }] remoteExec ['call', _REtarget, _JIPparam];
                    };
                    comment "
                        systemChat '[ RE2 Package ] : RE2 functions initialized.';
                    ";
                };
                M9SD_fnc_initRE2FunctionsGlobal_V5 = {
                    comment "Prep RE2 functions on all clients+jip.";
                    private _fncStr = format ["{
                        removeMissionEventHandler ['EachFrame', _thisEventHandler];
                        _thisArgs call %1
                    }", M9SD_fnc_initRE2Functions_V5];
                    _fncStr = _fncStr splitString '';
                    _fncStr deleteAt (count _fncStr - 1);
                    _fncStr deleteAt 0;
                    missionNamespace setVariable ["RE2_M9SD_fnc_initRE2Functions_V5", _fncStr, true];
                    [["RE2_M9SD_fnc_initRE2Functions_V5", []], {
                        addMissionEventHandler ["EachFrame", (missionNamespace getVariable ["RE2_M9SD_fnc_initRE2Functions_V5", ['']]) joinString '', _this # 1];
                    }] remoteExec ['call', 0, 'RE2_M9SD_JIP_initRE2Functions_V5'];
                    comment "
                        Delete from jip queue: remoteExec ['', 'RE2_M9SD_JIP_initRE2Functions_V5'];
                    ";
                };
                call M9SD_fnc_initRE2FunctionsGlobal_V5;
            };
            call M9SD_fnc_initRE2_V5;
            waitUntil {
                !isNil 'M9SD_fnc_RE2_V5'
            };
            if (true) exitWith {
                true
            };
            'so'; true;
        };
        waitUntil {
            scriptDone _initREpack
        };
        'RE Pack Initialized...';
    };

    waitUntil {(!isNil 'M9SD_fnc_REinit2_V5')};

    ART_fnc_initPiano = {
        params [['_piano_actionObj', objNull], ['_piano_objects', []]];
        if (isServer) then {
            {
                _x setVariable ['pianoObjs', _piano_objects];
                _x addEventHandler ["Deleted", {
                    params ["_entity"];
                    {
                        deleteVehicle _x;
                    } foreach (_entity getVariable ['pianoObjs', []]);
                }]; 
            } forEach _piano_objects;
        };
		comment "-----------------------------------------------";
		if (!hasInterface) exitWith {};
		waitUntil { !isNil { player } && { !isNull player } };
		waitUntil { !isNull (findDisplay 46) };
		comment "-----------------------------------------------";
        'removeAllActions _piano_actionObj;';
        _piano_actionObj addAction ["<t color='#FF82B6' size='2' font='Caveat'><img image='\a3\modules_f_curator\data\portraitmusic_ca.paa'></img><br/>Play Piano</t>", {
            params ["_target", "_caller", "_actionId", "_arguments"];
            if (_target getVariable ['seat_occupied', false]) exitWith {
                systemChat 'Piano is occupied!';
                playsound 'addItemFailed';
            };

            _target setVariable ['seat_occupied', true, true];

            _caller attachTo [_target getVariable ['baseCompObj', objNull], [-0.05,-1.24,-0.175]]; 
            [_caller, 'HubSittingAtTableU_idle3'] remoteExec ['switchMove'];

            _caller switchCamera 'external';


            "Init fncs";

            if (isNil 'ART_piano_noteLibrary') then {
                ART_piano_noteLibrary = createHashMapFromArray [
                    ['F4', 'a3\ui_f_curator\data\sound\cfgsound\ping01.wss'],
                    ['A4', 'a3\ui_f_curator\data\sound\cfgsound\ping02.wss'],
                    ['D5', 'a3\ui_f_curator\data\sound\cfgsound\ping03.wss'],
                    ['E5', 'a3\ui_f_curator\data\sound\cfgsound\ping04.wss'],
                    ['F5', 'a3\ui_f_curator\data\sound\cfgsound\ping05.wss'],
                    ['G5', 'a3\ui_f_curator\data\sound\cfgsound\ping06.wss'],
                    ['A5', 'a3\ui_f_curator\data\sound\cfgsound\ping07.wss']
                ];

                ART_fnc_piano_playNote = {
                    params ["_input"];

                    if (_input isEqualTo "REST") exitWith {};

                    private _playSingle = {
                        params ["_note"];

                        private _sound = ART_piano_noteLibrary get _note;
                        if (isNil "_sound") exitWith {};

                        playSound3D [
                            _sound,
                            player,
                            false,
                            getPosASL player,
                            5,
                            1,
                            400,
                            0,
                            false
                        ];
                    };

                    "If it's a chord (array), play all notes together";
                    if (_input isEqualType []) exitWith {
                        {
                            [_x] call _playSingle;
                        } forEach _input;
                    };

                    "Otherwise single note";
                    [_input] call _playSingle;
                };

                ART_fnc_piano_playSong = {
                    params ["_songName", ["_tempoOverride", -1]];

                    "waitUntil {isNull findDisplay 49};";

                    private _entry = ART_piano_songLibrary get _songName;
                    if (isNil "_entry") exitWith { hint "Song not found"; };

                    _entry params ["_notes", "_defaultTempo"];

                    private _tempo = if (_tempoOverride < 0) then {
                        _defaultTempo
                    } else {
                        _tempoOverride
                    };

                    private _fnc_playNoteWithUI = {
                        if (_this == 'REST') then {
                            [_this] call ART_fnc_piano_playNote;
                        } else {
                            if (!isNull (uiNamespace getVariable ['ART_piano_menu', displayNull])) then {
                                private _pianoMenu = uiNamespace getVariable ['ART_piano_menu', displayNull];
                                private _ctrl_pianoKey = _pianoMenu getVariable _this;
                                if ((isNil '_ctrl_pianoKey') or (isNull _ctrl_pianoKey)) then {
                                    [_this] call ART_fnc_piano_playNote;
                                } else {
                                    ctrlSetFocus _ctrl_pianoKey;
                                    _ctrl_pianoKey ctrlActivate true;
                                };
                            } else {
                                [_this] call ART_fnc_piano_playNote;
                            };
                        };
                    };

                    {
                        if (_x isEqualType []) then {
                            {
                                _x call _fnc_playNoteWithUI;
                            } forEach _x;
                        } else {
                            _x call _fnc_playNoteWithUI;
                        };
                        uiSleep _tempo;
                    } forEach _notes;

                    missionNamespace setVariable ['ART_piano_songPlaying', false];
                };

                ART_piano_songLibrary = createHashMapFromArray [

                    ["hot_cross_buns", [
                        ["E5","D5","F4","REST",
                        "E5","D5","F4","REST",
                        "F4","F4","F4","F4","REST",
                        "D5","D5","D5","D5","REST",
                        "E5","D5","F4"],
                        0.30
                    ]],

                    ["mary_lamb", [
                        [
                            ["E5","G5"], "D5", "F4", "D5", "REST",
                            ["E5","G5"], ["E5","G5"], ["E5","G5"], "REST",

                            "D5","D5","D5","REST",

                            ["E5","A5"], ["G5"], ["G5"], "REST",

                            ["E5","G5"], "D5", "F4", "D5", "REST",

                            ["E5","G5"], ["E5","G5"], ["E5","G5"], "REST",

                            "D5","D5",["E5","G5"],"D5","REST",

                            "F5"
                        ], 0.32
                    ]],

                    ["three_blind_mice", [
                        ["D5","E5","F5","REST",
                        "D5","E5","F5","REST",
                        "A5","A5","G5","F5","REST",
                        "D5","E5","F5"],
                        0.30
                    ]],

                    ["london_bridge", [
                        ["G5","A5","G5","F5","E5","F5","REST",
                        "D5","E5","F5","REST",
                        "F5","G5","A5","G5"],
                        0.34
                    ]],

                    ["twinkle", [
                        [
                            ["F5","A5"], ["F5","A5"], ["A5"], ["A5"],
                            ["G5"], ["G5"], "REST",

                            ["F5","A5"], ["F5","A5"], ["D5"], ["D5"],
                            ["E5"], ["E5"], "REST",

                            ["F5","A5"], ["A5"], ["G5"]
                        ],
                        0.36
                    ]],

                    ["baa_baa", [
                        ["D5","D5","A5","A5","G5","G5","REST",
                        "F5","F5","E5","E5","D5","REST"],
                        0.34
                    ]],

                    ["old_macdonald", [
                        ["G5","G5","G5","D5","E5","E5","D5","REST",
                        "A5","A5","G5","REST"],
                        0.38
                    ]],

                    ["row_row_row", [
                        ["D5","D5","D5","E5","F5","REST",
                        "F5","E5","F5","G5","A5","REST",
                        "A5","G5","F5"],
                        0.33
                    ]],

                    ["yankee_doodle", [
                        ["E5","E5","F5","G5","E5","REST",
                        "G5","A5","G5","E5","REST"],
                        0.32
                    ]],

                    ["ode_to_joy", [
                        ["E5","E5","F5","G5","G5","F5","E5","D5","REST",
                        "E5","D5","D5","REST"],
                        0.40
                    ]],

                    ["frere_jacques", [
                        ["D5","E5","F5","D5","REST",
                        "D5","E5","F5","D5","REST",
                        "F5","G5","A5","REST"],
                        0.36
                    ]],

                    ["happy_birthday", [
                        ["F5","F5","G5","F5","A5","G5","REST",
                        "F5","F5","G5","F5","D5","REST"],
                        0.38
                    ]],

                    ["skip_to_my_lou", [
                        ["D5","E5","F5","REST",
                        "D5","E5","F5","REST",
                        "F5","G5","A5","G5","F5"],
                        0.30
                    ]],

                    ["this_old_man", [
                        ["G5","E5","F5","E5","D5","REST",
                        "D5","E5","F5"],
                        0.35
                    ]],

                    ["rain_rain", [
                        ["A5","G5","F5","REST",
                        "A5","G5","F5","REST",
                        "F5","F5","E5","D5"],
                        0.33
                    ]],

                    ["imperial_march", [
                        ["D5","D5","D5","G5","D5","REST",
                        "A5","G5","F5","E5","D5","REST",
                        "D5","G5","D5"],
                        0.32
                    ]],

                    ["zelda_theme", [
                        ["D5","F5","G5","A5","G5","F5","E5","REST",
                        "D5","F5","G5","A5","G5"],
                        0.34
                    ]],

                    ["dragonborn", [
                        ["D5","D5","F5","D5","G5","REST",
                        "F5","E5","D5","REST",
                        "A5","G5","F5"],
                        0.38
                    ]],

                    ["halo", [
                        ["E5","F5","G5","F5","E5","D5","REST",
                        "E5","F5","G5","A5","G5"],
                        0.40
                    ]],

                    ["mission_impossible", [
                        ["E5","G5","E5","G5","E5","G5","A5","REST",
                        "A5","G5","F5","E5"],
                        0.28
                    ]],

                    ["tetris", [
                        ["E5","G5","A5","G5","F5","E5","D5","REST",
                        "D5","F5","G5","A5","G5"],
                        0.26
                    ]],

                    ["mario", [
                        ["E5","E5","E5","D5","E5","G5","REST",
                        "G5","F5","E5","D5","REST",
                        "F5","G5","A5"],
                        0.30
                    ]],

                    ["star_wars", [
                        ["D5","G5","F5","E5","D5","REST",
                        "A5","G5","F5","E5","D5"],
                        0.34
                    ]],

                    ["jaws", [
                        ["D5","E5","REST",
                        "D5","E5","REST",
                        "D5","E5","REST",
                        "D5","E5","G5"],
                        0.45
                    ]],

                    ["pirates", [
                        ["D5","E5","F5","G5","A5","G5","F5","E5",
                        "F5","G5","A5","G5","F5"],
                        0.30
                    ]],

                    ["arma_this_is_war", [
                        ["D5","G5","F5","E5","D5","REST",
                        "F5","A5","G5","F5","E5","D5","REST",
                        "D5","F5","A5"],
                        0.36
                    ]],

                    ["arma_contact", [
                        ["D5","F5","A5","G5","F5","D5","REST",
                        "E5","G5","A5","G5","F5","E5","D5"],
                        0.44
                    ]],

                    ["arma_apex_jungle", [
                        ["E5","F5","G5","A5","G5","F5","E5","D5","REST",
                        "F5","G5","A5","F5","E5"],
                        0.30
                    ]],

                    ["arma_tanks", [
                        ["D5","D5","F5","D5","G5","REST",
                        "A5","G5","F5","E5","D5","REST",
                        "F5","A5","F5"],
                        0.28
                    ]],

                    ["arma_memories", [
                        ["F5","E5","D5","E5","F5","REST",
                        "A5","G5","F5","E5","D5","REST",
                        "F5","G5","A5"],
                        0.42
                    ]],

                    ["arma_air_power", [
                        ["E5","F5","G5","A5","G5","F5","E5","REST",
                        "D5","E5","F5","G5","A5"],
                        0.32
                    ]],

                    ["arma_east_wind", [
                        ["D5","F5","E5","D5","REST",
                        "E5","F5","G5","F5","E5","D5","REST",
                        "F5","A5","G5"],
                        0.38
                    ]],

                    ["arma_zeus", [
                        ["F5","G5","A5","G5","F5","E5","D5","REST",
                        "F5","A5","F5","G5","E5"],
                        0.40
                    ]], 

                    ["minecraft_sweden", [
                        ["D5","F5","A5","F5","D5","REST",
                        "E5","F5","A5","G5","F5","D5","REST",
                        "D5","F5","A5"],
                        0.42
                    ]],

                    ["minecraft_alpha", [
                        ["F5","A5","G5","F5","E5","D5","REST",
                        "F5","A5","G5","F5","E5","D5","REST",
                        "D5","F5","A5"],
                        0.38
                    ]],

                    ["minecraft_subwoofer_lullaby", [
                        ["D5","D5","F5","A5","F5","D5","REST",
                        "E5","F5","G5","F5","D5","REST",
                        "D5","F5","A5"],
                        0.48
                    ]],

                    ["minecraft_wet_hands", [
                        ["F5","A5","G5","F5","E5","D5","REST",
                        "F5","A5","G5","F5","D5","REST",
                        "E5","F5","A5"],
                        0.44
                    ]],

                    ["minecraft_haggstrom", [
                        ["D5","F5","A5","F5","E5","F5","REST",
                        "G5","F5","E5","D5","REST",
                        "F5","A5","G5"],
                        0.34
                    ]],

                    ["minecraft_moog_city", [
                        ["F5","A5","F5","A5","G5","F5","REST",
                        "E5","F5","A5","G5","F5","REST",
                        "D5","F5","A5"],
                        0.30
                    ]],

                    ["minecraft_dry_hands", [
                        ["D5","F5","E5","D5","REST",
                        "F5","A5","G5","F5","REST",
                        "D5","E5","F5"],
                        0.46
                    ]]
                ];

                ART_piano_rateLimit = 0.05;

                "['london_bridge'] spawn ART_fnc_piano_playSong;";
            };


            "Init Menu";

            [_target, _caller] spawn {
                params ["_target", "_caller"];

                with uiNamespace do {
                    createDialog 'RscDisplayEmpty';
                    private _pianoMenu = findDisplay -1;
                    uiNamespace setVariable ['ART_piano_menu', _pianoMenu];

                    private _txtSize = safeZoneH * 1.125;

                    private _idk1 = _pianoMenu ctrlCreate ['RscStructuredText', -1];
                    _idk1 ctrlSetBackgroundColor [0.1,0.1,0.2,0.8];
                    _idk1 ctrlSetPosition [
                        0.448438 * safezoneW + safezoneX,
                        0.236 * safezoneH + safezoneY,
                        0.103125 * safezoneW,
                        0.022 * safezoneH
                    ];
                    _idk1 ctrlSetStructuredText parseText format ["<t size='%1' font='Caveat'><img image='a3\ui_f\data\igui\rscingameui\rscunitinfoairrtdfull\ico_cpt_music_on_ca.paa'></img>  %2</t>", _txtSize * 0.47, "Song Library"];
                    _idk1 ctrlCommit 0;
                    _idk1 ctrlEnable false;


                    private _idk2 = _pianoMenu ctrlCreate ['RscCheckbox', -1];
                    _idk2 ctrlSetPosition [
                        0.448438 * safezoneW + safezoneX,
                        0.423 * safezoneH + safezoneY,
                        0.0154688 * safezoneW,
                        0.022 * safezoneH
                    ];
                    _idk2 ctrlCommit 0;
                    _idk2 ctrlEnable false;
                    _idk2 ctrlShow false;


                    private _idk3 = _pianoMenu ctrlCreate ['RscText', -1];
                    _idk3 ctrlSetBackgroundColor [0,0.2,0,0.8];
                    _idk3 ctrlSetPosition [
                        0.448438 * safezoneW + safezoneX,
                        0.401 * safezoneH + safezoneY,
                        0.0825 * safezoneW,
                        0.022 * safezoneH
                    ];
                    _idk3 ctrlCommit 0;
                    _idk3 ctrlEnable false;
                    _idk3 ctrlShow false;


                    private _idk4 = _pianoMenu ctrlCreate ['RscText', -1];
                    _idk4 ctrlSetBackgroundColor [0.2,0,0,0.8];
                    _idk4 ctrlSetPosition [
                        0.530937 * safezoneW + safezoneX,
                        0.401 * safezoneH + safezoneY,
                        0.020625 * safezoneW,
                        0.022 * safezoneH
                    ];
                    _idk4 ctrlCommit 0;
                    _idk4 ctrlEnable false;
                    _idk4 ctrlShow false;


                    private _lb_songList = _pianoMenu ctrlCreate ['RscListbox', -1];
                    _pianoMenu setVariable ['songListBox', _lb_songList];
                    _lb_songList ctrlSetBackgroundColor [0.2, 0.065625, 0.11484375, 0.6];
                    _lb_songList ctrlSetPosition [
                        0.448438 * safezoneW + safezoneX,
                        0.258 * safezoneH + safezoneY,
                        0.103125 * safezoneW,
                        0.143 * safezoneH
                    ];
                    {
                        private _idx = _lb_songList lbAdd _x;
                        _lb_songList lbSetTooltip [_idx, _x];
                    } forEach (missionNamespace getVariable ['ART_piano_songLibrary', []]);
                    _lb_songList ctrlSetFontHeight (safeZoneH * 1.125 * 0.02);
                    _lb_songList ctrlCommit 0;


                    private _idk5 = _pianoMenu ctrlCreate ['RscButtonMenu', -1];
                    _idk5 ctrlSetBackgroundColor [0.0,0.2,0,0.8];
                    _idk5 ctrlSetPosition [
                        0.448438 * safezoneW + safezoneX,
                        0.401 * safezoneH + safezoneY,
                        0.103125 * safezoneW,
                        0.022 * safezoneH
                    ];
                    _idk5 ctrlSetStructuredText parseText format ["<t size='%1' font='Caveat'><img image='\a3\modules_f_curator\data\portraitmusic_ca.paa'></img>  %2</t>", _txtSize * 0.47, "Play"];
                    _idk5 ctrlSetTooltip 'Play selected song.';
                    _idk5 ctrlAddEventHandler ["ButtonClick", {
                        params ["_control"];
                        private _pianoMenu = ctrlParent _control;
                        if ((isNil '_pianoMenu') or (isNull _pianoMenu)) exitWith {};
                        private _lb_songList = _pianoMenu getVariable 'songListBox';
                        if ((isNil '_lb_songList') or (isNull _lb_songList)) exitWith {};
                        private _idx = lbCurSel _lb_songList;
                        if (_idx == -1) exitWith {};
                        private _songName = '';
                        _songName = _lb_songList lbText _idx;
                        if (_songName == '') exitWith {};
                        if (missionNamespace getVariable ['ART_piano_songPlaying', false]) exitWith {
                            playSound 'addItemFailed';
                            systemChat 'Piano:  A song is already playing!';
                            hint 'Piano:\n\nA song is already playing!';
                        };
                        missionNamespace setVariable ['ART_piano_songPlaying', true];
                        [_songName] spawn ART_fnc_piano_playSong;

                    }];
                    _idk5 ctrlCommit 0;


                    private _bg_notesBackground = _pianoMenu ctrlCreate ['IGUIBack', -1];
                    _bg_notesBackground ctrlSetBackgroundColor [1,1,1,0.58];
                    _bg_notesBackground ctrlSetText 'F4';
                    _bg_notesBackground ctrlSetPosition [
                        0.298906 * safezoneW + safezoneX,
                        0.456 * safezoneH + safezoneY,
                        0.402187 * safezoneW,
                        0.099 * safezoneH
                    ];
                    _bg_notesBackground ctrlCommit 0;
                    _bg_notesBackground ctrlEnable false;


                    private _keyTxtSize1 = _txtSize * 0.9 * 0.77;
                    private _keyTxtSize2 = _txtSize * 0.45;
                    private _keyFont1 = 'PuristaBold';
                    private _keyFont2 = 'PuristaLight';


                    "-----------------------------------------------------------------";

                    private _btn_note_F4 = _pianoMenu ctrlCreate ['RscButtonMenu', -1];
                    _btn_note_F4 ctrlSetStructuredText parseText format [
                        "<t size='%1' font='%2'>%3<br/><t size='%4' font='%5'>%6</t>", 
                        _keyTxtSize1, 
                        _keyFont1,
                        'F4', 
                        _keyTxtSize2, 
                        _keyFont2,
                        '[ 1 ]'
                    ];
                    _btn_note_F4 ctrlSetPosition [
                        0.324687 * safezoneW + safezoneX,
                        0.478 * safezoneH + safezoneY,
                        0.04125 * safezoneW,
                        0.055 * safezoneH
                    ];
                    _btn_note_F4 ctrlCommit 0;
                    _btn_note_F4 ctrlAddEventHandler ["ButtonClick", {
                        ['F4'] call ART_fnc_piano_playNote;
                    }];
                    _pianoMenu setVariable ['F4', _btn_note_F4];

                    "-----------------------------------------------------------------";

                    private _btn_note_A4 = _pianoMenu ctrlCreate ['RscButtonMenu', -1];
                    _btn_note_A4 ctrlSetStructuredText parseText format [
                        "<t size='%1' font='%2'>%3<br/><t size='%4' font='%5'>%6</t>", 
                        _keyTxtSize1, 
                        _keyFont1,
                        'A4', 
                        _keyTxtSize2, 
                        _keyFont2,
                        '[ 2 ]'
                    ];
                    _btn_note_A4 ctrlSetPosition [
                        0.37625 * safezoneW + safezoneX,
                        0.478 * safezoneH + safezoneY,
                        0.04125 * safezoneW,
                        0.055 * safezoneH
                    ];
                    _btn_note_A4 ctrlCommit 0;
                    _btn_note_A4 ctrlAddEventHandler ["ButtonClick", {
                        ['A4'] call ART_fnc_piano_playNote;
                    }];
                    _pianoMenu setVariable ['A4', _btn_note_A4];

                    "-----------------------------------------------------------------";

                    private _btn_note_D5 = _pianoMenu ctrlCreate ['RscButtonMenu', -1];
                    _btn_note_D5 ctrlSetStructuredText parseText format [
                        "<t size='%1' font='%2'>%3<br/><t size='%4' font='%5'>%6</t>", 
                        _keyTxtSize1, 
                        _keyFont1,
                        'D5', 
                        _keyTxtSize2, 
                        _keyFont2,
                        '[ 3 ]'
                    ];
                    _btn_note_D5 ctrlSetPosition [
                        0.427812 * safezoneW + safezoneX,
                        0.478 * safezoneH + safezoneY,
                        0.04125 * safezoneW,
                        0.055 * safezoneH
                    ];
                    _btn_note_D5 ctrlCommit 0;
                    _btn_note_D5 ctrlAddEventHandler ["ButtonClick", {
                        ['D5'] call ART_fnc_piano_playNote;
                    }];
                    _pianoMenu setVariable ['D5', _btn_note_D5];

                    "-----------------------------------------------------------------";

                    private _btn_note_E5 = _pianoMenu ctrlCreate ['RscButtonMenu', -1];
                    _btn_note_E5 ctrlSetStructuredText parseText format [
                        "<t size='%1' font='%2'>%3<br/><t size='%4' font='%5'>%6</t>", 
                        _keyTxtSize1, 
                        _keyFont1,
                        'E5', 
                        _keyTxtSize2, 
                        _keyFont2,
                        '[ 4 ]'
                    ];
                    _btn_note_E5 ctrlSetPosition [
                        0.479375 * safezoneW + safezoneX,
                        0.478 * safezoneH + safezoneY,
                        0.04125 * safezoneW,
                        0.055 * safezoneH
                    ];
                    _btn_note_E5 ctrlCommit 0;
                    _btn_note_E5 ctrlAddEventHandler ["ButtonClick", {
                        ['E5'] call ART_fnc_piano_playNote;
                    }];
                    _pianoMenu setVariable ['E5', _btn_note_E5];

                    "-----------------------------------------------------------------";

                    private _btn_note_F5 = _pianoMenu ctrlCreate ['RscButtonMenu', -1];
                    _btn_note_F5 ctrlSetStructuredText parseText format [
                        "<t size='%1' font='%2'>%3<br/><t size='%4' font='%5'>%6</t>", 
                        _keyTxtSize1, 
                        _keyFont1,
                        'F5', 
                        _keyTxtSize2, 
                        _keyFont2,
                        '[ 5 ]'
                    ];
                    _btn_note_F5 ctrlSetPosition [
                        0.530937 * safezoneW + safezoneX,
                        0.478 * safezoneH + safezoneY,
                        0.04125 * safezoneW,
                        0.055 * safezoneH
                    ];
                    _btn_note_F5 ctrlCommit 0;
                    _btn_note_F5 ctrlAddEventHandler ["ButtonClick", {
                        ['F5'] call ART_fnc_piano_playNote;
                    }];
                    _pianoMenu setVariable ['F5', _btn_note_F5];

                    "-----------------------------------------------------------------";

                    private _btn_note_G5 = _pianoMenu ctrlCreate ['RscButtonMenu', -1];
                    _btn_note_G5 ctrlSetStructuredText parseText format [
                        "<t size='%1' font='%2'>%3<br/><t size='%4' font='%5'>%6</t>", 
                        _keyTxtSize1, 
                        _keyFont1,
                        'G5', 
                        _keyTxtSize2, 
                        _keyFont2,
                        '[ 6 ]'
                    ];
                    _btn_note_G5 ctrlSetPosition [
                        0.5825 * safezoneW + safezoneX,
                        0.478 * safezoneH + safezoneY,
                        0.04125 * safezoneW,
                        0.055 * safezoneH
                    ];
                    _btn_note_G5 ctrlCommit 0;
                    _btn_note_G5 ctrlAddEventHandler ["ButtonClick", {
                        ['G5'] call ART_fnc_piano_playNote;
                    }];
                    _pianoMenu setVariable ['G5', _btn_note_G5];

                    "-----------------------------------------------------------------";

                    private _btn_note_A5 = _pianoMenu ctrlCreate ['RscButtonMenu', -1];
                    _btn_note_A5 ctrlSetStructuredText parseText format [
                        "<t size='%1' font='%2'>%3<br/><t size='%4' font='%5'>%6</t>", 
                        _keyTxtSize1, 
                        _keyFont1,
                        'A5', 
                        _keyTxtSize2, 
                        _keyFont2,
                        '[ 7 ]'
                    ];
                    _btn_note_A5 ctrlSetPosition [
                        0.634062 * safezoneW + safezoneX,
                        0.478 * safezoneH + safezoneY,
                        0.04125 * safezoneW,
                        0.055 * safezoneH
                    ];
                    _btn_note_A5 ctrlCommit 0;
                    _btn_note_A5 ctrlAddEventHandler ["ButtonClick", {
                        ['A5'] call ART_fnc_piano_playNote;
                    }];
                    _pianoMenu setVariable ['A5', _btn_note_A5];

                    "-----------------------------------------------------------------";

                    _pianoMenu displayAddEventHandler ['keyDown',{
                        params ["_pianoMenu", "_key", "_shift", "_ctrl", "_alt"];

                        private _rateLimitVar = format ["keyTime_%1", _key];
                        private _lastPress = _pianoMenu getVariable [_rateLimitVar, 0];

                        if ((diag_tickTime - _lastPress) < ART_piano_rateLimit) exitWith {};

                        _pianoMenu setVariable [_rateLimitVar, diag_tickTime];

                        switch (_key) do {
                            case 2: {
                                private _ctrl_F4 = _pianoMenu getVariable 'F4';
                                if ((isNil '_ctrl_F4') or (isNull _ctrl_F4)) exitWith {};
                                ctrlSetFocus _ctrl_F4;
                                _ctrl_F4 ctrlActivate true;
                            };
                            case 3: {                            
                                private _ctrl_A4 = _pianoMenu getVariable 'A4';
                                if ((isNil '_ctrl_A4') or (isNull _ctrl_A4)) exitWith {};
                                ctrlSetFocus _ctrl_A4;
                                _ctrl_A4 ctrlActivate true;
                            };
                            case 4: {
                                private _ctrl_D5 = _pianoMenu getVariable 'D5';
                                if ((isNil '_ctrl_D5') or (isNull _ctrl_D5)) exitWith {};
                                ctrlSetFocus _ctrl_D5;
                                _ctrl_D5 ctrlActivate true;
                            };
                            case 5: {
                                private _ctrl_E5 = _pianoMenu getVariable 'E5';
                                if ((isNil '_ctrl_E5') or (isNull _ctrl_E5)) exitWith {};
                                ctrlSetFocus _ctrl_E5;
                                _ctrl_E5 ctrlActivate true;
                            };
                            case 6: {
                                private _ctrl_F5 = _pianoMenu getVariable 'F5';
                                if ((isNil '_ctrl_F5') or (isNull _ctrl_F5)) exitWith {};
                                ctrlSetFocus _ctrl_F5;
                                _ctrl_F5 ctrlActivate true;
                            };
                            case 7: {
                                private _ctrl_G5 = _pianoMenu getVariable 'G5';
                                if ((isNil '_ctrl_G5') or (isNull _ctrl_G5)) exitWith {};
                                ctrlSetFocus _ctrl_G5;
                                _ctrl_G5 ctrlActivate true;
                            };
                            case 8: {
                                private _ctrl_A5 = _pianoMenu getVariable 'A5';
                                if ((isNil '_ctrl_A5') or (isNull _ctrl_A5)) exitWith {};
                                ctrlSetFocus _ctrl_A5;
                                _ctrl_A5 ctrlActivate true;
                            };
                            case 1: {_pianoMenu closeDisplay 0};
                            default {};
                        };
                    }];

                    "-----------------------------------------------------------------";

                    [_target, _caller, _pianoMenu] spawn {
                        params ["_target", "_caller", "_pianoMenu"];
                        private _baseCompObj = _target getVariable ['baseCompObj', objNull];
                        waitUntil {sleep 0.1; (
                            (isNull _target) or 
                            (isNull _caller) or 
                            (!alive _caller) or 
                            (lifeState _caller == 'INCAPACITATED') or 
                            (!(attachedTo _caller == _baseCompObj)) or 
                            (isNull _pianoMenu)
                        )};

                        missionNamespace setVariable ['ART_piano_songPlaying', false];

                        if (!isNil '_pianoMenu') then {
                            if (!isNull _pianoMenu) then {
                                _pianoMenu closeDisplay 0;
                            };
                        };
                        
                        
                        if (!isNull _target) then {
                            _target setVariable ['seat_occupied', false, true];
                        };

                        if (isNull _caller) exitWith {};

                        if ((!alive _caller) or (lifeState _caller == 'INCAPACITATED')) exitWith {
                            if (attachedTo _caller == _baseCompObj) then {
                                detach _caller;
                            };
                        };

                        if (!(attachedTo _caller == _baseCompObj)) exitWith {
                            if (animationState _caller == 'HubSittingAtTableU_idle3') then {
                                _caller switchMove '';
                                [_caller, ''] remoteExec ['switchMove'];
                            };
                        };

                        if (attachedTo _caller == _baseCompObj) then {
                            detach _caller;
                        };

                        if (animationState _caller == 'HubSittingAtTableU_idle3') then {
                            _caller switchMove '';
                            [_caller, ''] remoteExec ['switchMove'];
                        };
                    };

                };
            };
        }, nil, 9999, true, true, '', "(
            (!(_target getVariable ['seat_occupied', false])) && 
            (_this == vehicle _this)
        )", 4, false, '', ''];
    };

    if (isNil 'RE2_ART_fnc_initPiano') then {
        ['ART_fnc_initPiano', 'spawn'] call M9SD_fnc_REinit2_V5;
    };

    comment 'Wait for function to be ready';
    waitUntil {!isNil 'RE2_ART_fnc_initPiano'}; 
    [[_piano_actionObj, _piano_objects], 'RE2_ART_fnc_initPiano', 0, _piano_actionObj] call M9SD_fnc_RE2_V5; 
};
