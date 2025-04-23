// Rain World v1.10.2 Autosplitter by rek
// https://github.com/rekadoodle/Rain-World-Autosplitter

state("RainWorld") {}

startup {
    vars.VERSION = "v0.04.05";
    refreshRate = 40; // match game tickrate

    var helperType = Assembly.Load(File.ReadAllBytes(@"Components\asl-help")).GetType("Unity");
    vars.Helper = Activator.CreateInstance(helperType, args: false);
    vars.Helper.Settings.CreateFromXml("Components/rainworlddp.settings.xml", false);

    vars.visitedRooms = new HashSet<string>();
    vars.collectedPearls = new HashSet<string>();
    vars.karmaCacheSkipModEnabled = false;

    vars.igt = 0;
    vars.TWO_MINUTES = TimeSpan.FromMinutes(2);
    vars.oldTime = DateTime.Now;
    vars.igt_native = new TimeSpan();
    vars.igt_native_max = new TimeSpan();
    vars.igt_interpolated = new TimeSpan();

    vars.lastSafeTime = 0;
    vars.moonReached = false;
    vars.sessionType = null;
    vars.echoTimeout = 0;

    vars.alertShown = false;
    vars.Helper.GameName = "Rain World";
}

onStart {
    vars.igt = 0;
    vars.igt_native = new TimeSpan();
    vars.igt_native_max = new TimeSpan();
    vars.igt_interpolated = new TimeSpan();
    vars.oldTime = DateTime.Now;
    vars.visitedRooms.Clear();
    vars.collectedPearls.Clear();
    vars.lastSafeTime = 0;
    vars.moonReached = false;
    vars.gourmandFoodQuest = new int[22];
}

