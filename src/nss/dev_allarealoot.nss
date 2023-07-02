#include "inc_debug"
// run via dm_runscript
// Automatically run dev_arealootval on every area with a CR set in the module
// which outputs a lot of stuff to the log about how many items you might find and their value
// Takes a while to run, most likely enough time to go make a warm beverage of your choosing

// tools/areavaluestocsv.py processes the garbled mess of log output into a csv which is a little more friendly


// this script may take a while to run, spot check certain areas only
// note, the global column won't be that accurate if this is the case
const int LIMITED_SAMPLE_SIZE = 0;

void RunOnArea(object oDev, json jAreas, int nState=0)
{
    int nLength = JsonGetLength(jAreas);
    if (nLength == 0)
    {
        SendMessageToPC(oDev, "DONE.");
        DeleteLocalJson(GetModule(), "dev_allarealoot_areas");
        return;
    }
    object oArea = StringToObject(JsonGetString(JsonArrayGet(jAreas, 0)));
    SetLocalJson(GetModule(), "dev_allarealoot_areas", jAreas);
    if (!GetIsObjectValid(oDev) && nState != 1)
    {
        WriteTimestampedLogEntry("PC crashed. RIP.");
        if (nState >= 2)
        {
            ExecuteScript("area_refresh", oArea);
        }
        return;
    }
    // State 0: jump PC to area
    // State 1: wait for PC to load in
    // State 2: run dev_arealootval
    // State 3: wait 12 seconds
    // State 4: jump to next area
    if (nState == 0)
    {
        object oTest = GetFirstObjectInArea(oArea);
        while (GetIsObjectValid(oTest))
        {
            if (!GetIsDead(oTest) && GetIsObjectValid(oTest) && GetObjectType(oTest) == OBJECT_TYPE_CREATURE)
            {
                break;
            }
            oTest = GetNextObjectInArea(oArea);
        }
        if (GetIsObjectValid(oTest))
        {
            location lTarget = GetLocation(oTest);
            JumpToLocation(lTarget);
            WriteTimestampedLogEntry("Jumping to: " + GetName(oArea));
            nState = 1;
        }
        else
        {
            nState = 4;
        }
    }
    if (nState == 1)
    {
        if (GetArea(oDev) != oArea)
        {
            DelayCommand(2.0, RunOnArea(oDev, jAreas, nState));
            return;
        }
        nState = 2;
    }
    if (nState == 2)
    {
        FloatingTextStringOnCreature("There are " + IntToString(nLength) + " areas left in the queue.", oDev);
        ExecuteScript("dev_arealootval", oDev);
        nState = 3;
    }
    if (nState == 3)
    {
        if (!GetLocalInt(oDev, "dev_arealoot_done"))
        {
            DelayCommand(1.0, RunOnArea(oDev, jAreas, nState));
            return;
        }
        nState = 4;
    }
    if (nState == 4)
    {
        jAreas = JsonArrayDel(jAreas, 0);
        RunOnArea(oDev, jAreas, 0);
    }
}

void main()
{
    object oDev = OBJECT_SELF;
    if (!GetIsDevServer())
    {
        SendMessageToAllDMs(GetName(oDev) + " tried to run dev_allarealoot, but the server is not in developer mode");
        return;
    }

    if (!GetIsDeveloper(oDev))
    {
        SendMessageToAllDMs(GetName(oDev) + " tried to run dev_allarealoot, but they are not a developer");
        return;
    }
    SendMessageToAllDMs(GetName(oDev) + " is running dev_allarealoot");

    json jAreas = JsonArray();
    object oArea = GetFirstArea();
    while (GetIsObjectValid(oArea))
    {
        // only count areas with a CR variable, as this determines loot
        // loot is still possible even without that variable but should be considered a bug
        if (GetLocalInt(oArea, "cr") > 0)
        {
            int bAddArea = FALSE;

            if (LIMITED_SAMPLE_SIZE)
            {
                string sResRef = GetResRef(oArea);
                if (sResRef == "ud_behold1" || // beholder dungeon
                    sResRef == "ud_behold2" ||
                    // sResRef == "ud_behold3" ||
                    sResRef == "ud_east_form" || // formian dungeon
                    sResRef == "ud_central" || // underdark exploration areas
                    sResRef == "ud_east" ||
                    sResRef == "beg_crypts" || // great graveyard and dungeons
                    sResRef == "beg_grave" ||
                    sResRef == "beg_warrens" ||
                    sResRef == "charwood_jhareg" || // castle jhareg
                    sResRef == "charwood_jharegk" ||
                    sResRef == "charwood_jharegq" ||
                    sResRef == "hr_north1" || // high roads
                    // sResRef == "hr_north2" ||
                    sResRef == "hr_south1" ||
                    // sResRef == "hr_south2" ||
                    sResRef == "mere_lizard0" || // lizardfolk lair
                    sResRef == "mere_lizard1" ||
                    sResRef == "mere_lizard2" ||
                    sResRef == "helm1" || // helm's hold
                    sResRef == "helm2" ||
                    sResRef == "helm3" ||
                    sResRef == "goblin0" || // goblin dungeon
                    sResRef == "goblin1" ||
                    sResRef == "goblin2" ||
                    sResRef == "banditcamp")
                    {
                        bAddArea = TRUE;
                    }

            }
            else
            {
                bAddArea = TRUE;
            }

            if (bAddArea)
            {
                jAreas = JsonArrayInsert(jAreas, JsonString(ObjectToString(oArea)));
            }
        }
        oArea = GetNextArea();
    }
    json jSaved = GetLocalJson(GetModule(), "dev_allarealoot_areas");
    if (jSaved != JsonNull())
    {
        jAreas = jSaved;
    }
    RunOnArea(oDev, jAreas, 0);

}

