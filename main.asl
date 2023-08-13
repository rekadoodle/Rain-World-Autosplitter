
//TODO consider fast shelters and maybe other mechanics with IGT
//TODO improve response time of auto-start with processManager.upcomingProcess or actually inspecting the hud elements

state("RainWorld", "v1.9 Steam") {
        // i don't know the syntax for almost all of this currently so we have a bunch of long addresses 
        // int rainWorld : "mono-2.0-bdwgc.dll", 0x003A6CCC, 0x18, 0x30, 0xEA0;
        // string32 room : new MemoryWatcher<int>(new DeepPointer((IntPtr)current.rainWorld, 0xC, 0xC, 0x1C, 0x10, 0x8, 0x10, 0xC, 0xC));



        
        string32 room : "mono-2.0-bdwgc.dll", 0x003A6CCC, 0x18, 0x30, 0xEA0, 0xC, 0xC, 0x1C, 0x10, 0x8, 0x10, 0xC, 0xC;

        // int totTime : "mono-2.0-bdwgc.dll", 0x003A6CCC, 0x18, 0x30, 0xEA0, 0xC, 0xC, 0x4C, 0x20, 0x88;
        // int deathTime : "mono-2.0-bdwgc.dll", 0x003A6CCC, 0x18, 0x30, 0xEA0, 0xC, 0xC, 0x4C, 0x20, 0x3C, 0x80;
        byte4 storyGameSession : "mono-2.0-bdwgc.dll", 0x003A6CCC, 0x18, 0x30, 0xEA0, 0xC, 0xC, 0x4C;
        int time : "mono-2.0-bdwgc.dll", 0x003A6CCC, 0x18, 0x30, 0xEA0, 0xC, 0xC, 0x4C, 0x40, 0x10, 0x28;
        int playerGrabbedTime : "mono-2.0-bdwgc.dll", 0x003A6CCC, 0x18, 0x30, 0xEA0, 0xC, 0xC, 0x4C, 0x40, 0x10, 0x2c;

        string32 mainProcessName : "mono-2.0-bdwgc.dll", 0x003A6CCC, 0x18, 0x30, 0xEA0, 0xC, 0xC, 0xC, 0x8, 0xC;
        string32 oldProcessName : "mono-2.0-bdwgc.dll", 0x003A6CCC, 0x18, 0x30, 0xEA0, 0xC, 0x2C, 0xC, 0x8, 0xC;
        string32 gameInitConditionName : "mono-2.0-bdwgc.dll", 0x003A6CCC, 0x18, 0x30, 0xEA0, 0xC, 0x58, 0x8, 0x8, 0xC;

        bool startButtonPressed : "mono-2.0-bdwgc.dll", 0x003A6CCC, 0x18, 0x30, 0xEA0, 0xC, 0xC, 0x0e0, 0x058;
        string32 startButtonLabel : "mono-2.0-bdwgc.dll", 0x003A6CCC, 0x18, 0x30, 0xEA0, 0xC, 0xC, 0x0e0, 0x038, 0x040, 0x00c;
    }