init {
    vars.Helper.TryLoad = (Func<dynamic, bool>)(mono => {
        vars.Helper["room"] = mono.MakeString("RWCustom.Custom", "rainWorld", 0x18, 0x18, 0x30, 0x20, 0x10, 0x20, 0x18);
        vars.Helper["gateStatus"] = mono.MakeString("RWCustom.Custom", "rainWorld", 0x18, 0x18, 0x30, 0x20, 0x10, 0x160, 0x40, 0x10);
        vars.Helper["time"] = mono.Make<int>("RWCustom.Custom", "rainWorld", 0x18, 0x18, 0x90, 0x68, 0x20, 0x48);
        vars.Helper["playerGrabbedTime"] = mono.Make<int>("RWCustom.Custom", "rainWorld", 0x18, 0x18, 0x90, 0x68, 0x20, 0x4C);
        vars.Helper["playerX"] = mono.Make<float>("RWCustom.Custom", "rainWorld", 0x18, 0x18, 0x30, 0x20, 0x1A0, 0x10, 0x20, 0x20, 0x30);
        vars.Helper["playerCharacter"] = mono.MakeString("RWCustom.Custom", "rainWorld", 0x18, 0x18, 0x30, 0x20, 0x1A0, 0x10, 0x358, 0x10);
        vars.Helper["theMark"] = mono.Make<bool>("RWCustom.Custom", "rainWorld", 0x18, 0x18, 0x90, 0x38, 0xC0, 0xB9);
        vars.Helper["pebblesHasIncreasedRedsKarmaCap"] = mono.Make<bool>("RWCustom.Custom", "rainWorld", 0x18, 0x18, 0x90, 0x38, 0xC0, 0xBC);
        vars.Helper["scarVisible"] = mono.Make<bool>("RWCustom.Custom", "rainWorld", 0x18, 0x18, 0x30, 0x20, 0x1A0, 0x10, 0x30, 0xC0, 0x64);
        vars.Helper["moonRevived"] = mono.Make<bool>("RWCustom.Custom", "rainWorld", 0x18, 0x18, 0x90, 0x38, 0xB8, 0x78);
        vars.Helper["moonEquipsRobe"] = mono.Make<bool>("RWCustom.Custom", "rainWorld", 0x18, 0x18, 0x90, 0x38, 0xB8, 0x89);
        vars.Helper["echoID"] = mono.MakeString("RWCustom.Custom", "rainWorld", 0x18, 0x18, 0xC0, 0x10);
        
        vars.Helper["rivOrbCollected"] = mono.Make<bool>("RWCustom.Custom", "rainWorld", 0x18, 0x18, 0x90, 0x38, 0xB8, 0x80);
        vars.Helper["rivOrbPlaced"] = mono.Make<bool>("RWCustom.Custom", "rainWorld", 0x18, 0x18, 0x90, 0x38, 0xB8, 0x88);
        vars.Helper["moonPingSpearmaster"] = mono.Make<bool>("RWCustom.Custom", "rainWorld", 0x18, 0x18, 0x90, 0x38, 0xB8, 0x8A);
        vars.Helper["saintPingPebbles"] = mono.Make<bool>("RWCustom.Custom", "rainWorld", 0x18, 0x18, 0x90, 0x38, 0xC0, 0xDA);
        vars.Helper["saintPingMoon"] = mono.Make<bool>("RWCustom.Custom", "rainWorld", 0x18, 0x18, 0x90, 0x38, 0xC0, 0xDB);

        vars.Helper["voidSeaMode"] = mono.Make<bool>("RWCustom.Custom", "rainWorld", 0x18, 0x18, 0x30, 0x20, 0x28C);
        vars.Helper["reinforcedKarma"] = mono.Make<bool>("RWCustom.Custom", "rainWorld", 0x18, 0x18, 0x90, 0x38, 0xC0, 0xB8);
        vars.Helper["lockGameTimer"] = mono.Make<bool>("RainWorld", "lockGameTimer");
        vars.Helper["CurrentFreeTimeSpan"] = mono.Make<TimeSpan>("RainWorld", "CurrentFreeTimeSpan");

        vars.Helper["processID"] = mono.MakeString("RWCustom.Custom", "rainWorld", 0x18, 0x18, 0x18, 0x10);
        vars.Helper["upcomingProcessID"] = mono.MakeString("RWCustom.Custom", "rainWorld", 0x18, 0x60, 0x10);
        vars.Helper["startButtonPressed"] = mono.Make<bool>("RWCustom.Custom", "rainWorld", 0x18, 0x18, 0x138, 0x8C);
        vars.Helper["currentlySelectedSlugcat"] = mono.MakeString("RWCustom.Custom", "rainWorld", 0x28, 0x30, 0x50, 0x10);
        vars.Helper["redIsDead"] = mono.Make<bool>("RWCustom.Custom", "rainWorld", 0x18, 0x18, 0x1E1);
        vars.Helper["artificerIsDead"] = mono.Make<bool>("RWCustom.Custom", "rainWorld", 0x18, 0x18, 0x1F8);
        vars.Helper["saintIsDead"] = mono.Make<bool>("RWCustom.Custom", "rainWorld", 0x18, 0x18, 0x1F9);
        vars.Helper["expeditionStartButtonPressed"] = mono.Make<bool>("RWCustom.Custom", "rainWorld", 0x18, 0x18, 0x170, 0x180, 0x144);
        vars.Helper["gameInitCondition"] = mono.MakeString("RWCustom.Custom", "rainWorld", 0x18, 0xB0, 0x10, 0x10);
        vars.Helper["currentlySelectedGameType"] = mono.MakeString("RWCustom.Custom", "rainWorld", 0x18, 0xC0, 0x18, 0x10);
        vars.Helper["selectedChallenge"] = mono.Make<int>("RWCustom.Custom", "rainWorld", 0x18, 0x18, 0x1e0, 0x50, 0xA8);
        vars.Helper["challengeCompleted"] = mono.Make<bool>("RWCustom.Custom", "rainWorld", 0x18, 0x18, 0x90, 0x91);
        vars.Helper["session"] = mono.Make<IntPtr>("RWCustom.Custom", "rainWorld", 0x18, 0x18, 0x90);
        vars.Helper["arenaAliveTime"] = mono.Make<int>("RWCustom.Custom", "rainWorld", 0x18, 0x18, 0x90, 0x38, 0x18, 0x10, 0x20, 0x44);

        vars.Helper["waitingAchievement"] = mono.Make<int>("RWCustom.Custom", "rainWorld", 0x18, 0x14C);
        vars.Helper["waitingAchievementGOG"] = mono.Make<int>("RWCustom.Custom", "rainWorld", 0x18, 0x154);
        vars.Helper["sandboxUnlocksCount"] = mono.Make<int>("RWCustom.Custom", "rainWorld", 0x28, 0x30, 0x30, 0x18);
        vars.Helper["sandboxUnlocksItems"] = mono.Make<IntPtr>("RWCustom.Custom", "rainWorld", 0x28, 0x30, 0x30, 0x10);
        vars.Helper["levelUnlocksCount"] = mono.Make<int>("RWCustom.Custom", "rainWorld", 0x28, 0x30, 0x28, 0x18);
        vars.Helper["levelUnlocksItems"] = mono.Make<IntPtr>("RWCustom.Custom", "rainWorld", 0x28, 0x30, 0x28, 0x10);

        vars.Helper["slugcatUnlocksCount"] = mono.Make<int>("RWCustom.Custom", "rainWorld", 0x28, 0x30, 0xC8, 0x18);
        vars.Helper["slugcatUnlocksItems"] = mono.Make<IntPtr>("RWCustom.Custom", "rainWorld", 0x28, 0x30, 0xC8, 0x10);
        vars.Helper["safariUnlocksCount"] = mono.Make<int>("RWCustom.Custom", "rainWorld", 0x28, 0x30, 0xD0, 0x18);
        vars.Helper["safariUnlocksItems"] = mono.Make<IntPtr>("RWCustom.Custom", "rainWorld", 0x28, 0x30, 0xD0, 0x10);
        vars.Helper["broadcastsCount"] = mono.Make<int>("RWCustom.Custom", "rainWorld", 0x28, 0x30, 0xF8, 0x18);
        vars.Helper["broadcastsItems"] = mono.Make<IntPtr>("RWCustom.Custom", "rainWorld", 0x28, 0x30, 0xF8, 0x10);
        vars.Helper["chatlogID"] = mono.MakeString("RWCustom.Custom", "rainWorld", 0x18, 0x18, 0x30, 0x20, 0x1A0, 0x10, 0x350, 0x10);
        vars.Helper["chatlog"] = mono.Make<bool>("RWCustom.Custom", "rainWorld", 0x18, 0x18, 0x30, 0x20, 0x1A0, 0x10, 0x62E);
        vars.Helper["gourmandMeterCount"] = mono.Make<int>("RWCustom.Custom", "rainWorld", 0x18, 0x18, 0x30, 0x20, 0x1A0, 0x88, 0x28, 0x18);
        vars.Helper["gourmandMeterItems"] = mono.Make<IntPtr>("RWCustom.Custom", "rainWorld", 0x18, 0x18, 0x30, 0x20, 0x1A0, 0x88, 0x28, 0x10);
        vars.Helper["hand1pearlType"] = mono.MakeString("RWCustom.Custom", "rainWorld", 0x18, 0x18, 0x30, 0x20, 0x1A0, 0x10, 0xA8, 0x20, 0x18, 0x40, 0xA0, 0x10);
        vars.Helper["hand2pearlType"] = mono.MakeString("RWCustom.Custom", "rainWorld", 0x18, 0x18, 0x30, 0x20, 0x1A0, 0x10, 0xA8, 0x28, 0x18, 0x40, 0xA0, 0x10);

        vars.Helper["remixEnabled"] = mono.Make<bool>("ModManager", "MMF");
        vars.Helper["expeditionComplete"] = mono.Make<bool>("Expedition.ExpeditionGame", "expeditionComplete");

        vars.Helper["pauseMenu"] = mono.Make<int>("RWCustom.Custom", "rainWorld", 0x18, 0x18, 0x60);
        vars.Helper["paused"] = mono.Make<bool>("RWCustom.Custom", "rainWorld", 0x18, 0x18, 0x114);
        vars.Helper["mscEnabled"] = mono.Make<bool>("ModManager", "MSC");
        vars.Helper["artificerDreamNumber"] = mono.Make<int>("RWCustom.Custom", "rainWorld", 0x18, 0x144);
        vars.Helper["gameOverMode"] = mono.Make<bool>("RWCustom.Custom", "rainWorld", 0x18, 0x18, 0x30, 0x20, 0x1A0, 0x40, 0xA8);

        try {
            var KarmaCacheSkipClass = mono["KarmaCacheSkip", "KarmaCacheSkip.KarmaCacheSkip"];
            vars.Helper["karmaCacheSkipTime"] = mono.Make<int>(KarmaCacheSkipClass, "KARMA_CACHE_IN_GAME_TIME");
            vars.karmaCacheSkipModEnabled = true;
        }
        catch(Exception e) { }
        
        return true;
    });

    vars.igt = 0;
    vars.igt_native = new TimeSpan();
    vars.igt_native_max = new TimeSpan();
    vars.Helper.Load();
    vars.log = (Action<string, string>)((type, message) => { 
        if((!settings.ContainsKey("debug_log_" + type) && settings["debug_log"]) || settings["debug_log_" + type]) {
            string cleanType;
            switch(type) 
            {
                case "menu":
                    cleanType = "MENU CHANGE: ";
                    break;
                case "room":
                    cleanType = "ROOM CHANGE: ";
                    break;
                default:
                    cleanType = type.ToUpper() + " - ";
                    break;
            }
            print("Rain World ASL " + vars.VERSION + ": " + cleanType + message);
        }
    });
}

