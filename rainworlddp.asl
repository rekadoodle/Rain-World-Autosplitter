
state("RainWorld") {}

startup {
    Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Unity");
    vars.Helper.Settings.CreateFromXml("Components/rainworlddp.settings.xml");
}

init {
    vars.Helper.TryLoad = (Func<dynamic, bool>)(mono => {
        vars.Helper["room"] = mono.MakeString("RWCustom.Custom", "rainWorld", "processManager", "currentMainLoop", 0x1C, 0x10, 0x8, 0x10, 0xC);
        vars.Helper["time"] = mono.Make<int>("RWCustom.Custom", "rainWorld", "processManager", "currentMainLoop", 0x4C, 0x40, 0x10, 0x28);
        vars.Helper["playerGrabbedTime"] = mono.Make<int>("RWCustom.Custom", "rainWorld", "processManager", 0xC, 0x4C, 0x40, 0x10, 0x2c);

        vars.Helper["startButtonPressed"] = mono.Make<bool>("RWCustom.Custom", "rainWorld", "processManager", "currentMainLoop", 0x0e0, 0x058);
        vars.Helper["holdButtonType"] = mono.MakeString("RWCustom.Custom", "rainWorld", "processManager", "currentMainLoop", 0x0e0, 0x044);

        vars.Helper["remixEnabled"] = mono.Make<bool>("ModManager", "MMF");
        return true;
    });

    vars.igt = 0;
    vars.readyToStart = false;
    vars.lastSafeRecordedTime = 0;
    vars.visitedRooms = new List<string>();
    vars.lastSafeRoom = null;
    vars.oldtime = 0;
}

start {
    if((settings["autostart"])) {
        if(!vars.readyToStart && !vars.Helper["startButtonPressed"].Current) {
            vars.readyToStart = true;
        }
        if(vars.readyToStart && vars.Helper["startButtonPressed"].Current && vars.Helper["holdButtonType"].Current == "START") {
            return true;
        }
    }
}

split {
    // room splits
    if(vars.Helper["room"].Current != vars.Helper["room"].Old && vars.Helper["room"].Current != vars.lastSafeRoom && vars.Helper["room"].Current != null) {
        vars.lastSafeRoom = vars.Helper["room"].Current;
        if(settings.ContainsKey(vars.Helper["room"].Current) && settings[vars.Helper["room"].Current] && (!settings["rooms_once_only"] || !vars.visitedRooms.Contains(vars.Helper["room"].Current))) {
            vars.visitedRooms.Add(vars.Helper["room"].Current);
            return true;
        }
    }
}

isLoading {
    // only use igt, don't interpolate
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
            int currentTime = vars.Helper["time"].Current * 25 + vars.Helper["playerGrabbedTime"].Current * 25;
            int lastRecordedTime = vars.Helper["time"].Old * 25 + vars.Helper["playerGrabbedTime"].Old * 25;

            // the difference between this time and the last recorded time is added to the timer
            // livesplit polls the game regularly but may lag so finding the difference is pretty secure I think
            int deltaTime = 0;
            
            // there is some more code here to verify the variables make sense before we add stuff to the timer
            if(vars.lastSafeRecordedTime == 0 && currentTime == 0 && lastRecordedTime != 0) {
                vars.lastSafeRecordedTime = lastRecordedTime;
            }
            if(vars.lastSafeRecordedTime == 0 && currentTime != 0) {
                deltaTime = currentTime - lastRecordedTime;
                // print("2 - deltatime: " + deltaTime + ", currenttime: " + currentTime + ", safetime: " + vars.lastSafeRecordedTime + ", lasttime: " + lastRecordedTime);
            }
            else if(vars.lastSafeRecordedTime != 0 && currentTime != 0) { 
                if(currentTime > vars.lastSafeRecordedTime) {
                    deltaTime = currentTime - vars.lastSafeRecordedTime;
                }
                // print("1 - deltatime: " + deltaTime + ", currenttime: " + currentTime + ", safetime: " + vars.lastSafeRecordedTime + ", lasttime: " + lastRecordedTime);
                vars.lastSafeRecordedTime = 0;
            }
            if(deltaTime > 1000) {
                print("------------------------------------------------------");
                print("time increased by (ms): " + deltaTime);
                print("current time (ms): " + vars.igt);
                print("------------------------------------------------------");
            }
            if(!vars.Helper["remixEnabled"].Current) {
                deltaTime = deltaTime / 2;
            }
            vars.igt += deltaTime;
    
    return TimeSpan.FromMilliseconds(vars.igt);
}