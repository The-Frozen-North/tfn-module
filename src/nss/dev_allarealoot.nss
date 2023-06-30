#include "inc_debug"
// run via dm_runscript
// Automatically run dev_arealootval on every area with a CR set in the module
// which outputs a lot of stuff to the log about how many items you might find and their value
// Takes a while to run, most likely enough time to go make a warm beverage of your choosing


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
    if (!GetIsObjectValid(oDev) && nState != 1)
    {
        WriteTimestampedLogEntry("PC crashed. RIP.");
        SetLocalJson(GetModule(), "dev_allarealoot_areas", jAreas);
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
        SetLocalInt(oDev, "dev_allarealoot_wait", 1);
        ExecuteScript("dev_arealootval", oDev);
        DelayCommand(12.0, DeleteLocalInt(oDev, "dev_allarealoot_wait"));
        nState = 3;
    }
    if (nState == 3)
    {
        if (GetLocalInt(oDev, "dev_allarealoot_wait"))
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
		if (GetLocalInt(oArea, "cr") > 0)
		{
			jAreas = JsonArrayInsert(jAreas, JsonString(ObjectToString(oArea)));
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