update {
    if (!vars.Helper.Loaded) return false; vars.Helper.MapPointers();
    
    if(!vars.alertShown && !settings["disable_gametime_reminder"]) {
        vars.Helper.AlertGameTime();
    }
    vars.alertShown = true;
    if(!((IDictionary<string, object>)old).ContainsKey("processID")) {
        return;
    }
    if(current.processID != null && current.processID != old.processID) {
        if(current.processID == "SlugcatSelect") {
            vars.sessionType = "StoryGameSession";
        }
        else if(current.processID == "MultiplayerMenu") {
            vars.sessionType = "SandboxGameSession";
        }
        else {
            vars.sessionType = vars.Helper.ReadString(32, ReadStringType.UTF8, current.session, 0x0, 0x48, 0x0); //todo investigate and document
        }
    }
    if(vars.echoTimeout > 0) {
        vars.echoTimeout--;
    }
    
    // log menu change
    if(current.processID != null && current.processID != old.processID) {
        vars.log("menu", (old.processID ?? "NULL") + " => " + current.processID);
    }
    // log room change
    if(current.room != null && current.room != old.room) {
        vars.log("room", (old.room ?? "NULL") + " => " + current.room);
    }
}

start {
    // trigger start the circle button fills up on the campaign slug select menu
    if(current.processID == "SlugcatSelect") {
        if(current.currentlySelectedSlugcat == "Red" && current.redIsDead) {
            return false;
        }
        if(current.currentlySelectedSlugcat == "Artificer" && current.artificerIsDead) {
            return false;
        }
        if(current.currentlySelectedSlugcat == "Saint" && current.saintIsDead) {
            return false;
        }
        if(current.startButtonPressed && !old.startButtonPressed) {
            if(current.gameInitCondition == "New" && settings["start_new_campaign"]) {
                vars.log("start", "Start new campaign");
                return true;
            }
            if(current.gameInitCondition == "Load" && settings["start_load_campaign"]) {
                vars.log("start", "Load campaign");
                return true;
            }
        }
    }
    // trigger start when the expedition start button fills up
    if(current.processID == "ExpeditionMenu" && settings["start_new_expedition"]) {
        if(current.expeditionStartButtonPressed && !old.expeditionStartButtonPressed) {
            vars.log("start", "Start new expedition");
            return true;
        }
    }
    // trigger start on expedition retry
    if(current.processID == "ExpeditionGameOver" && settings["start_retry_expedition"]) {
        if(current.gameInitCondition != old.gameInitCondition && current.gameInitCondition == "New") {
            vars.log("start", "Reset expedition");
            return true;
        }
    }
    // room split triggers start
    if(settings["start_room_split"] && current.room != null && current.room != old.room) {
        if(settings.ContainsKey(current.room) && settings[current.room]) {
            vars.log("start", "Room change: " + (old.room ?? "NULL") + " => " + current.room);
            return true;
        }
    }
    // challenge start
    if(current.processID == "MultiplayerMenu" && current.currentlySelectedGameType == "Challenge" && current.upcomingProcessID != old.upcomingProcessID && current.upcomingProcessID == "Game") {
        if(settings["start_challenge_start_" + current.selectedChallenge.ToString()]) {
            vars.log("start", "Challenge Started:  " + current.selectedChallenge.ToString());
            return true;
        }
    }
}

