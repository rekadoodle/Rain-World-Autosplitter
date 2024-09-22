// Rain World v1.9 Autosplitter v0.04.00 by rek 
// https://github.com/rekadoodle/Rain-World-Autosplitter

state("RainWorld") {}

startup {
    var type = Assembly.Load(File.ReadAllBytes(@"Components\asl-help")).GetType("Unity");
    vars.Helper = Activator.CreateInstance(type, args: false);
    vars.Helper.Settings.CreateFromXml("Components/rainworlddp.settings.xml", false);

    vars.visitedRooms = new HashSet<string>();
    vars.collectedPearls = new HashSet<string>();
    vars.karmaCacheSkipModEnabled = false;

    vars.igt = 0;
    vars.ONE_SECOND = TimeSpan.FromSeconds(1);
    vars.igt_native = new TimeSpan();
    vars.lastSafeTime = 0;
    vars.moonReached = false;
    vars.sessionType = null;
    vars.echoTimeout = 0;

    vars.alertShown = false;
    vars.Helper.GameName = "Rain World";
    vars.logPrefix = "Rain World ASL v0.04.00: ";
}

onStart {
    vars.igt = 0;
    vars.igt_native = new TimeSpan();
    vars.visitedRooms.Clear();
    vars.collectedPearls.Clear();
    vars.lastSafeTime = 0;
    vars.moonReached = false;
    vars.gourmandFoodQuest = new int[22];
}