startup {

    settings.Add("start_new", true, "New game starts timer");
    settings.Add("start_load", false, "Opening a save starts timer");

    IDictionary<string, string[]> all_rooms = new Dictionary<string, string[]>();
    all_rooms["Gate Rooms"] = new string[] {"GATE_CC_UW","GATE_DM_SL","GATE_DS_CC","GATE_DS_GW","GATE_DS_SB","GATE_GW_SH","GATE_GW_SL","GATE_HI_CC","GATE_HI_GW","GATE_HI_SH","GATE_HI_VS","GATE_LF_SB","GATE_LF_SU","GATE_MS_SL","GATE_OE_SU","GATE_SB_OE","GATE_SB_SL","GATE_SB_VS","GATE_SH_SL","GATE_SH_UW","GATE_SI_CC","GATE_SI_LF","GATE_SI_VS","GATE_SL_CL","GATE_SL_DM","GATE_SL_MS","GATE_SL_VS","GATE_SS_UW","GATE_SU_DS","GATE_SU_HI","GATE_UW_LC","GATE_UW_SL","GATE_UW_SS"};
    all_rooms["Outskirts"] = new string[] {"SU_A02","SU_A04","SU_A06","SU_A07","SU_A10","SU_A12","SU_A13","SU_A17","SU_A20","SU_A22","SU_A23","SU_A24","SU_A25","SU_A29","SU_A30","SU_A31","SU_A32","SU_A33","SU_A34","SU_A35","SU_A36","SU_A37","SU_A38","SU_A39","SU_A40","SU_A41","SU_A42","SU_A43","SU_A44","SU_A45","SU_A53","SU_A63","SU_B01","SU_B02","SU_B04","SU_B05","SU_B06","SU_B07","SU_B08","SU_B09","SU_B10","SU_B11","SU_B12","SU_B13","SU_B14","SU_B14SAINT","SU_C01","SU_C02","SU_C04","SU_CAVE01","SU_CAVE02","SU_CAVE03","SU_CAVE04","SU_CAVE05","SU_INTRO01","SU_PMPSTATION01","SU_PS1","SU_PUMP03","SU_S01","SU_S03","SU_S04","SU_S05","SU_VR1"};
    all_rooms["Industrial Complex"] = new string[] {"HI_A04","HI_A06","HI_A07","HI_A10","HI_A11","HI_A14","HI_A15","HI_A16","HI_A17","HI_A18","HI_A19","HI_A20","HI_A21","HI_A22","HI_A23","HI_A24","HI_A25","HI_A26","HI_A27","HI_A28","HI_B02","HI_B03","HI_B04","HI_B05","HI_B06","HI_B07","HI_B08","HI_B09","HI_B12","HI_B13","HI_B14","HI_B15","HI_C01","HI_C02","HI_C03","HI_C04","HI_C05","HI_C11","HI_C13","HI_C14","HI_C15","HI_D01","HI_S01","HI_S02","HI_S03","HI_S04","HI_S05","HI_S06"};
    all_rooms["Drainage System"] = new string[] {"DS_A01","DS_A02","DS_A05","DS_A06","DS_A07","DS_A08","DS_A09","DS_A10","DS_A11","DS_A13","DS_A14","DS_A15","DS_A16","DS_A17","DS_A19","DS_A20","DS_A21","DS_A22","DS_A23","DS_A24","DS_A25","DS_A26","DS_A27","DS_B01","DS_B02","DS_B03","DS_B04","DS_B06","DS_B07","DS_B08","DS_B10","DS_C01","DS_C02","DS_C03","DS_C04","DS_D01","DS_D02","DS_D03","DS_GUTTER01","DS_GUTTER02","DS_GUTTER03","DS_GUTTER04","DS_GUTTER05","DS_RIVSTART","DS_S01r","DS_S02l","DS_S03","DS_S04"};
    all_rooms["Chimney Canopy"] = new string[] {"CC_A02","CC_A06","CC_A07","CC_A10","CC_A12","CC_A15","CC_A16","CC_A17","CC_B01","CC_B04","CC_B05","CC_B06","CC_B08","CC_B10","CC_B11","CC_B12","CC_B13","CC_B14","CC_C03","CC_C04","CC_C05","CC_C07","CC_C08","CC_C09","CC_C11","CC_C12","CC_C13","CC_CLOG","CC_D01","CC_F01","CC_H01","CC_H01SAINT","CC_OUTPUT","CC_S01","CC_S03","CC_S04","CC_S05","CC_S06","CC_S07","CC_SHAFT01x","CC_SHAFT02","CC_STRAINER01","CC_STRAINER02","CC_STRAINER03","CC_SUMP01","CC_SUMP02","CC_SUMP03","CC_SUMP04","CC_SUMP05"};
    all_rooms["Garbage Wastes"] = new string[] {"GW_A01","GW_A04","GW_A05","GW_A06","GW_A07","GW_A08","GW_A10","GW_A10_PAST","GW_A11","GW_A11_PAST","GW_A12","GW_A13","GW_A13_PAST","GW_A14","GW_A19","GW_A20","GW_A21","GW_A22","GW_A23","GW_A24","GW_A25","GW_B01","GW_B01_PAST","GW_B02","GW_B03","GW_B04","GW_B05","GW_B06","GW_B06_PAST","GW_B07","GW_B08","GW_B09","GW_B09_PAST","GW_C01","GW_C01_PAST","GW_C02","GW_C02_PAST","GW_C03","GW_C04","GW_C04_PAST","GW_C05","GW_C06","GW_C06_PAST","GW_C07","GW_C08","GW_C09","GW_C10","GW_C10_PAST","GW_C11","GW_D01","GW_D01_PAST","GW_D02","GW_E01","GW_E02","GW_E02_PAST","GW_EDGE01","GW_EDGE02","GW_EDGE03","GW_EDGE04","GW_EDGE05","GW_PIPE01","GW_PIPE02","GW_PIPE03","GW_PIPE04","GW_PIPE05","GW_PIPE06","GW_PIPE07","GW_PIPE08","GW_PIPE09","GW_PIPE10","GW_PIPE11","GW_PIPE12","GW_PIPE13","GW_S01","GW_S02","GW_S03","GW_S04","GW_S05","GW_S06","GW_S07","GW_S08","GW_S09","GW_TOWER01","GW_TOWER02","GW_TOWER03","GW_TOWER04","GW_TOWER05","GW_TOWER06","GW_TOWER07","GW_TOWER08","GW_TOWER09","GW_TOWER10","GW_TOWER11","GW_TOWER12","GW_TOWER13","GW_TOWER14","GW_TOWER15"};
    all_rooms["Shaded Citadel"] = new string[] {"SH_A04","SH_A05","SH_A06","SH_A07","SH_A08","SH_A09","SH_A10","SH_A11","SH_A12","SH_A13","SH_A14","SH_A15","SH_A16","SH_A17","SH_A19","SH_A21","SH_A22","SH_A23","SH_A24","SH_A25","SH_A26","SH_B01","SH_B02","SH_B03","SH_B04","SH_B05","SH_B06","SH_B07","SH_B08","SH_B09","SH_B10","SH_B11","SH_B12","SH_B13","SH_B15","SH_B16","SH_B17","SH_C01","SH_C02","SH_C03","SH_C04","SH_C05","SH_C07","SH_C08","SH_C09","SH_C10","SH_C11","SH_C12","SH_C13","SH_CURVE","SH_D01","SH_D02","SH_D03","SH_E01","SH_E01RIV","SH_E02","SH_E03","SH_E03RIV","SH_E04","SH_E04RIV","SH_E05","SH_GOR01","SH_GOR02","SH_H01","SH_H01RIV","SH_HALL","SH_HELPOUT","SH_KELP","SH_LEDGE","SH_OVERHEAD","SH_S01","SH_S02","SH_S03","SH_S04","SH_S05","SH_S06","SH_S07","SH_S08","SH_S09","SH_S10","SH_S11","SH_scavshop"};
    all_rooms["Shoreline"] = new string[] {"SL_A02","SL_A03","SL_A04","SL_A05","SL_A06","SL_A07","SL_A08","SL_A10","SL_A11","SL_A12","SL_A13","SL_A14","SL_A15","SL_A16","SL_A17","SL_ACCSHAFT","SL_AI","SL_B01","SL_B02","SL_B02SAINT","SL_B04","SL_B10","SL_B11","SL_BRIDGE01","SL_BRIDGEEND","SL_C01","SL_C02","SL_C03","SL_C04","SL_C05","SL_C06","SL_C06SAINT","SL_C07","SL_C08","SL_C09","SL_C10","SL_C11","SL_C12","SL_C14","SL_C15","SL_C16","SL_D01","SL_D02","SL_D03","SL_D04","SL_D05","SL_D06","SL_E01","SL_E02","SL_E03","SL_ECNIUS01","SL_ECNIUS02","SL_ECNIUS03","SL_EDGE01","SL_EDGE02","SL_F01","SL_F02","SL_H02","SL_H03","SL_I01","SL_I02","SL_MOONTOP","SL_ROOF01","SL_ROOF03","SL_ROOF04","SL_S02","SL_S03","SL_S04","SL_S05","SL_S06","SL_S07","SL_S08","SL_S09","SL_S10","SL_S11","SL_S13","SL_S15","SL_SCRUSHED","SL_STOP","SL_TEMPLE","SL_TUNNELA","SL_WALL02","SL_WALL05","SL_WALL06"};
    all_rooms["Sky Islands"] = new string[] {"SI_A02","SI_A03x","SI_A06","SI_A07","SI_A08x","SI_A09x","SI_A17","SI_A18","SI_A20","SI_A21","SI_A23","SI_A27","SI_A28","SI_A30","SI_A31","SI_B01","SI_B02","SI_B02x","SI_B03","SI_B04","SI_B07x","SI_B09","SI_B10","SI_B11","SI_B12","SI_B13","SI_B15","SI_B16","SI_C01","SI_C01x","SI_C02","SI_C03","SI_C04","SI_C05","SI_C06","SI_C06x","SI_C07","SI_C08","SI_C09","SI_D01","SI_D03","SI_D05","SI_D06","SI_D07","SI_D08","SI_D09","SI_F01","SI_S03","SI_S04","SI_S05","SI_S06","SI_SAINTINTRO"};
    all_rooms["Farm Arrays"] = new string[] {"LF_A01","LF_A02","LF_A03","LF_A04","LF_A05","LF_A06","LF_A07","LF_A10","LF_A11","LF_A12","LF_A13","LF_A14","LF_A15","LF_A17","LF_B01","LF_B02","LF_B03","LF_B04","LF_B05","LF_C01","LF_C02","LF_C03","LF_C05","LF_D01","LF_D02","LF_D03","LF_D04","LF_D06","LF_D07","LF_D08","LF_D09","LF_E01","LF_E02","LF_E03","LF_E04","LF_E05","LF_F02","LF_H01","LF_H02","LF_J01","LF_M01","LF_M02","LF_M03","LF_M04","LF_M05","LF_S01","LF_S02","LF_S03","LF_S04","LF_S05","LF_S06","LF_S07"};
    all_rooms["The Exterior"] = new string[] {"UW_A01","UW_A02","UW_A03","UW_A04","UW_A04RIV","UW_A05","UW_A05RIV","UW_A06","UW_A06RIV","UW_A07","UW_A08","UW_A09","UW_A10","UW_A11","UW_A11RIV","UW_A12","UW_A13","UW_A14","UW_B01","UW_C01","UW_C01RIV","UW_C02","UW_C02RIV","UW_C03","UW_C04","UW_C05","UW_C06","UW_C07","UW_C08","UW_D01","UW_D02","UW_D03","UW_D04","UW_D05","UW_D05RIV","UW_D06","UW_D07","UW_E01","UW_E02","UW_E03","UW_E04","UW_E04RIV","UW_F01","UW_H01","UW_I01","UW_J01","UW_J02","UW_J02RIV","UW_PREGATE","UW_S01","UW_S02","UW_S03","UW_S04","UW_S05","UW_S06","UW_S07"};
    all_rooms["Five Pebbles"] = new string[] {"SS_A01","SS_A03","SS_A04","SS_A08","SS_A09","SS_A10","SS_A11","SS_A13","SS_A14","SS_A15","SS_A16","SS_A17","SS_A18","SS_A19","SS_AI","SS_B01","SS_B02","SS_B03","SS_B04","SS_B05","SS_B06","SS_C02","SS_C03","SS_C04","SS_C06","SS_C07","SS_C08","SS_D02","SS_D03","SS_D04","SS_D05","SS_D06","SS_D07","SS_D08","SS_E01","SS_E02","SS_E03","SS_E04","SS_E05","SS_E06","SS_E07","SS_E08","SS_F01","SS_F02","SS_F03","SS_H01","SS_I02","SS_I03","SS_L01","SS_LAB1","SS_LAB10","SS_LAB11","SS_LAB12","SS_LAB13","SS_LAB2","SS_LAB3","SS_LAB4","SS_LAB5","SS_LAB6","SS_LAB7","SS_LAB8","SS_LAB9","SS_S01","SS_S02","SS_S03","SS_S04","SS_S05"};
    all_rooms["Subterranean"] = new string[] {"SB_A01","SB_A02","SB_A03","SB_A04","SB_A05","SB_A06","SB_A07","SB_A08","SB_A09","SB_A10","SB_A11","SB_A12","SB_A13","SB_A14","SB_B01","SB_B02","SB_B03","SB_B04","SB_C01","SB_C02","SB_C05","SB_C06","SB_C07","SB_C08","SB_C09","SB_C10","SB_C11","SB_D01","SB_D02","SB_D03","SB_D04","SB_D05","SB_D06","SB_D07","SB_E01","SB_E02","SB_E03","SB_E04","SB_E05","SB_E05SAINT","SB_E06","SB_E07","SB_F01","SB_F02","SB_F03","SB_G02","SB_G03","SB_G04","SB_GOR01","SB_GOR02","SB_GOR02RIV","SB_GOR02SAINT","SB_H02","SB_H03","SB_I01","SB_J01","SB_J02","SB_J03","SB_J04","SB_J10","SB_L01","SB_S01","SB_S02","SB_S03","SB_S04","SB_S05","SB_S06","SB_S07","SB_S09","SB_S10","SB_TESTB","SB_TESTC","SB_TOPSIDE"};
    all_rooms["Pipeyard"] = new string[] {"VS_A01","VS_A02","VS_A03","VS_A04","VS_A05","VS_A06","VS_A07","VS_A08","VS_A09","VS_A10","VS_A11","VS_A12","VS_A13","VS_A14","VS_A15","VS_B01","VS_B02","VS_B03","VS_B04","VS_B05","VS_B06","VS_B07","VS_B08","VS_B09","VS_B10","VS_B11","VS_B12","VS_B13","VS_B14","VS_B15","VS_B16","VS_B17","VS_B18","VS_BASEMENT01","VS_BASEMENT02","VS_C01","VS_C02","VS_C03","VS_C04","VS_C05","VS_C06","VS_C07","VS_C08","VS_C09","VS_C10","VS_C11","VS_C12","VS_C13","VS_D01","VS_D02","VS_D03","VS_D04","VS_D05","VS_E01","VS_E02","VS_E06","VS_E07","VS_F01","VS_F02","VS_H01","VS_H02","VS_S01","VS_S02","VS_S03","VS_S04","VS_S05","VS_S06","VS_S07","VS_S08","VS_S09","VS_S20"};
    all_rooms["Submerged Superstructure"] = new string[] {"MS_AI","MS_AIR01","MS_AIR02","MS_AIR03","MS_ARTERY01","MS_ARTERY02","MS_ARTERY03","MS_ARTERY04","MS_ARTERY05","MS_ARTERY06","MS_ARTERY07","MS_ARTERY08","MS_ARTERY09","MS_ARTERY10","MS_ARTERY11","MS_ARTERY12","MS_C13","MS_CAPI01","MS_CAPI02","MS_CAPI03","MS_CAPI04","MS_COMMS","MS_CORE","MS_CORTEX","MS_CROSSOVER01","MS_CROSSOVER02","MS_EAST01","MS_EAST02","MS_EAST03","MS_EAST04","MS_EAST05","MS_EAST06","MS_EAST07","MS_ENTRANCE","MS_FARSIDE","MS_HEART","MS_I01","MS_I02","MS_I03","MS_I06","MS_I07","MS_I08","MS_I11","MS_I12","MS_I13","MS_Jtrap","MS_LAB1","MS_LAB10","MS_LAB12","MS_LAB13","MS_LAB14","MS_LAB2","MS_LAB3","MS_LAB4","MS_LAB5","MS_LAB6","MS_LAB7","MS_LAB8","MS_LAB9","MS_M03","MS_MEM01","MS_MEM02","MS_MEM03","MS_MEM04","MS_MEM05","MS_MEM06","MS_MEMENTRANCE","MS_MEMOUTSIDE","MS_MEMTUBE","MS_O03","MS_O04","MS_O05","MS_O06","MS_S01","MS_S03","MS_S04","MS_S05","MS_S06","MS_S07","MS_S09","MS_S10","MS_U03","MS_VENT01","MS_VENT02","MS_VENT03","MS_VENT04","MS_VENT05","MS_VENT06","MS_VENT07","MS_VENT08","MS_VENT09","MS_VENT10","MS_VENT11","MS_VENT12","MS_VENT13","MS_VENT14","MS_VENT15","MS_VENT16","MS_VENT17","MS_VENT18","MS_VENT19","MS_VENT20","MS_VENT21","MS_VENT22","MS_VENT23","MS_VISTA","MS_WILLSNAGGING01","MS_X02","MS_aeriestart","MS_bitteraccess","MS_bitteraerie1","MS_bitteraerie2","MS_bitteraerie3","MS_bitteraerie4","MS_bitteraerie5","MS_bitteraerie6","MS_bitteraeriedown","MS_bitteraeriepipeu","MS_bitteredge","MS_bitterentrance","MS_bittermironest","MS_bitterpipe","MS_bittersafe","MS_bittershelter","MS_bitterstart","MS_bitterunderground","MS_bittervents","MS_pumps","MS_scavtrader","MS_sewerbridge","MS_splitsewers","MS_startsewers"};
    all_rooms["Outer Expanse"] = new string[] {"OE_BACKFILTER","OE_BROKENDRAIN","OE_CAVE01","OE_CAVE02","OE_CAVE03","OE_CAVE04","OE_CAVE05","OE_CAVE07","OE_CAVE08","OE_CAVE09","OE_CAVE10","OE_CAVE11","OE_CAVE12","OE_CAVE13","OE_CAVE14","OE_CAVE15","OE_CAVE16","OE_CAVE17","OE_CAVE18","OE_CAVE19","OE_CAVE20","OE_EXITPATH","OE_EXSHELTER","OE_FINAL01","OE_FINAL02","OE_FINAL03","OE_JUNGLE01","OE_JUNGLE02","OE_JUNGLE03","OE_JUNGLE04","OE_JUNGLE05","OE_JUNGLE06","OE_JUNGLEESCAPE","OE_MIDSHELTER","OE_PUMP01","OE_PUMP02","OE_PUMP03","OE_PUMP04","OE_RAIL01","OE_RAIL02","OE_RAIL03","OE_RAIL04","OE_RAIL05","OE_RAIL06","OE_RUIN01","OE_RUIN02","OE_RUIN03","OE_RUIN04","OE_RUIN05","OE_RUIN06","OE_RUIN07","OE_RUIN08","OE_RUIN09","OE_RUIN10","OE_RUIN11","OE_RUIN12","OE_RUIN13","OE_RUIN14","OE_RUIN15","OE_RUIN16","OE_RUIN17","OE_RUIN18","OE_RUIN19","OE_RUIN21","OE_RUIN22","OE_RUIN23","OE_RUIN24","OE_RUIN25","OE_RUINBackHall","OE_RUINCourtYard","OE_RUINFrontHall","OE_S01","OE_S02","OE_S03","OE_S04","OE_S05x","OE_S06","OE_SEXTRA","OE_SFINAL","OE_SPIRE","OE_TEMP","OE_TOWER01","OE_TOWER02","OE_TOWER03","OE_TOWER04","OE_TOWER05","OE_TOWER06","OE_TOWER07","OE_TOWER08","OE_TOWER09","OE_TOWER10","OE_TOWER11","OE_TOWER12","OE_TOWER13","OE_TOWER14","OE_TREETOP","OE_WORMPIT"};
    all_rooms["Waterfront Facility"] = new string[] {"LM_A02","LM_A03","LM_A04","LM_A05","LM_A06","LM_A07","LM_A08","LM_A10","LM_A11","LM_A12","LM_A13","LM_B01","LM_B02","LM_B04","LM_BRIDGE01","LM_BRIDGE02","LM_BRIDGE03","LM_BRIDGE04","LM_BRIDGE04ARTY","LM_BRIDGEEND","LM_C01","LM_C02","LM_C03","LM_C04","LM_C05","LM_C06","LM_C08","LM_C10","LM_C11","LM_C12","LM_D01","LM_D02","LM_D03","LM_D04","LM_D05","LM_D06","LM_E01","LM_E02","LM_ECNIUS01","LM_ECNIUS02","LM_ECNIUS03","LM_EDGE01","LM_EDGE02","LM_EXTRASIDE","LM_F01","LM_F02","LM_H03","LM_LEGENTRANCE","LM_LEGENTRANCEARTY","LM_MIRRORSIDE","LM_S02","LM_S03","LM_S04","LM_S05","LM_S06","LM_S07","LM_S09","LM_S11","LM_S13","LM_S15","LM_SIDESWAMP","LM_TOWER01","LM_TOWER02","LM_TOWER03","LM_TOWER04","LM_TOWER05","LM_TOWER06","LM_TOWER07","LM_TOWER08","LM_TOWER09","LM_TOWER10","LM_TOWER10ARTY","LM_TOWER11","LM_TOWER12","LM_TOWER13","LM_TOWER14","LM_TOWERSIDE","LM_TUNNELA","LM_WALL02","LM_WALL03","LM_WALL05"};
    all_rooms["Metropolis"] = new string[] {"LC_02A","LC_A02","LC_A04","LC_A05","LC_B04","LC_C03","LC_C05","LC_C07","LC_C08","LC_C10","LC_C12","LC_FINAL","LC_LAB01","LC_LAB02","LC_LAB03","LC_LAB04","LC_LAB05","LC_LAB06","LC_PIPES01","LC_PIPES02","LC_PIPES03","LC_PIPES04","LC_PIPES05","LC_S01","LC_S03","LC_S04","LC_S05","LC_S06","LC_SUBWAY01","LC_SUBWAY02","LC_SUBWAY03","LC_SUBWAY04","LC_ShelterTrain1","LC_THECLIMB","LC_betweenwalls","LC_capbase","LC_corner","LC_cramped","LC_crash","LC_deepslumsuh","LC_dome","LC_downwards","LC_eastdome","LC_elevatorcab","LC_elevatorentrance","LC_elevatorlower","LC_elevatorupper","LC_entrancezone","LC_fence","LC_floorpipes","LC_gatehouse01","LC_gatehouse02","LC_gatehouse03","LC_girderwalk","LC_highestpoint","LC_junction","LC_longori","LC_longslum","LC_mallentrance","LC_midlab","LC_rooftophop","LC_ruin01","LC_ruin02","LC_ruin03","LC_scavtreasury","LC_shelter_above","LC_slumtowers","LC_splitpath","LC_sroofs","LC_station01","LC_streets","LC_stripmallNEW","LC_tallSlums","LC_tallbreak","LC_tallestconnection","LC_templeentrance","LC_templegate","LC_templeshaft","LC_templetoll","LC_topdoor","LC_topexit","LC_tophall","LC_toplab","LC_topshaft","LC_towerCLIMB","LC_westdome"};
    all_rooms["The Rot"] = new string[] {"RM_A01","RM_A03","RM_A04","RM_A08","RM_A09","RM_A11","RM_A13","RM_A14","RM_A15","RM_A16","RM_A17","RM_A19","RM_AI","RM_ASSEMBLY","RM_B01","RM_B02","RM_B03","RM_B04","RM_B06","RM_C02","RM_C03","RM_C04","RM_C06","RM_C07","RM_C08","RM_CONSTRUCT","RM_CONVERGENCE","RM_CORE","RM_D02","RM_D03","RM_D04","RM_D07","RM_D08","RM_DEAD01","RM_DEAD02","RM_DEAD03","RM_E01","RM_E02","RM_E03","RM_E04","RM_E05","RM_E06","RM_E08","RM_F01","RM_F02","RM_GSB1","RM_GSB2","RM_H01","RM_I02","RM_I03","RM_LAB11","RM_LAB13","RM_LAB3","RM_LAB5","RM_LAB6","RM_LAB7","RM_LAB8","RM_LC01","RM_LC02","RM_LC03","RM_LC04","RM_LC05","RM_LC06","RM_LCAMBUSH","RM_LCBLOCKAGE","RM_LCCACHE","RM_LCEDGE","RM_LCEXTRA","RM_LCFILTERS","RM_LCFINAL","RM_LCHEADER","RM_LCHUNT","RM_LCLPIPE","RM_LCMANUFOLD","RM_LCMEMEXIT","RM_LCRPIPE","RM_LCS1","RM_LCS2","RM_LCSWAP","RM_LCTANK","RM_LCTPIPE","RM_LCTUBE","RM_LCUPSIDE","RM_LS1","RM_LS2","RM_LSCOREACCESS","RM_LSENTRANCE","RM_LSLOCKDOWN","RM_LSROOT","RM_LSSECRET","RM_LSVALVES","RM_ROT01","RM_ROT02","RM_S01","RM_S02","RM_S03","RM_S04","RM_S05","RM_SDEAD","RM_SFINAL","RM_TERROR"};
    all_rooms["Looks to the Moon"] = new string[] {"DM_A15","DM_A16","DM_ACCSHAFT","DM_AI","DM_C13","DM_CROSSOVER01","DM_CROSSOVER02","DM_ENTRANCE","DM_FAKEGATE_UNDER","DM_I01","DM_I02","DM_I03","DM_I04","DM_I05","DM_I06","DM_I07","DM_I08","DM_I09","DM_I10","DM_I11","DM_I12","DM_I13","DM_LAB1","DM_LAB10","DM_LAB11","DM_LAB12","DM_LAB13","DM_LAB14","DM_LAB2","DM_LAB3","DM_LAB4","DM_LAB5","DM_LAB6","DM_LAB7","DM_LAB8","DM_LAB9","DM_LEG01","DM_LEG02","DM_LEG03","DM_LEG04","DM_LEG05","DM_LEG06","DM_LEG07","DM_LEG08","DM_LEG09","DM_M01","DM_M02","DM_M03","DM_MEM01","DM_MEM02","DM_MEM03","DM_MEM04","DM_MOONCHAMBER","DM_O01","DM_O02","DM_O03","DM_O04","DM_O05","DM_O06","DM_O07","DM_O08","DM_ROOF01","DM_ROOF03","DM_ROOF04","DM_S01","DM_S02","DM_S03","DM_S04","DM_S05","DM_S06","DM_S10","DM_S11","DM_S13","DM_S14","DM_STOP","DM_TEMPLE","DM_U01","DM_U02","DM_U03","DM_U04","DM_U05","DM_U06","DM_U07","DM_U08","DM_U09","DM_U10","DM_U11","DM_UHALL","DM_VISTA","DM_WALL04","DM_WALL06"};
    all_rooms["Silent Construct"] = new string[] {"CL_A04","CL_A05","CL_A06","CL_A07","CL_A08","CL_A10","CL_A11","CL_A12","CL_A13","CL_A14","CL_A15","CL_A16","CL_A17","CL_A24","CL_A25","CL_A30","CL_A31","CL_A32","CL_A33","CL_A34","CL_A35","CL_A36","CL_A37","CL_A38","CL_A39","CL_A40","CL_A41","CL_A42","CL_A43","CL_A44","CL_A45","CL_AI","CL_B01","CL_B02","CL_B03","CL_B04","CL_B05","CL_B06","CL_B11","CL_B15","CL_B16","CL_B17","CL_B20","CL_B21","CL_B22","CL_B23","CL_B24","CL_B25","CL_B26","CL_B27","CL_B28","CL_B29","CL_B30","CL_B31","CL_B32","CL_C01","CL_C02","CL_C03","CL_C04","CL_C05","CL_C07","CL_C08","CL_C09","CL_C11","CL_C12","CL_C13","CL_C14","CL_C20","CL_C21","CL_C22","CL_CORE","CL_CURVE","CL_D01","CL_D02","CL_D03","CL_D04","CL_D05","CL_D06","CL_D08","CL_D10","CL_D11","CL_D12","CL_D13","CL_D14","CL_D15","CL_D16","CL_DEADGATE","CL_E01","CL_E02","CL_E03","CL_E04","CL_H01","CL_H02","CL_HALL","CL_KELP","CL_LC01","CL_LC02","CL_LCFILTERS","CL_LCLPIPE","CL_LCS2","CL_LCSWAP","CL_LEDGE","CL_LSCOREACCESS","CL_LSENTRANCE","CL_LSSECRET","CL_OVERHEAD","CL_S01","CL_S02","CL_S03","CL_S05","CL_S08","CL_S10","CL_S11","CL_S12","CL_S13","CL_S14","CL_S15","CL_S20","CL_S21","CL_V01","CL_V02","CL_V03","CL_X04","CL_scavshop"};
    all_rooms["Undergrowth"] = new string[] {"UG_A02","UG_A05","UG_A06","UG_A07","UG_A08","UG_A09","UG_A11","UG_A16","UG_A19","UG_A20","UG_A21","UG_A22","UG_A24","UG_A25","UG_A26","UG_B02","UG_B03","UG_B04","UG_B06","UG_B07","UG_B08","UG_B10","UG_C01","UG_C02","UG_C03","UG_C04","UG_D01","UG_D02","UG_D03","UG_DARK01","UG_DARK02","UG_DARK03","UG_Filters","UG_GUTTER01","UG_GUTTER02","UG_GUTTER03","UG_GUTTER04","UG_GUTTER05","UG_RIVSTART","UG_S01r","UG_S02l","UG_S03","UG_S04","UG_TOLL"};
    all_rooms["Rubicon"] = new string[] {"HR_A02","HR_A03","HR_A04","HR_A05","HR_A06","HR_A07","HR_A08","HR_A14","HR_A16","HR_A17","HR_A18","HR_A25","HR_A7R","HR_AI","HR_AP01","HR_B01","HR_B02","HR_B03","HR_B05","HR_B14","HR_BI01","HR_BI02","HR_BR1","HR_C01","HR_C02","HR_C09","HR_C14","HR_COL","HR_CT1","HR_E04","HR_FINAL","HR_H01","HR_I01","HR_IN1","HR_J02","HR_L02","HR_L03","HR_L04","HR_L05","HR_L06","HR_L07","HR_L08","HR_LAYERS_OF_REALITY","HR_LCA","HR_M01","HR_M02","HR_M03","HR_M04","HR_M05","HR_M06","HR_R01","HR_R02","HR_R03","HR_R04","HR_R05","HR_R06","HR_R07","HR_R08","HR_R09","HR_R10","HR_R11","HR_R12","HR_R13","HR_R14","HR_R15","HR_R16","HR_R17","HR_R18","HR_S01","HR_S02","HR_S03","HR_S04","HR_S05","HR_S06","HR_S10","HR_S11","HR_S12","HR_S1R","HR_SHR","HR_TER","HR_TP1","HR_US1","HR_gbfi","HR_hrce"};
    
    
    settings.Add("rooms", true, "Splits per room");
    settings.Add("rooms_once_only", true, "Only split the first time entering a room", "rooms");

    foreach(KeyValuePair<string, string[]> region in all_rooms)
    {
        string region_name = region.Key;
        settings.Add(region_name, true, region_name, "rooms");
        string[] rooms = region.Value;
        Array.Sort(rooms);
        foreach (string room in rooms) 
        {
            settings.Add(room, false, room, region_name);
        }
    }
    // refreshRate = 1;
    // Func<Int32[], DeepPointer> rwPtr = offsets => {
    //     Int32[] rwGameOffsets = {0x50, 0xC, 0x308, 0x20, 0xE8, 0x280, 0x100, 0xC, 0xC};
    //     return new DeepPointer("mono-2.0-bdwgc.dll", 0x003A820C, rwGameOffsets.Concat(offsets).ToArray());
    // };

    // vars.room = new StringWatcher(rwPtr(new Int32[] {0x1C, 0x10, 0x8, 0x10, 0xC, 0xC}), 64);

    vars.igt = 0;
    vars.readyToStart = false;
    vars.lastSafeRecordedTime = 0;
    vars.visitedRooms = new List<string>();
    vars.lastSafeRoom = null;
}