reset {
    // trigger start the circle button fills up on the campaign slug select menu
    if(current.processID == "SlugcatSelect") {
        if(current.currentlySelectedSlugcat == "Red" && current.redIsDead) {
            return false;
        }
        if(current.currentlySelectedSlugcat == "Artificer" && current.artificerIsDead) {
            return false;
        }
        if(current.currentlySelectedSlugcat == "Saint" && current.saintIsDead) {
            return false;
        }
        if(current.startButtonPressed && !old.startButtonPressed) {
            if(current.gameInitCondition == "New" && settings["reset_new_campaign"]) {
                vars.log("reset", "Reset new campaign");
                return true;
            }
            if(current.gameInitCondition == "Load" && settings["reset_load_campaign"]) {
                vars.log("reset", "Reset load campaign");
                return true;
            }
        }
    }
    // trigger start when the expedition start button fills up
    if(current.processID == "ExpeditionMenu" && settings["reset_new_expedition"]) {
        if(current.expeditionStartButtonPressed && !old.expeditionStartButtonPressed) {
            vars.log("reset", "Reset expedition");
            return true;
        }
    }
    // trigger start on expedition retry
    if(current.processID == "ExpeditionGameOver" && settings["reset_retry_expedition"]) {
        if(current.gameInitCondition != old.gameInitCondition && current.gameInitCondition == "New") {
            vars.log("reset", "Reset expedition");
            return true;
        }
    }
    // trigger start on challenge start
    if(current.processID == "MultiplayerMenu" && current.currentlySelectedGameType == "Challenge" && current.upcomingProcessID != old.upcomingProcessID && current.upcomingProcessID == "Game") {
        if(settings["reset_challenge_start_" + current.selectedChallenge.ToString()]) {
            vars.log("reset", "Challenge Started:  " + current.selectedChallenge.ToString());
            return true;
        }
    }
}