init {
    vars.Helper.TryLoad = (Func<dynamic, bool>)(mono => {
        vars.Helper["room"] = mono.MakeString("RWCustom.Custom", "rainWorld", 0xC, 0xC, 0x1C, 0x10, 0x8, 0x10, 0xC);
        vars.Helper["gateStatus"] = mono.MakeString("RWCustom.Custom", "rainWorld", 0xC, 0xC, 0x1C, 0x10, 0x8, 0x9c, 0x20, 0x8);
        vars.Helper["time"] = mono.Make<int>("RWCustom.Custom", "rainWorld", 0xC, 0xC, 0x4C, 0x40, 0x10, 0x28);
        vars.Helper["playerGrabbedTime"] = mono.Make<int>("RWCustom.Custom", "rainWorld", 0xC, 0xC, 0x4C, 0x40, 0x10, 0x2c);
        vars.Helper["playerX"] = mono.Make<float>("RWCustom.Custom", "rainWorld", 0xC, 0xC, 0x1C, 0x10, 0x104, 0x8, 0x10, 0x10, 0x18);
        vars.Helper["playerCharacter"] = mono.MakeString("RWCustom.Custom", "rainWorld", 0xC, 0xC, 0x1C, 0x10, 0x104, 0x8, 0x244, 0x8);
        vars.Helper["theMark"] = mono.Make<bool>("RWCustom.Custom", "rainWorld", 0xC, 0xC, 0x4C, 0x20, 0x44, 0x5D);
        vars.Helper["pebblesHasIncreasedRedsKarmaCap"] = mono.Make<bool>("RWCustom.Custom", "rainWorld", 0xC, 0xC, 0x4C, 0x20, 0x44, 0x60);
        vars.Helper["scarVisible"] = mono.Make<bool>("RWCustom.Custom", "rainWorld", 0xC, 0xC, 0x1C, 0x10, 0x104, 0x8, 0x18, 0x54, 0x58);
        vars.Helper["moonRevived"] = mono.Make<bool>("RWCustom.Custom", "rainWorld", 0xC, 0xC, 0x4C, 0x20, 0x40, 0x20);
        vars.Helper["moonEquipsRobe"] = mono.Make<bool>("RWCustom.Custom", "rainWorld", 0xC, 0xC, 0x4C, 0x20, 0x40, 0x31);
        vars.Helper["echoID"] = mono.MakeString("RWCustom.Custom", "rainWorld", 0xC, 0xC, 0x60, 0x8);
        
        vars.Helper["rivOrbCollected"] = mono.Make<bool>("RWCustom.Custom", "rainWorld", 0xC, 0xC, 0x4C, 0x20, 0x40, 0x28);
        vars.Helper["rivOrbPlaced"] = mono.Make<bool>("RWCustom.Custom", "rainWorld", 0xC, 0xC, 0x4C, 0x20, 0x40, 0x30);
        vars.Helper["moonPingSpearmaster"] = mono.Make<bool>("RWCustom.Custom", "rainWorld", 0xC, 0xC, 0x4C, 0x20, 0x40, 0x32);
        vars.Helper["saintPingPebbles"] = mono.Make<bool>("RWCustom.Custom", "rainWorld", 0xC, 0xC, 0x4C, 0x20, 0x44, 0x7E);
        vars.Helper["saintPingMoon"] = mono.Make<bool>("RWCustom.Custom", "rainWorld", 0xC, 0xC, 0x4C, 0x20, 0x44, 0x7F);

        vars.Helper["voidSeaMode"] = mono.Make<bool>("RWCustom.Custom", "rainWorld", 0xC, 0xC, 0x1C, 0x10, 0x184);
        vars.Helper["reinforcedKarma"] = mono.Make<bool>("RWCustom.Custom", "rainWorld", 0xC, 0xC, 0x4C, 0x20, 0x44, 0x5C);
        vars.Helper["lockGameTimer"] = mono.Make<bool>("RainWorld", "lockGameTimer");
        vars.Helper["CurrentFreeTimeSpan"] = mono.Make<TimeSpan>("RainWorld", "CurrentFreeTimeSpan");

        vars.Helper["processID"] = mono.MakeString("RWCustom.Custom", "rainWorld", 0xC, 0xC, 0xC, 0x8);
        vars.Helper["upcomingProcessID"] = mono.MakeString("RWCustom.Custom", "rainWorld", 0xC, 0x30, 0x8);
        vars.Helper["startButtonPressed"] = mono.Make<bool>("RWCustom.Custom", "rainWorld", 0xC, 0xC, 0x0e0, 0x058);
        vars.Helper["currentlySelectedSlugcat"] = mono.MakeString("RWCustom.Custom", "rainWorld", 0x14, 0x18, 0x28, 0x8);
        vars.Helper["redIsDead"] = mono.Make<bool>("RWCustom.Custom", "rainWorld", 0xC, 0xC, 0x13D);
        vars.Helper["artificerIsDead"] = mono.Make<bool>("RWCustom.Custom", "rainWorld", 0xC, 0xC, 0x154);
        vars.Helper["saintIsDead"] = mono.Make<bool>("RWCustom.Custom", "rainWorld", 0xC, 0xC, 0x155);
        vars.Helper["expeditionStartButtonPressed"] = mono.Make<bool>("RWCustom.Custom", "rainWorld", 0xC, 0xC, 0xFC, 0xC8, 0xC4);
        vars.Helper["gameInitCondition"] = mono.MakeString("RWCustom.Custom", "rainWorld", 0xC, 0x58, 0x8, 0x8);
        vars.Helper["currentlySelectedGameType"] = mono.MakeString("RWCustom.Custom", "rainWorld", 0xC, 0x60, 0xC, 0x8);
        vars.Helper["selectedChallenge"] = mono.Make<int>("RWCustom.Custom", "rainWorld", 0xC, 0xC, 0x134, 0x30, 0x6C);
        vars.Helper["challengeCompleted"] = mono.Make<bool>("RWCustom.Custom", "rainWorld", 0xC, 0xC, 0x4C, 0x59);
        vars.Helper["session"] = mono.Make<IntPtr>("RWCustom.Custom", "rainWorld", 0xC, 0xC, 0x4C);
        vars.Helper["arenaAliveTime"] = mono.Make<int>("RWCustom.Custom", "rainWorld", 0xC, 0xC, 0x4C, 0x20, 0xC, 0x8, 0x10, 0x2C);

        vars.Helper["waitingAchievement"] = mono.Make<int>("RWCustom.Custom", "rainWorld", 0xC, 0xBC);
        vars.Helper["waitingAchievementGOG"] = mono.Make<int>("RWCustom.Custom", "rainWorld", 0xC, 0xC4);
        vars.Helper["sandboxUnlocksCount"] = mono.Make<int>("RWCustom.Custom", "rainWorld", 0x14, 0x18, 0x18, 0xC);
        vars.Helper["sandboxUnlocksItems"] = mono.Make<IntPtr>("RWCustom.Custom", "rainWorld", 0x14, 0x18, 0x18, 0x8);
        vars.Helper["levelUnlocksCount"] = mono.Make<int>("RWCustom.Custom", "rainWorld", 0x14, 0x18, 0x14, 0xC);
        vars.Helper["levelUnlocksItems"] = mono.Make<IntPtr>("RWCustom.Custom", "rainWorld", 0x14, 0x18, 0x14, 0x8);

        vars.Helper["slugcatUnlocksCount"] = mono.Make<int>("RWCustom.Custom", "rainWorld", 0x14, 0x18, 0x6C, 0xC);
        vars.Helper["slugcatUnlocksItems"] = mono.Make<IntPtr>("RWCustom.Custom", "rainWorld", 0x14, 0x18, 0x6C, 0x8);
        vars.Helper["safariUnlocksCount"] = mono.Make<int>("RWCustom.Custom", "rainWorld", 0x14, 0x18, 0x70, 0xC);
        vars.Helper["safariUnlocksItems"] = mono.Make<IntPtr>("RWCustom.Custom", "rainWorld", 0x14, 0x70, 0x18, 0x8);
        vars.Helper["broadcastsCount"] = mono.Make<int>("RWCustom.Custom", "rainWorld", 0x14, 0x18, 0x84, 0xC);
        vars.Helper["broadcastsItems"] = mono.Make<IntPtr>("RWCustom.Custom", "rainWorld", 0x14, 0x18, 0x84, 0x8);
        vars.Helper["chatlogID"] = mono.MakeString("RWCustom.Custom", "rainWorld", 0xC, 0xC, 0x1C, 0x10, 0x104, 0x8, 0x240, 0x8);
        vars.Helper["chatlog"] = mono.Make<bool>("RWCustom.Custom", "rainWorld", 0xC, 0xC, 0x1C, 0x10, 0x104, 0x8, 0x47D);
        vars.Helper["gourmandMeterCount"] = mono.Make<int>("RWCustom.Custom", "rainWorld", 0xC, 0xC, 0x1C, 0x10, 0x104, 0x44, 0x14, 0xC);
        vars.Helper["gourmandMeterItems"] = mono.Make<IntPtr>("RWCustom.Custom", "rainWorld", 0xC, 0xC, 0x1C, 0x10, 0x104, 0x44, 0x14, 0x8);
        vars.Helper["hand1pearlType"] = mono.MakeString("RWCustom.Custom", "rainWorld", 0xC, 0xC, 0x1C, 0x10, 0x104, 0x8, 0x70, 0x10, 0xC, 0x20, 0x64, 0x8);
        vars.Helper["hand2pearlType"] = mono.MakeString("RWCustom.Custom", "rainWorld", 0xC, 0xC, 0x1C, 0x10, 0x104, 0x8, 0x70, 0x14, 0xC, 0x20, 0x64, 0x8);

        vars.Helper["remixEnabled"] = mono.Make<bool>("ModManager", "MMF");
        vars.Helper["expeditionComplete"] = mono.Make<bool>("Expedition.ExpeditionGame", "expeditionComplete");

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
    vars.Helper.Load();
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
            vars.sessionType = vars.Helper.ReadString(32, ReadStringType.UTF8, current.session, 0x0, 0x2C, 0x0);
        }
    }
    if(vars.echoTimeout > 0) {
        vars.echoTimeout--;
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
                if(settings["debug_log_start"]) {
                    print(vars.logPrefix + "START - Start new campaign");
                }
                return true;
            }
            if(current.gameInitCondition == "Load" && settings["start_load_campaign"]) {
                if(settings["debug_log_start"]) {
                    print(vars.logPrefix + "START - Load campaign");
                }
                return true;
            }
        }
    }
    // trigger start when the expedition start button fills up
    if(current.processID == "ExpeditionMenu" && settings["start_new_expedition"]) {
        if(current.expeditionStartButtonPressed && !old.expeditionStartButtonPressed) {
            if(settings["debug_log_start"]) {
                print(vars.logPrefix + "START - Start new expedition");
            }
            return true;
        }
    }
    // trigger start on expedition retry
    if(current.processID == "ExpeditionGameOver" && settings["start_retry_expedition"]) {
        if(current.gameInitCondition != old.gameInitCondition && current.gameInitCondition == "New") {
            if(settings["debug_log_start"]) {
                print(vars.logPrefix + "START - Reset expedition");
            }
            return true;
        }
    }
    // room split triggers start
    if(settings["start_room_split"] && current.room != null && current.room != old.room) {
        if(settings.ContainsKey(current.room) && settings[current.room]) {
            if(settings["debug_log_start"]) {
                print(vars.logPrefix + "START - Room change: " + (old.room ?? "NULL") + " => " + current.room);
            }
            return true;
        }
    }
    // challenge start
    if(current.processID == "MultiplayerMenu" && current.currentlySelectedGameType == "Challenge" && current.upcomingProcessID != old.upcomingProcessID && current.upcomingProcessID == "Game") {
        if(settings["start_challenge_start_" + current.selectedChallenge.ToString()]) {
            if(settings["debug_log_start"]) {
                print(vars.logPrefix + "START - Challenge Started:  " + current.selectedChallenge.ToString());
            }
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
                if(settings["debug_log_reset"]) {
                    print(vars.logPrefix + "RESET - Reset new campaign");
                }
                return true;
            }
            if(current.gameInitCondition == "Load" && settings["reset_load_campaign"]) {
                if(settings["debug_log_reset"]) {
                    print(vars.logPrefix + "RESET - Reset load campaign");
                }
                return true;
            }
        }
    }
    // trigger start when the expedition start button fills up
    if(current.processID == "ExpeditionMenu" && settings["reset_new_expedition"]) {
        if(current.expeditionStartButtonPressed && !old.expeditionStartButtonPressed) {
            if(settings["debug_log_reset"]) {
                print(vars.logPrefix + "RESET - Reset expedition");
            }
            return true;
        }
    }
    // trigger start on expedition retry
    if(current.processID == "ExpeditionGameOver" && settings["reset_retry_expedition"]) {
        if(current.gameInitCondition != old.gameInitCondition && current.gameInitCondition == "New") {
            if(settings["debug_log_reset"]) {
                print(vars.logPrefix + "RESET - Reset expedition");
            }
            return true;
        }
    }
    // trigger start on challenge start
    if(current.processID == "MultiplayerMenu" && current.currentlySelectedGameType == "Challenge" && current.upcomingProcessID != old.upcomingProcessID && current.upcomingProcessID == "Game") {
        if(settings["reset_challenge_start_" + current.selectedChallenge.ToString()]) {
            if(settings["debug_log_reset"]) {
                print(vars.logPrefix + "RESET - Challenge Started:  " + current.selectedChallenge.ToString());
            }
            return true;
        }
    }
}