update {
    // vars.room.Update(game);
}

init {
}

start {
    //print("mainProcessName: " + current.mainProcessName +  " oldProcessName: " + current.oldProcessName);
    // if(current.mainProcessName != old.mainProcessName) {
    //     if(current.oldProcessName == "SlugcatSelect" && current.mainProcessName == "Game") {
    //         if((settings["start_new"] && current.gameInitConditionName == "New") || (settings["start_load"] && current.gameInitConditionName == "Load"))
    //             return true;
    //     }
    // }

    if(!vars.readyToStart && !current.startButtonPressed) {
        vars.readyToStart = true;
    }
    
    if(vars.readyToStart && current.startButtonPressed) {
        if((settings["start_new"] && current.startButtonLabel == "NEW GAME") || (settings["start_load"] && current.startButtonLabel == "CONTINUE"))
            return true;
    }
}

split {
    // if(vars.room.Current != vars.room.Old) {
    //     print(vars.room.Current);
// for (int i = 0; i < modules.Length; i++)
//         {
//             print(i.ToString());
//             print(modules[i].ModuleName);
//         }
    // }


    if(current.room != old.room && current.room != vars.lastSafeRoom && current.room != null) {
        vars.lastSafeRoom = current.room;
        if(settings.ContainsKey(current.room) && settings[current.room] && (!settings["rooms_once_only"] || !vars.visitedRooms.Contains(current.room))) {
            vars.visitedRooms.Add(current.room);
            return true;
        }
    }
}

