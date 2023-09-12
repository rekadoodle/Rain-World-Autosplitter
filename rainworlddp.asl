
state("RainWorld") {}

startup {
    Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Unity");
    vars.Helper.Settings.CreateFromXml("Components/rainworlddp.settings.xml", false);

    vars.visitedRooms = new HashSet<string>();
}

onStart {
    vars.igt = 0;
    vars.visitedRooms.Clear();
}

init {
    vars.Helper.TryLoad = (Func<dynamic, bool>)(mono => {
        vars.Helper["room"] = mono.MakeString("RWCustom.Custom", "rainWorld", "processManager", "currentMainLoop", 0x1C, 0x10, 0x8, 0x10, 0xC);
        vars.Helper["gateStatus"] = mono.MakeString("RWCustom.Custom", "rainWorld", "processManager", "currentMainLoop", 0x1C, 0x10, 0x8, 0x9c, 0x20, 0x8);
        vars.Helper["time"] = mono.Make<int>("RWCustom.Custom", "rainWorld", "processManager", "currentMainLoop", 0x4C, 0x40, 0x10, 0x28);
        vars.Helper["playerGrabbedTime"] = mono.Make<int>("RWCustom.Custom", "rainWorld", "processManager", 0xC, 0x4C, 0x40, 0x10, 0x2c);

        vars.Helper["voidSeaMode"] = mono.Make<bool>("RWCustom.Custom", "rainWorld", "processManager", "currentMainLoop", 0x1C, 0x10, 0x184);
        vars.Helper["reinforcedKarma"] = mono.Make<bool>("RWCustom.Custom", "rainWorld", "processManager", "currentMainLoop", 0x4C, 0x20, 0x3C, 0x5C);
        vars.Helper["lockGameTimer"] = mono.Make<bool>("RainWorld", "lockGameTimer");

        vars.Helper["startButtonPressed"] = mono.Make<bool>("RWCustom.Custom", "rainWorld", "processManager", "currentMainLoop", 0x0e0, 0x058);
        vars.Helper["startButtonLabel"] = mono.MakeString("RWCustom.Custom", "rainWorld", "processManager", "currentMainLoop", 0x0e0, 0x038, 0x040);
        vars.Helper["processID"] = mono.MakeString("RWCustom.Custom", "rainWorld", "processManager", "currentMainLoop", "ID", "value");

        vars.Helper["remixEnabled"] = mono.Make<bool>("ModManager", "MMF");
        return true;
    });

    vars.igt = 0;
}

start {
    // return true when circular hold button pressed on slugcat select screen, unless the label is statistics
    // this is not perfect since other languages will still autostart when statistics screen is opened but it's not a big deal
    return !old.startButtonPressed && current.startButtonPressed && current.processID == "SlugcatSelect" && current.startButtonLabel != "STATISTICS";
}

split {
    // room splits
    if(current.room != null && current.room != old.room) {
        if(settings.ContainsKey(current.room) && settings[current.room]) {
            if(!settings["rooms_once_only"] || vars.visitedRooms.Add(current.room))
                return true;
        }
    }
    // gate splits
    if(current.room != null && current.gateStatus != old.gateStatus) {
        if(settings["GATE_ANY_OPEN"] || (settings.ContainsKey(current.room + "_OPEN") && settings[current.room + "_OPEN"])) {
            if(current.gateStatus == "MiddleOpen")
                return true;
        }
    }
    // void swim split
    if(current.voidSeaMode != old.voidSeaMode && current.voidSeaMode == true && settings["obj_ending_voidswim"]) {
        return true;
    }
    // other ending splits
    if(current.room != null) {
        if(current.lockGameTimer != old.lockGameTimer && current.lockGameTimer == true) {
            if(current.room == "OE_FINAL03" && settings["obj_ending_slugtree"])
                return true;
            if(current.room == "SI_A07" && settings["obj_ending_broadcast"])
                return true;
            if(current.room == "SL_MOONTOP" && settings["obj_ending_moonrise"])
                return true;
        }
        if(current.reinforcedKarma != old.reinforcedKarma && current.reinforcedKarma == false) {
            if(current.room == "LC_FINAL" && settings["obj_ending_regicide"])
                return true;
        }
    }
}

isLoading {
    // only use igt, don't interpolate
    return true;
}

gameTime {  
    int time = current.time * 25 + current.playerGrabbedTime * 25;

    // time recorded at the last livesplit poll
    int prevTime = old.time * 25 + old.playerGrabbedTime  * 25;

    // the difference between this time and the last recorded time is added to the timer
    // livesplit polls the game regularly but may lag so finding the difference is pretty secure I think
    int deltaTime = Math.Max(time - prevTime, 0);
        
    // fix double speed timer when remix is disabled
    if(!vars.Helper["remixEnabled"].Current) {
        deltaTime = deltaTime / 2;
    }
    vars.igt += deltaTime;
    
    return TimeSpan.FromMilliseconds(vars.igt);
}