split {
    // log menu change
    if(settings["debug_log_menu"] && current.processID != null && current.processID != old.processID) {
        print(vars.logPrefix + "MENU CHANGE: " + (old.processID ?? "NULL") + " => " + current.processID);
    }
    // room splits
    if(current.room != null && current.room != old.room) {
        if(settings["debug_log_room"]) {
            print(vars.logPrefix + "ROOM CHANGE: " + (old.room ?? "NULL") + " => " + current.room);
        }
        if(settings.ContainsKey(current.room) && settings[current.room]) {
            if(!settings["rooms_once_only"] || vars.visitedRooms.Add(current.room)) {
                if(settings["debug_log_split"]) {
                    print(vars.logPrefix + "SPLIT - Room change: " + (old.room ?? "NULL") + " => " + current.room);
                }
                return true;
            }
        }
    }
    // gate splits
    if(current.room != null && current.gateStatus != old.gateStatus) {
        if(settings["GATE_ANY_OPEN"] || (settings.ContainsKey(current.room + "_OPEN") && settings[current.room + "_OPEN"])) {
            if(settings.ContainsKey("gate_mode_" + current.gateStatus) && settings["gate_mode_" + current.gateStatus]) {
                if(settings["debug_log_split"]) {
                    print(vars.logPrefix + "SPLIT - Gate " + current.room + ": Animation status " + current.gateStatus);
                }
                return true;
            }
        }
    }
    // void swim split
    if(current.voidSeaMode != old.voidSeaMode && current.voidSeaMode == true && settings["obj_ending_voidswim"]) {
        if(settings["debug_log_split"]) {
            print(vars.logPrefix + "SPLIT - Entered Void Sea");
        }
        return true;
    }
    // other ending splits
    if(current.room != null) {
        if(current.lockGameTimer != old.lockGameTimer && current.lockGameTimer == true) {
            if(current.room == "OE_FINAL03" && settings["obj_ending_slugtree"]) {
                if(settings["debug_log_split"]) {
                    print(vars.logPrefix + "SPLIT - Gourmand Ending");
                }
                return true;
            }
            if(current.room == "SI_A07" && settings["obj_ending_broadcast"]) {
                if(settings["debug_log_split"]) {
                    print(vars.logPrefix + "SPLIT - Spearmaster Ending");
                }
                return true;
            }
            if(current.room == "SL_MOONTOP" && settings["obj_ending_moonrise"]) {
                if(settings["debug_log_split"]) {
                    print(vars.logPrefix + "SPLIT - Rivulet Ending");
                }
                return true;
            }
        }
        if(current.reinforcedKarma != old.reinforcedKarma && current.reinforcedKarma == false) {
            if(current.room == "LC_FINAL" && settings["obj_ending_regicide"]) {
                if(settings["debug_log_split"]) {
                    print(vars.logPrefix + "SPLIT - Artificer Ending");
                }
                return true;
            }
        }
    }
    // visit moon split (moon%)
    if(!vars.moonReached && current.room == "SL_AI" && current.playerX >= 1160f) {
        vars.moonReached = true;
        if(settings["obj_visit_moon"]) {
            if(settings["debug_log_split"]) {
                print(vars.logPrefix + "SPLIT - Visit Moon (moon%)");
            }
            return true;
        }
    }
    // revive moon (hunter)
    if(current.room == "SL_AI") {
        if(current.moonRevived && !old.moonRevived && settings["obj_revive_moon"]) {
            if(settings["debug_log_split"]) {
                print(vars.logPrefix + "SPLIT - Revived Moon");
            }
            return true;
        }
    }
    // clothe moon
    if(current.room == "SL_AI") {
        if(current.moonEquipsRobe && !old.moonEquipsRobe && settings["obj_cloak_moon"]) {
            if(settings["debug_log_split"]) {
                print(vars.logPrefix + "SPLIT - Give Moon cloak");
            }
            return true;
        }
    }
    // pebbles ping
    if(current.room == "SS_AI" && settings["obj_pebbles_ping"]) {
        if(current.theMark && !old.theMark) {
            if(settings["debug_log_split"]) {
                print(vars.logPrefix + "SPLIT - Pebbles ping");
            }
            return true;
        }
        if(current.pebblesHasIncreasedRedsKarmaCap && !old.pebblesHasIncreasedRedsKarmaCap) {
            if(settings["debug_log_split"]) {
                print(vars.logPrefix + "SPLIT - Pebbles ping");
            }
            return true;
        }
        if(current.scarVisible && !old.scarVisible) {
            if(settings["debug_log_split"]) {
                print(vars.logPrefix + "SPLIT - Pebbles ping");
            }
            return true;
        }
    }
    // msc objectives
    if(current.room == "RM_CORE" && settings["obj_riv_pickup_orb"]) {
        if(current.rivOrbCollected && !old.rivOrbCollected) {
            if(settings["debug_log_split"]) {
                print(vars.logPrefix + "SPLIT - Rivulet takes orb");
            }
            return true;
        }
    }
    if(current.room == "MS_CORE" && settings["obj_riv_place_orb"]) {
        if(current.rivOrbPlaced && !old.rivOrbPlaced) {
            if(settings["debug_log_split"]) {
                print(vars.logPrefix + "SPLIT - Rivulet places orb");
            }
            return true;
        }
    }
    if(current.room == "DM_AI" && settings["obj_moon_ping"]) {
        if(current.moonPingSpearmaster && !old.moonPingSpearmaster) {
            if(settings["debug_log_split"]) {
                print(vars.logPrefix + "SPLIT - Moon pings Spearmaster");
            }
            return true;
        }
    }
    if(current.room == "CL_AI" && settings["obj_saint_ping_pebbles"]) {
        if(current.saintPingPebbles && !old.saintPingPebbles) {
            if(settings["debug_log_split"]) {
                print(vars.logPrefix + "SPLIT - Saint pings Pebbles");
            }
            return true;
        }
    }
    if(current.room == "SL_AI" && settings["obj_saint_ping_moon"]) {
        if(current.saintPingMoon && !old.saintPingMoon) {
            if(settings["debug_log_split"]) {
                print(vars.logPrefix + "SPLIT - Saint pings Moon");
            }
            return true;
        }
    }
    // echoes
    if(current.echoID != null && current.echoID != old.echoID && current.echoID != "NoGhost") {
        if(current.echoID == "CL" && settings["echo_visit_UW"]) {
            if(settings["debug_log_split"]) {
                print(vars.logPrefix + "SPLIT - Visited echo: " + current.echoID);
            }
            return true;
        }
        if(settings.ContainsKey("echo_visit_" + current.echoID) && settings["echo_visit_" + current.echoID]) {
            if(settings["debug_log_split"]) {
                print(vars.logPrefix + "SPLIT - Visited echo: " + current.echoID);
            }
            vars.echoTimeout = 400;
            return true;
        }
    }
    // expedition complete
    if(current.lockGameTimer != old.lockGameTimer && current.lockGameTimer == true) {
        if(current.expeditionComplete) {
            if(settings["obj_ending_expedition"]) {
                if(settings["debug_log_split"]) {
                    print(vars.logPrefix + "SPLIT - Completed expedition");
                }
                return true;
            }
        }
    }
    // passages
    if(current.waitingAchievement != old.waitingAchievement || current.waitingAchievementGOG != old.waitingAchievementGOG) {
        int achievmentId = Math.Max(current.waitingAchievement, current.waitingAchievementGOG);
        if(settings.ContainsKey("achievement_" + achievmentId) && settings["achievement_" + achievmentId]) {
            if(settings["debug_log_split"]) {
                print(vars.logPrefix + "SPLIT - Obtained passage: " + achievmentId.ToString());
            }
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
                if(settings["debug_log_split"]) {
                    print(vars.logPrefix + "SPLIT - Visited echo with achievement ID: " + achievmentId.ToString());
                }
                return true;
            }
        }
    }
    // arena unlocks
    if(old.sandboxUnlocksCount != null && current.sandboxUnlocksCount > old.sandboxUnlocksCount) {
        var unlockName = vars.Helper.ReadString(64, ReadStringType.UTF16, current.sandboxUnlocksItems + 16 + (current.sandboxUnlocksCount - 1) * 4, 0x8, 0xC);
        if((settings.ContainsKey("arena_unlock_sandbox_" + unlockName) && settings["arena_unlock_sandbox_" + unlockName])) {
            if(settings["debug_log_split"]) {
                print(vars.logPrefix + "SPLIT - Collected Arena unlock: " + unlockName);
            }
            return true;
        }
    }
    if(old.levelUnlocksCount != null && current.levelUnlocksCount > old.levelUnlocksCount) {
        var unlockName = vars.Helper.ReadString(64, ReadStringType.UTF16, current.levelUnlocksItems + 16 + (current.levelUnlocksCount - 1) * 4, 0x8, 0xC);
        if((settings.ContainsKey("arena_unlock_level_" + unlockName) && settings["arena_unlock_level_" + unlockName])) {
            if(settings["debug_log_split"]) {
                print(vars.logPrefix + "SPLIT - Collected Level unlock: " + unlockName);
            }
            return true;
        }
    }
    if(old.slugcatUnlocksCount != null && current.slugcatUnlocksCount > old.slugcatUnlocksCount) {
        var unlockName = vars.Helper.ReadString(64, ReadStringType.UTF16, current.slugcatUnlocksItems + 16 + (current.slugcatUnlocksCount - 1) * 4, 0x8, 0xC);
        if((settings.ContainsKey("arena_unlock_class_" + unlockName) && settings["arena_unlock_class_" + unlockName])) {
            return true;
        }
    }
    if(old.safariUnlocksCount != null && current.safariUnlocksCount > old.safariUnlocksCount) {
        var unlockName = vars.Helper.ReadString(64, ReadStringType.UTF16, current.safariUnlocksItems + 16 + (current.safariUnlocksCount - 1) * 4, 0x8, 0xC);
        if((settings.ContainsKey("arena_unlock_safari_" + unlockName) && settings["arena_unlock_safari_" + unlockName])) {
            if(settings["debug_log_split"]) {
                print(vars.logPrefix + "SPLIT - Collected Class unlock: " + unlockName);
            }
            return true;
        }
    }
    // spearmaster broadcasts
    if(old.broadcastsCount != null && current.broadcastsCount > old.broadcastsCount) {
        var unlockName = vars.Helper.ReadString(64, ReadStringType.UTF16, current.broadcastsItems + 16 + (current.broadcastsCount - 1) * 4, 0x8, 0xC);
        if((settings.ContainsKey("broadcast_" + unlockName) && settings["broadcast_" + unlockName])) {
            if(settings["debug_log_split"]) {
                print(vars.logPrefix + "SPLIT - Collected broadcast: " + unlockName);
            }
            return true;
        }
    }
    // developer commentary tokens
    if(!old.chatlog && current.chatlog && current.chatlogID == "DevCommentaryNode") {
        if(current.playerCharacter == "Artificer") {
            if(settings.ContainsKey("devlog_artificer_" + current.room) && settings["devlog_artificer_" + current.room]) {
                if(settings["debug_log_split"]) {
                    print(vars.logPrefix + "SPLIT - Collected developer commentary token");
                }
                return true;
            }
        }
        else if(current.playerCharacter == "Rivulet") {
            if(settings.ContainsKey("devlog_rivulet_" + current.room) && settings["devlog_rivulet_" + current.room]) {
                if(settings["debug_log_split"]) {
                    print(vars.logPrefix + "SPLIT - Collected developer commentary token");
                }
                return true;
            }
        }
        else if(current.playerCharacter == "Spear") {
            if(settings.ContainsKey("devlog_spearmaster_" + current.room) && settings["devlog_spearmaster_" + current.room]) {
                if(settings["debug_log_split"]) {
                    print(vars.logPrefix + "SPLIT - Collected developer commentary token");
                }
                return true;
            }
        }
        else if(current.playerCharacter == "Saint") {
            if(settings.ContainsKey("devlog_saint_" + current.room) && settings["devlog_saint_" + current.room]) {
                if(settings["debug_log_split"]) {
                    print(vars.logPrefix + "SPLIT - Collected developer commentary token");
                }
                return true;
            }
        }
        else if(current.playerCharacter == "Inv") {
            if(settings.ContainsKey("devlog_inv_" + current.room) && settings["devlog_inv_" + current.room]) {
                if(settings["debug_log_split"]) {
                    print(vars.logPrefix + "SPLIT - Collected developer commentary token");
                }
                return true;
            }
        }
        if(settings.ContainsKey("devlog_" + current.room) && settings["devlog_" + current.room]) {
            if(settings["debug_log_split"]) {
                print(vars.logPrefix + "SPLIT - Collected developer commentary token");
            }
            return true;
        }
    }
    // gourmander food quest
    if(current.processID == "Game" && current.playerCharacter == "Gourmand" && current.gourmandMeterCount > 0) {
        for (int i = 0; i < 22; i++) {
            if(settings["obj_foodquest_" + i]) {
                var gourmandMeterValue = vars.Helper.Read<int>(current.gourmandMeterItems + 16 + i * 4);
                var prevGourmandMeterValue = vars.gourmandFoodQuest[i];
                vars.gourmandFoodQuest[i] = gourmandMeterValue;
                if(prevGourmandMeterValue == 0 && gourmandMeterValue == 1) {
                    if(settings["debug_log_split"]) {
                        print(vars.logPrefix + "SPLIT - Collected gourmand food quest item " + i.ToString());
                    }
                    return true;
                }
            }
        }
    }
    // pearl pickups
    if((current.hand1pearlType != null && current.hand1pearlType != old.hand1pearlType)) {
        if(settings["pearl_pickup_" + current.hand1pearlType] || vars.collectedPearls.Add(current.hand1pearlType)) {
            if(settings["debug_log_split"]) {
                print(vars.logPrefix + "SPLIT - Collected pearl " + current.hand1pearlType);
            }
            return true;
        }
    }
    if((current.hand2pearlType != null && current.hand2pearlType != old.hand2pearlType)) {
        if(settings["pearl_pickup_" + current.hand2pearlType] || vars.collectedPearls.Add(current.hand2pearlType)) {
            if(settings["debug_log_split"]) {
                print(vars.logPrefix + "SPLIT - Collected pearl " + current.hand2pearlType);
            }
            return true;
        }
    }
    // start challenge
    if(current.processID == "MultiplayerMenu" && current.currentlySelectedGameType == "Challenge" && current.upcomingProcessID != old.upcomingProcessID && current.upcomingProcessID == "Game") {
        if(settings["challenge_start_" + current.selectedChallenge.ToString()]) {
            if(settings["debug_log_split"]) {
                print(vars.logPrefix + "SPLIT - Challenge Started:  " + current.selectedChallenge.ToString());
            }
            return true;
        }
    }
    // end challenge
    if(current.processID == "Game" && vars.sessionType == "SandboxGameSession" && current.challengeCompleted && !old.challengeCompleted) {
        if(settings["challenge_end_" + current.selectedChallenge.ToString()]) {
            if(settings["debug_log_split"]) {
                print(vars.logPrefix + "SPLIT - Challenge Complete:  " + current.selectedChallenge.ToString());
            }
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

        timeToAdd += deltaTime;
    }

    // add karma cache skip (mod) time
    if(vars.karmaCacheSkipModEnabled && current.karmaCacheSkipTime != old.karmaCacheSkipTime) {
        timeToAdd += current.karmaCacheSkipTime;
    }

    vars.igt += timeToAdd;
    
    if(current.CurrentFreeTimeSpan > old.CurrentFreeTimeSpan && (current.CurrentFreeTimeSpan - old.CurrentFreeTimeSpan) < vars.ONE_SECOND) {
        vars.igt_native += current.CurrentFreeTimeSpan - old.CurrentFreeTimeSpan;
    }

    if(settings["force_native_gametime_only"]) {
        return current.CurrentFreeTimeSpan;
    }
    if(settings["use_native_ingame_time"] && vars.sessionType != "SandboxGameSession") {
        return vars.igt_native;
    }
    return TimeSpan.FromMilliseconds(vars.igt);
}

exit {
    vars.Helper.Dispose();
}

shutdown {
    vars.Helper.Dispose();
}
