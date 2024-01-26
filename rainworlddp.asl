
state("RainWorld") {}

startup {
    var type = Assembly.Load(File.ReadAllBytes(@"Components\asl-help")).GetType("Unity");
    vars.Helper = Activator.CreateInstance(type, args: false);
    vars.Helper.Settings.CreateFromXml("Components/rainworlddp.settings.xml", false);

    vars.visitedRooms = new HashSet<string>();
    vars.karmaCacheSkipModEnabled = false;

    vars.igt = 0;
    vars.lastSafeTime = 0;
}

onStart {
    vars.igt = 0;
    vars.visitedRooms.Clear();
    vars.lastSafeTime = 0;
}

init {
    vars.Helper.TryLoad = (Func<dynamic, bool>)(mono => {
        vars.Helper["room"] = mono.MakeString("RWCustom.Custom", "rainWorld", "processManager", "currentMainLoop", 0x1C, 0x10, 0x8, 0x10, 0xC);
        vars.Helper["gateStatus"] = mono.MakeString("RWCustom.Custom", "rainWorld", "processManager", "currentMainLoop", 0x1C, 0x10, 0x8, 0x9c, 0x20, 0x8);
        vars.Helper["time"] = mono.Make<int>("RWCustom.Custom", "rainWorld", "processManager", "currentMainLoop", 0x4C, 0x40, 0x10, 0x28);
        vars.Helper["playerGrabbedTime"] = mono.Make<int>("RWCustom.Custom", "rainWorld", "processManager", "currentMainLoop", 0x4C, 0x40, 0x10, 0x2c);

        vars.Helper["voidSeaMode"] = mono.Make<bool>("RWCustom.Custom", "rainWorld", "processManager", "currentMainLoop", 0x1C, 0x10, 0x184);
        vars.Helper["reinforcedKarma"] = mono.Make<bool>("RWCustom.Custom", "rainWorld", "processManager", "currentMainLoop", 0x4C, 0x20, 0x3C, 0x5C);
        vars.Helper["lockGameTimer"] = mono.Make<bool>("RainWorld", "lockGameTimer");

        vars.Helper["startButtonPressed"] = mono.Make<bool>("RWCustom.Custom", "rainWorld", "processManager", "currentMainLoop", 0x0e0, 0x058);
        vars.Helper["startButtonLabel"] = mono.MakeString("RWCustom.Custom", "rainWorld", "processManager", "currentMainLoop", 0x0e0, 0x038, 0x040);
        vars.Helper["processID"] = mono.MakeString("RWCustom.Custom", "rainWorld", "processManager", "currentMainLoop", "ID", "value");

        vars.Helper["remixEnabled"] = mono.Make<bool>("ModManager", "MMF");

        try {
            var KarmaCacheSkipClass = mono["KarmaCacheSkip", "KarmaCacheSkip.KarmaCacheSkip"];
            vars.Helper["karmaCacheSkipTime"] = mono.Make<int>(KarmaCacheSkipClass, "KARMA_CACHE_IN_GAME_TIME");
            vars.karmaCacheSkipModEnabled = true;
        }
        catch(Exception e) { }
        
        return true;
    });

    vars.igt = 0;
    vars.Helper.Load();
}

update {
    if (!vars.Helper.Loaded) return false; vars.Helper.MapPointers();
}

start {
    // return true when circular hold button pressed on slugcat select screen, unless the label is statistics
    // this is not perfect since other languages will still autostart when statistics screen is opened but it's not a big deal
    return current.processID == "SlugcatSelect" && !old.startButtonPressed && current.startButtonPressed && current.startButtonLabel != "STATISTICS";
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
    int timeToAdd = 0;

    if(current.processID == "Game") {
        int time = current.time * 25 + current.playerGrabbedTime * 25;

        // time recorded at the last livesplit poll
        int prevTime = old.time * 25 + old.playerGrabbedTime  * 25;
        
        // the difference between this time and the last recorded time is added to the timer
        // livesplit polls the game regularly but may lag so finding the difference is pretty secure I think
        int deltaTime = Math.Max(time - prevTime, 0);

        if(deltaTime > 500) {
            if(vars.lastSafeTime == 0) {
                vars.lastSafeTime = prevTime;
            }
            deltaTime = 0;
        }
        else {
            if(vars.lastSafeTime != 0) {
                deltaTime = Math.Max(time - vars.lastSafeTime, 0);
                vars.lastSafeTime = 0;
            }
        }
        
        // fix double speed timer when remix is disabled
        if(!vars.Helper["remixEnabled"].Current && deltaTime > 0) {
            deltaTime = deltaTime / 2;
        }

        timeToAdd += deltaTime;
    }

    // add karma cache skip (mod) time
    if(vars.karmaCacheSkipModEnabled && current.karmaCacheSkipTime != old.karmaCacheSkipTime) {
        timeToAdd += current.karmaCacheSkipTime;
    }

    vars.igt += timeToAdd;
    
    return TimeSpan.FromMilliseconds(vars.igt);
}

exit {
    vars.Helper.Dispose();
}

shutdown {
    vars.Helper.Dispose();
}
