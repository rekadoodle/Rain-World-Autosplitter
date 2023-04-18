
//TODO consider fast shelters and maybe other mechanics with IGT
//TODO improve response time of auto-start with processManager.upcomingProcess or actually inspecting the hud elements

state("RainWorld", "v1.9 Steam") {
        // i don't know the syntax for almost all of this currently so we have a bunch of long addresses 
        // int rainWorld : "mono-2.0-bdwgc.dll", 0x003A820C, 0x50, 0xC, 0x308, 0x20, 0xE8, 0x280, 0x100;
        // string32 room : new MemoryWatcher<int>(new DeepPointer((IntPtr)current.rainWorld, 0xC, 0xC, 0x1C, 0x10, 0x8, 0x10, 0xC, 0xC));



        
        string32 room : "mono-2.0-bdwgc.dll", 0x003A820C, 0x50, 0xC, 0x308, 0x20, 0xE8, 0x280, 0x100, 0xC, 0xC, 0x1C, 0x10, 0x8, 0x10, 0xC, 0xC;

        // int totTime : "mono-2.0-bdwgc.dll", 0x003A820C, 0x50, 0xC, 0x308, 0x20, 0xE8, 0x280, 0x100, 0xC, 0xC, 0x4C, 0x20, 0x88;
        // int deathTime : "mono-2.0-bdwgc.dll", 0x003A820C, 0x50, 0xC, 0x308, 0x20, 0xE8, 0x280, 0x100, 0xC, 0xC, 0x4C, 0x20, 0x3C, 0x80;
        int time : "mono-2.0-bdwgc.dll", 0x003A820C, 0x50, 0xC, 0x308, 0x20, 0xE8, 0x280, 0x100, 0xC, 0xC, 0x4C, 0x40, 0x10, 0x28;
        int playerGrabbedTime : "mono-2.0-bdwgc.dll", 0x003A820C, 0x50, 0xC, 0x308, 0x20, 0xE8, 0x280, 0x100, 0xC, 0xC, 0x4C, 0x40, 0x10, 0x2c;

        string32 mainProcessName : "mono-2.0-bdwgc.dll", 0x003A820C, 0x50, 0xC, 0x308, 0x20, 0xE8, 0x280, 0x100, 0xC, 0xC, 0xC, 0x8, 0xC;
        string32 oldProcessName : "mono-2.0-bdwgc.dll", 0x003A820C, 0x50, 0xC, 0x308, 0x20, 0xE8, 0x280, 0x100, 0xC, 0x2C, 0xC, 0x8, 0xC;
        string32 gameInitConditionName : "mono-2.0-bdwgc.dll", 0x003A820C, 0x50, 0xC, 0x308, 0x20, 0xE8, 0x280, 0x100, 0xC, 0x58, 0x8, 0x8, 0xC;
    }

startup {

    settings.Add("start_new", true, "New game starts timer");
    settings.Add("start_load", false, "Opening a save starts timer");
    // refreshRate = 1;
    // Func<Int32[], DeepPointer> rwPtr = offsets => {
    //     Int32[] rwGameOffsets = {0x50, 0xC, 0x308, 0x20, 0xE8, 0x280, 0x100, 0xC, 0xC};
    //     return new DeepPointer("mono-2.0-bdwgc.dll", 0x003A820C, rwGameOffsets.Concat(offsets).ToArray());
    // };

    // vars.room = new StringWatcher(rwPtr(new Int32[] {0x1C, 0x10, 0x8, 0x10, 0xC, 0xC}), 64);

    vars.igt = 0;
}

update {
    // vars.room.Update(game);
}

init {
}

start {
    //print("mainProcessName: " + current.mainProcessName +  " oldProcessName: " + current.oldProcessName);
    if(current.mainProcessName != old.mainProcessName) {
        if(current.oldProcessName == "SlugcatSelect" && current.mainProcessName == "Game") {
            if((settings["start_new"] && current.gameInitConditionName == "New") || (settings["start_load"] && current.gameInitConditionName == "Load"))
                return true;
        }
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

    if(current.room != old.room) {
        print(current.mainProcessName);
    }
}

isLoading {
    //only use igt, don't interpolate
    return true;
}

onReset {
    vars.igt = 0;
}

onStart {
    vars.igt = 0;
}

gameTime {
    //actual igt from HUD, this pointer only works with certain user settings and is rounded to nearest second
    //return new DeepPointer("mono-2.0-bdwgc.dll", 0x003A820C, 0x50, 0xC, 0x308, 0x20, 0xE8, 0x280, 0x100, 0xC, 0xC, 0x1C, 0x10, 0x104, 0x10, 0x8, 0x30, 0x30).Deref<TimeSpan>(game);

    // print("totTime: " + current.totTime);
    // print("deathTime: " + current.deathTime);
    // print("time: " + current.time);2
    // print("playerGrabbedTime: " + current.playerGrabbedTime);

    // print("totTime: " + current.totTime +  " deathTime: " + current.deathTime + " time: " + current.time + " playerGrabbedTime: " + current.playerGrabbedTime);

    // calculated igt from variables
    // int ms = current.totTime * 1000 + current.deathTime * 1000 + current.time * 25 + current.playerGrabbedTime * 25;
    // int oldMs = old.totTime * 1000 + old.deathTime * 1000 + old.time * 25 + old.playerGrabbedTime * 25;


    //calculate time increasing only
    int ms = current.time * 25 + current.playerGrabbedTime * 25;
    int oldMs = old.time * 25 + old.playerGrabbedTime * 25;
    int diff = ms - oldMs;
    if(diff > 0) {
        vars.igt += diff;
    }
    return TimeSpan.FromMilliseconds(vars.igt);
}