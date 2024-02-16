
state("RainWorld") {}

startup {
    var type = Assembly.Load(File.ReadAllBytes(@"Components\asl-help")).GetType("Unity");
    vars.Helper = Activator.CreateInstance(type, args: false);
    vars.Helper.Settings.CreateFromXml("Components/rainworlddp.settings.xml", false);

    vars.visitedRooms = new HashSet<string>();
    vars.karmaCacheSkipModEnabled = false;

    vars.igt = 0;
    vars.lastSafeTime = 0;
    vars.moonReached = false;
}

onStart {
    vars.igt = 0;
    vars.visitedRooms.Clear();
    vars.lastSafeTime = 0;
    vars.moonReached = false;
}

init {
    vars.Helper.TryLoad = (Func<dynamic, bool>)(mono => {
        vars.Helper["room"] = mono.MakeString("RWCustom.Custom", "rainWorld", 0xC, 0xC, 0x1C, 0x10, 0x8, 0x10, 0xC);
        vars.Helper["gateStatus"] = mono.MakeString("RWCustom.Custom", "rainWorld", 0xC, 0xC, 0x1C, 0x10, 0x8, 0x9c, 0x20, 0x8);
        vars.Helper["time"] = mono.Make<int>("RWCustom.Custom", "rainWorld", 0xC, 0xC, 0x4C, 0x40, 0x10, 0x28);
        vars.Helper["playerGrabbedTime"] = mono.Make<int>("RWCustom.Custom", "rainWorld", 0xC, 0xC, 0x4C, 0x40, 0x10, 0x2c);
        vars.Helper["playerX"] = mono.Make<float>("RWCustom.Custom", "rainWorld", 0xC, 0xC, 0x1C, 0x10, 0x104, 0x8, 0x10, 0x10, 0x18);
        vars.Helper["theMark"] = mono.Make<bool>("RWCustom.Custom", "rainWorld", 0xC, 0xC, 0x4C, 0x20, 0x3C, 0x5D);
        vars.Helper["pebblesHasIncreasedRedsKarmaCap"] = mono.Make<bool>("RWCustom.Custom", "rainWorld", 0xC, 0xC, 0x4C, 0x20, 0x3C, 0x60);
        vars.Helper["scarVisible"] = mono.Make<bool>("RWCustom.Custom", "rainWorld", 0xC, 0xC, 0x1C, 0x10, 0x104, 0x8, 0x18, 0x54, 0x58);
        vars.Helper["moonRevived"] = mono.Make<bool>("RWCustom.Custom", "rainWorld", 0xC, 0xC, 0x4C, 0x20, 0x38, 0x20);
        vars.Helper["moonEquipsRobe"] = mono.Make<bool>("RWCustom.Custom", "rainWorld", 0xC, 0xC, 0x4C, 0x20, 0x38, 0x31);
        vars.Helper["echoID"] = mono.MakeString("RWCustom.Custom", "rainWorld", 0xC, 0xC, 0x60, 0x8);

        vars.Helper["voidSeaMode"] = mono.Make<bool>("RWCustom.Custom", "rainWorld", 0xC, 0xC, 0x1C, 0x10, 0x184);
        vars.Helper["reinforcedKarma"] = mono.Make<bool>("RWCustom.Custom", "rainWorld", 0xC, 0xC, 0x4C, 0x20, 0x3C, 0x5C);
        vars.Helper["lockGameTimer"] = mono.Make<bool>("RainWorld", "lockGameTimer");

        vars.Helper["processID"] = mono.MakeString("RWCustom.Custom", "rainWorld", 0xC, 0xC, 0xC, 0x8);
        vars.Helper["startButtonPressed"] = mono.Make<bool>("RWCustom.Custom", "rainWorld", 0xC, 0xC, 0x0e0, 0x058);
        vars.Helper["currentlySelectedSlugcat"] = mono.MakeString("RWCustom.Custom", "rainWorld", 0x14, 0x18, 0x28, 0x8);
        vars.Helper["redIsDead"] = mono.Make<bool>("RWCustom.Custom", "rainWorld", 0xC, 0xC, 0x13D);
        vars.Helper["artificerIsDead"] = mono.Make<bool>("RWCustom.Custom", "rainWorld", 0xC, 0xC, 0x150);
        vars.Helper["saintIsDead"] = mono.Make<bool>("RWCustom.Custom", "rainWorld", 0xC, 0xC, 0x151);
        vars.Helper["expeditionStartButtonPressed"] = mono.Make<bool>("RWCustom.Custom", "rainWorld", 0xC, 0xC, 0xFC, 0xC8, 0xC4);
        vars.Helper["gameInitCondition"] = mono.MakeString("RWCustom.Custom", "rainWorld", 0xC, 0x58, 0x8, 0x8);

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
    // trigger start the circle button fills up on the campaign slug select menu
    if(current.processID == "SlugcatSelect") {
        if(current.currentlySelectedSlugcat == "Red" && current.redIsDead)
            return false;
        if(current.currentlySelectedSlugcat == "Artificer" && current.artificerIsDead)
            return false;
        if(current.currentlySelectedSlugcat == "Saint" && current.saintIsDead)
            return false;
        if(current.startButtonPressed && !old.startButtonPressed) {
            if(current.gameInitCondition == "New" && settings["start_new_campaign"])
                return true;
            if(current.gameInitCondition == "Load" && settings["start_load_campaign"])
                return true;
        }
    }
    // trigger start when the expedition start button fills up
    if(current.processID == "ExpeditionMenu" && settings["start_new_expedition"]) {
        return current.expeditionStartButtonPressed && !old.expeditionStartButtonPressed;
    }
    // trigger start on expedition retry
    if(current.processID == "ExpeditionGameOver" && settings["start_retry_expedition"]) {
        return current.gameInitCondition != old.gameInitCondition && current.gameInitCondition == "New";
    }
}

split {
    //passages
    //endgamemeter tracker id

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
    // visit moon split (moon%)
    if(!vars.moonReached && current.room == "SL_AI" && current.playerX >= 1160f) {
        vars.moonReached = true;
        if(settings["obj_visit_moon"])
            return true;
    }
    // revive moon (hunter)
    if(current.room == "SL_AI") {
        if(current.moonRevived && !old.moonRevived && settings["obj_revive_moon"])
            return true;
    }
    // clothe moon
    if(current.room == "SL_AI") {
        if(current.moonEquipsRobe && !old.moonEquipsRobe && settings["obj_cloak_moon"])
            return true;
    }
    // pebbles ping
    if(current.room == "SS_AI" && settings["obj_pebbles_ping"]) {
        if(current.theMark && !old.theMark)
            return true;
        if(current.pebblesHasIncreasedRedsKarmaCap && !old.pebblesHasIncreasedRedsKarmaCap)
            return true;
        if(current.scarVisible && !old.scarVisible)
            return true;
    }
    //echoes
    if(current.echoID != null && current.echoID != old.echoID && current.echoID != "NoGhost") {
        if(current.echoID == "CL" && settings["echo_visit_UW"])
            return true;
        if(settings.ContainsKey("echo_visit_" + current.echoID) && settings["echo_visit_" + current.echoID])
            return true;
    }
    if(current.processID == "ExpeditionWinScreen" && current.processID != old.processID) {
        if(settings["obj_ending_expedition"])
            return true;
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