split {
    // room splits
    if(current.room != null && current.room != old.room) {
        if(settings.ContainsKey(current.room) && settings[current.room]) {
            if(!settings["rooms_once_only"] || vars.visitedRooms.Add(current.room)) {
                vars.log("split", "Room change: " + (old.room ?? "NULL") + " => " + current.room);
                return true;
            }
        }
    }
    // gate splits
    if(current.room != null && current.gateStatus != old.gateStatus) {
        if(settings["GATE_ANY_OPEN"] || (settings.ContainsKey(current.room + "_OPEN") && settings[current.room + "_OPEN"])) {
            if(settings.ContainsKey("gate_mode_" + current.gateStatus) && settings["gate_mode_" + current.gateStatus]) {
                vars.log("split", "Gate " + current.room + ": Animation status " + current.gateStatus);
                return true;
            }
        }
    }
    // void swim split
    if(current.voidSeaMode != old.voidSeaMode && current.voidSeaMode == true && settings["obj_ending_voidswim"]) {
        vars.log("split", "Entered Void Sea");
        return true;
    }
    // other ending splits
    if(current.room != null) {
        if(current.lockGameTimer != old.lockGameTimer && current.lockGameTimer == true) {
            if(current.room == "OE_FINAL03" && settings["obj_ending_slugtree"]) {
                vars.log("split", "Gourmand Ending");
                return true;
            }
            if(current.room == "SI_A07" && settings["obj_ending_broadcast"]) {
                vars.log("split", "Spearmaster Ending");
                return true;
            }
            if(current.room == "SL_MOONTOP" && settings["obj_ending_moonrise"]) {
                vars.log("split", "Rivulet Ending");
                return true;
            }
        }
        if(current.reinforcedKarma != old.reinforcedKarma && current.reinforcedKarma == false) {
            if(current.room == "LC_FINAL" && settings["obj_ending_regicide"]) {
                vars.log("split", "Artificer Ending");
                return true;
            }
        }
    }
    // visit moon split (moon%)
    if(!vars.moonReached && current.room == "SL_AI" && current.playerX >= 1160f) {
        vars.moonReached = true;
        if(settings["obj_visit_moon"]) {
            vars.log("split", "Visit Moon (moon%)");
            return true;
        }
    }
    // revive moon (hunter)
    if(current.room == "SL_AI") {
        if(current.moonRevived && !old.moonRevived && settings["obj_revive_moon"]) {
            vars.log("split", "Revived Moon");
            return true;
        }
    }
    // clothe moon
    if(current.room == "SL_AI") {
        if(current.moonEquipsRobe && !old.moonEquipsRobe && settings["obj_cloak_moon"]) {
            vars.log("split", "Give Moon cloak");
            return true;
        }
    }
    // pebbles ping
    if(current.room == "SS_AI" && settings["obj_pebbles_ping"]) {
        if(current.theMark && !old.theMark) {
            vars.log("split", "Pebbles ping");
            return true;
        }
        if(current.pebblesHasIncreasedRedsKarmaCap && !old.pebblesHasIncreasedRedsKarmaCap) {
            vars.log("split", "Pebbles ping");
            return true;
        }
        if(current.scarVisible && !old.scarVisible) {
            vars.log("split", "Pebbles ping");
            return true;
        }
    }
    // msc objectives
    if(current.room == "RM_CORE" && settings["obj_riv_pickup_orb"]) {
        if(current.rivOrbCollected && !old.rivOrbCollected) {
            vars.log("split", "Rivulet takes orb");
            return true;
        }
    }
    if(current.room == "MS_CORE" && settings["obj_riv_place_orb"]) {
        if(current.rivOrbPlaced && !old.rivOrbPlaced) {
            vars.log("split", "Rivulet places orb");
            return true;
        }
    }
    if(current.room == "DM_AI" && settings["obj_moon_ping"]) {
        if(current.moonPingSpearmaster && !old.moonPingSpearmaster) {
            vars.log("split", "Moon pings Spearmaster");
            return true;
        }
    }
    if(current.room == "CL_AI" && settings["obj_saint_ping_pebbles"]) {
        if(current.saintPingPebbles && !old.saintPingPebbles) {
            vars.log("split", "Saint pings Pebbles");
            return true;
        }
    }
    if(current.room == "SL_AI" && settings["obj_saint_ping_moon"]) {
        if(current.saintPingMoon && !old.saintPingMoon) {
            vars.log("split", "Saint pings Moon");
            return true;
        }
    }
    // echoes
    if(current.echoID != null && current.echoID != old.echoID && current.echoID != "NoGhost") {
        if(current.echoID == "CL" && settings["echo_visit_UW"]) {
            vars.log("split", "Visited echo: " + current.echoID);
            return true;
        }
        if(settings.ContainsKey("echo_visit_" + current.echoID) && settings["echo_visit_" + current.echoID]) {
            vars.log("split", "Visited echo: " + current.echoID);
            vars.echoTimeout = 400;
            return true;
        }
    }
    // expedition complete
    if(current.lockGameTimer != old.lockGameTimer && current.lockGameTimer == true) {
        if(current.expeditionComplete) {
            if(settings["obj_ending_expedition"]) {
                vars.log("split", "Completed expedition");
                return true;
            }
        }
    }
    // passages
    if(current.waitingAchievement != old.waitingAchievement || current.waitingAchievementGOG != old.waitingAchievementGOG) {
        int achievmentId = Math.Max(current.waitingAchievement, current.waitingAchievementGOG);
        if(settings.ContainsKey("achievement_" + achievmentId) && settings["achievement_" + achievmentId]) {
            vars.log("split", "Obtained passage: " + achievmentId.ToString());
            return true;
        }
        else if(vars.echoTimeout == 0) {
            // backup splits for echos (current method doesn't work for same echo twice)
            if(
                (achievmentId == 11 && settings["echo_visit_CC"]) ||
                (achievmentId == 12 && settings["echo_visit_SI"]) ||
                (achievmentId == 13 && settings["echo_visit_LF"]) ||
                (achievmentId == 14 && settings["echo_visit_SH"]) ||
                (achievmentId == 15 && settings["echo_visit_UW"]) ||
                (achievmentId == 16 && settings["echo_visit_SB"])
            ) {
                vars.log("split", "Visited echo with achievement ID: " + achievmentId.ToString());
                return true;
            }
        }
    }
    // arena unlocks
    if(old.sandboxUnlocksCount != null && current.sandboxUnlocksCount > old.sandboxUnlocksCount) {
        var unlockName = vars.Helper.ReadString(64, ReadStringType.UTF16, current.sandboxUnlocksItems + 32 + (current.sandboxUnlocksCount - 1) * 8, 0x10, 0x18);
        if((settings.ContainsKey("arena_unlock_sandbox_" + unlockName) && settings["arena_unlock_sandbox_" + unlockName])) {
            vars.log("split", "Collected Arena unlock: " + unlockName);
            return true;
        }
    }
    if(old.levelUnlocksCount != null && current.levelUnlocksCount > old.levelUnlocksCount) {
        var unlockName = vars.Helper.ReadString(64, ReadStringType.UTF16, current.levelUnlocksItems + 32 + (current.levelUnlocksCount - 1) * 8, 0x10, 0x18);
        if((settings.ContainsKey("arena_unlock_level_" + unlockName) && settings["arena_unlock_level_" + unlockName])) {
            vars.log("split", "Collected Level unlock: " + unlockName);
            return true;
        }
    }
    if(old.slugcatUnlocksCount != null && current.slugcatUnlocksCount > old.slugcatUnlocksCount) {
        var unlockName = vars.Helper.ReadString(64, ReadStringType.UTF16, current.slugcatUnlocksItems + 32 + (current.slugcatUnlocksCount - 1) * 8, 0x10, 0x18);
        if((settings.ContainsKey("arena_unlock_class_" + unlockName) && settings["arena_unlock_class_" + unlockName])) {
            vars.log("split", "Collected Class unlock: " + unlockName);
            return true;
        }
    }
    if(old.safariUnlocksCount != null && current.safariUnlocksCount > old.safariUnlocksCount) {
        var unlockName = vars.Helper.ReadString(64, ReadStringType.UTF16, current.safariUnlocksItems + 32 + (current.safariUnlocksCount - 1) * 8, 0x10, 0x18);
        if((settings.ContainsKey("arena_unlock_safari_" + unlockName) && settings["arena_unlock_safari_" + unlockName])) {
            vars.log("split", "Collected Safari unlock: " + unlockName);
            return true;
        }
    }
    // spearmaster broadcasts
    if(old.broadcastsCount != null && current.broadcastsCount > old.broadcastsCount) {
        var unlockName = vars.Helper.ReadString(64, ReadStringType.UTF16, current.broadcastsItems + 32 + (current.broadcastsCount - 1) * 8, 0x10, 0x18);
        if((settings.ContainsKey("broadcast_" + unlockName) && settings["broadcast_" + unlockName])) {
            vars.log("split", "Collected broadcast unlock: " + unlockName);
            return true;
        }
    }
    // developer commentary tokens
    if(!old.chatlog && current.chatlog && current.chatlogID == "DevCommentaryNode") {
        if(current.playerCharacter == "Artificer") {
            if(settings.ContainsKey("devlog_artificer_" + current.room) && settings["devlog_artificer_" + current.room]) {
                vars.log("split", "Collected developer commentary token");
                return true;
            }
        }
        else if(current.playerCharacter == "Rivulet") {
            if(settings.ContainsKey("devlog_rivulet_" + current.room) && settings["devlog_rivulet_" + current.room]) {
                vars.log("split", "Collected developer commentary token");
                return true;
            }
        }
        else if(current.playerCharacter == "Spear") {
            if(settings.ContainsKey("devlog_spearmaster_" + current.room) && settings["devlog_spearmaster_" + current.room]) {
                vars.log("split", "Collected developer commentary token");
                return true;
            }
        }
        else if(current.playerCharacter == "Saint") {
            if(settings.ContainsKey("devlog_saint_" + current.room) && settings["devlog_saint_" + current.room]) {
                vars.log("split", "Collected developer commentary token");
                return true;
            }
        }
        else if(current.playerCharacter == "Inv") {
            if(settings.ContainsKey("devlog_inv_" + current.room) && settings["devlog_inv_" + current.room]) {
                vars.log("split", "Collected developer commentary token");
                return true;
            }
        }
        if(settings.ContainsKey("devlog_" + current.room) && settings["devlog_" + current.room]) {
            vars.log("split", "Collected developer commentary token");
            return true;
        }
    }
    // gourmander food quest
    if(current.processID == "Game" && current.playerCharacter == "Gourmand" && current.gourmandMeterCount > 0) {
        for (int i = 0; i < 22; i++) {
            if(settings["obj_foodquest_" + i]) {
                var gourmandMeterValue = vars.Helper.Read<int>(current.gourmandMeterItems + 32 + i * 8);
                var prevGourmandMeterValue = vars.gourmandFoodQuest[i];
                vars.gourmandFoodQuest[i] = gourmandMeterValue;
                if(prevGourmandMeterValue == 0 && gourmandMeterValue == 1) {
                    vars.log("split", "Collected gourmand food quest item " + i.ToString());
                    return true;
                }
            }
        }
    }
    // pearl pickups
    if((current.hand1pearlType != null && current.hand1pearlType != old.hand1pearlType)) {
        if(settings["pearl_pickup_" + current.hand1pearlType] && vars.collectedPearls.Add(current.hand1pearlType)) {
            vars.log("split", "SPLIT - Collected pearl " + current.hand1pearlType);
            return true;
        }
    }
    if((current.hand2pearlType != null && current.hand2pearlType != old.hand2pearlType)) {
        if(settings["pearl_pickup_" + current.hand2pearlType] && vars.collectedPearls.Add(current.hand2pearlType)) {
            vars.log("split", "SPLIT - Collected pearl " + current.hand2pearlType);
            return true;
        }
    }
    // start challenge
    if(current.processID == "MultiplayerMenu" && current.currentlySelectedGameType == "Challenge" && current.upcomingProcessID != old.upcomingProcessID && current.upcomingProcessID == "Game") {
        if(settings["challenge_start_" + current.selectedChallenge.ToString()]) {
            vars.log("split", "Challenge Started:  " + current.selectedChallenge.ToString());
            return true;
        }
    }
    // end challenge
    if(current.processID == "Game" && vars.sessionType == "SandboxGameSession" && current.challengeCompleted && !old.challengeCompleted) {
        if(settings["challenge_end_" + current.selectedChallenge.ToString()]) {
            vars.log("split", "Challenge Complete:  " + current.selectedChallenge.ToString());
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
        int deltaTime = 0;
        int time = 0;
        int prevTime = 0;
        if(vars.sessionType == "SandboxGameSession") {
            time = current.arenaAliveTime * 25;
            prevTime = old.arenaAliveTime * 25;
        }
        else {
            time = current.time * 25 + current.playerGrabbedTime * 25;

            // time recorded at the last livesplit poll
            prevTime = old.time * 25 + old.playerGrabbedTime  * 25;
        }
        // the difference between this time and the last recorded time is added to the timer
        // livesplit polls the game regularly but may lag so finding the difference is pretty secure I think
        deltaTime = Math.Max(time - prevTime, 0);

        if(deltaTime > 500) {
            if(vars.lastSafeTime == 0) {
                vars.lastSafeTime = prevTime;
            }
            deltaTime = 0;
        }
        else {
            if(vars.lastSafeTime != 0) {
                int catchUpTime = Math.Max(time - vars.lastSafeTime, 0);
                // this system is designed to capture moments when the memory value for the game time is totally wrong
                // what I should really be doing is checking that the value is actually valid but instead I'm using this convoluted system and I'm commited to it now so I want it to work
                // This only resets now if the adjustment time is lower than 30 seconds (ie. max time a lag spike might occur for) so hopefully this will fix the problem in the meantime
                if(catchUpTime < 30000) {
                    deltaTime = catchUpTime;
                    vars.lastSafeTime = 0;
                }
            }
        }
        
        // fix double speed timer when remix is disabled
        if(!vars.Helper["remixEnabled"].Current && deltaTime > 0) {
            deltaTime = deltaTime / 2;
        }

        // interpolated time
        if(current.pauseMenu == 0 && !current.paused) {
            if(!current.mscEnabled || current.artificerDreamNumber == -1) {
                if(!current.lockGameTimer && !current.voidSeaMode) {
                    TimeSpan delta = DateTime.Now - vars.oldTime;
                    vars.igt_interpolated += delta;
                    if(current.gameOverMode) {
                        deltaTime += (int)delta.TotalMilliseconds;
                    }
                }
            }
        }

        timeToAdd += deltaTime;
    }
    vars.oldTime = DateTime.Now;

    // add karma cache skip (mod) time
    if(vars.karmaCacheSkipModEnabled && current.karmaCacheSkipTime != old.karmaCacheSkipTime) {
        timeToAdd += current.karmaCacheSkipTime;
    }

    vars.igt += timeToAdd;
    
    if(current.CurrentFreeTimeSpan > old.CurrentFreeTimeSpan && (current.CurrentFreeTimeSpan - old.CurrentFreeTimeSpan) < vars.TWO_MINUTES) {
        vars.igt_native += current.CurrentFreeTimeSpan - old.CurrentFreeTimeSpan;
    }

    if(current.CurrentFreeTimeSpan > vars.igt_native_max) {
        vars.igt_native_max = current.CurrentFreeTimeSpan;
    }
    
    if(settings["use_native_incrementing_time"] && vars.sessionType != "SandboxGameSession") {
        if(vars.sessionType != "SandboxGameSession") {
            return vars.igt_native;
        }
        return TimeSpan.FromMilliseconds(vars.igt);
    }
    if(settings["use_native_raw_time"]) {
        return current.CurrentFreeTimeSpan;
    }
    if(settings["use_native_max_time"]) {
        return vars.igt_native_max;
    }
    if(settings["use_calculated_legacy_time"]) {
        return TimeSpan.FromMilliseconds(vars.igt);
    }
    if(settings["use_interpolated_time"]) {
        return vars.igt_interpolated;
    }
    return TimeSpan.Zero;
}

exit {
    vars.Helper.Dispose();
}

shutdown {
    vars.Helper.Dispose();
}