isLoading {
    //only use igt, don't interpolate
    return true;
}

onReset {
    vars.igt = 0;
    vars.readyToStart = false;
    vars.lastSafeRecordedTime = 0;
    vars.visitedRooms.Clear();
    vars.lastSafeRoom = null;
}

onStart {
    vars.igt = 0;
}

gameTime {
    //actual igt from HUD, this pointer only works with certain user settings and is rounded to nearest second
    //return new DeepPointer("mono-2.0-bdwgc.dll", 0x003A6CCC, 0x18, 0x30, 0xEA0, 0xC, 0xC, 0x1C, 0x10, 0x104, 0x10, 0x8, 0x30, 0x30).Deref<TimeSpan>(game);

    // print("totTime: " + current.totTime);
    // print("deathTime: " + current.deathTime);
    // print("time: " + current.time);2
    // print("playerGrabbedTime: " + current.playerGrabbedTime);

    // print("totTime: " + current.totTime +  " deathTime: " + current.deathTime + " time: " + current.time + " playerGrabbedTime: " + current.playerGrabbedTime);

    // calculated igt from variables
    // int ms = current.totTime * 1000 + current.deathTime * 1000 + current.time * 25 + current.playerGrabbedTime * 25;
    // int oldMs = old.totTime * 1000 + old.deathTime * 1000 + old.time * 25 + old.playerGrabbedTime * 25;


    //calculate time increasing only
    if(current.storyGameSession != null) {
        // print(current.storyGameSession.ToString());
        bool storyGameSessionExists = false;
        for (int i = 0; i < 4; i++)
        {
            bool b = BitConverter.ToBoolean(current.storyGameSession, i);
            if(b) {
                storyGameSessionExists = true;
                break;
            }
        }
        if(storyGameSessionExists) {
            int currentTime = current.time * 25 + current.playerGrabbedTime * 25;
            int lastRecordedTime = old.time * 25 + old.playerGrabbedTime * 25;
            int deltaTime = 0;
            if(vars.lastSafeRecordedTime == 0 && currentTime == 0 && lastRecordedTime != 0) {
                vars.lastSafeRecordedTime = lastRecordedTime;
            }
            if(vars.lastSafeRecordedTime == 0 && currentTime != 0) {
                deltaTime = currentTime - lastRecordedTime;
            }
            else if(vars.lastSafeRecordedTime != 0 && currentTime != 0) { 
                if(currentTime > vars.lastSafeRecordedTime) {
                    deltaTime = currentTime - vars.lastSafeRecordedTime;
                }
                vars.lastSafeRecordedTime = 0;
            }
            // if(diff > 1000 && oldMs != 0) {
            //     // print("time increased by (ms): " + diff);
            //     // print("current time (ms): " + vars.igt);
            // }
            vars.igt += deltaTime;
        }
    }
    
    return TimeSpan.FromMilliseconds(vars.igt);
}