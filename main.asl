state("RainWorld", "v1.9 Steam") {
        // i don't know the syntax for almost all of this currently so we have a bunch of long addresses 
        // int rainWorld : "mono-2.0-bdwgc.dll", 0x003A820C, 0x50, 0xC, 0x308, 0x20, 0xE8, 0x280, 0x100;
        // string32 room : new MemoryWatcher<int>(new DeepPointer((IntPtr)current.rainWorld, 0xC, 0xC, 0x1C, 0x10, 0x8, 0x10, 0xC, 0xC));




        string32 room : "mono-2.0-bdwgc.dll", 0x003A820C, 0x50, 0xC, 0x308, 0x20, 0xE8, 0x280, 0x100, 0xC, 0xC, 0x1C, 0x10, 0x8, 0x10, 0xC, 0xC;

        int totTime : "mono-2.0-bdwgc.dll", 0x003A820C, 0x50, 0xC, 0x308, 0x20, 0xE8, 0x280, 0x100, 0xC, 0xC, 0x4C, 0x20, 0x88;
        int deathTime : "mono-2.0-bdwgc.dll", 0x003A820C, 0x50, 0xC, 0x308, 0x20, 0xE8, 0x280, 0x100, 0xC, 0xC, 0x4C, 0x20, 0x3C, 0x80;
        int time : "mono-2.0-bdwgc.dll", 0x003A820C, 0x50, 0xC, 0x308, 0x20, 0xE8, 0x280, 0x100, 0xC, 0xC, 0x4C, 0x40, 0x10, 0x28;
        int playerGrabbedTime : "mono-2.0-bdwgc.dll", 0x003A820C, 0x50, 0xC, 0x308, 0x20, 0xE8, 0x280, 0x100, 0xC, 0xC, 0x4C, 0x40, 0x10, 0x2c;
    }

init {
}

split {
    if(current.room != old.room) {
        print(current.room);
    }
}

isLoading {
    //only use igt, don't interpolate
    return true;
}

gameTime {
    //actual igt from HUD, this pointer only works with certain user settings and is rounded to nearest second
    //return new DeepPointer("mono-2.0-bdwgc.dll", 0x003A820C, 0x50, 0xC, 0x308, 0x20, 0xE8, 0x280, 0x100, 0xC, 0xC, 0x1C, 0x10, 0x104, 0x10, 0x8, 0x30, 0x30).Deref<TimeSpan>(game);

    //calculated igt from variables
    int ms = current.totTime * 1000 + current.deathTime * 1000 + current.time * 25 + current.playerGrabbedTime * 25;
    return TimeSpan.FromMilliseconds(ms);
}