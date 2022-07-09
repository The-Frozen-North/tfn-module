#include "inc_debug"
// run via dm_runscript
// Automatically run dev_arealootval on every area with a CR set in the module
// which outputs a lot of stuff to the log about how many items you might find and their value
// Takes a while to run, most likely enough time to go make a warm beverage of your choosing


void RunOnArea(object oDev, object oArea)
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
        DelayCommand(10.0f, ExecuteScript("dev_arealootval", oDev));
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

	float fDelay = 20.0*nAreaIndex;
	object oArea = GetFirstArea();
	while (GetIsObjectValid(oArea))
	{
		if (GetLocalInt(oArea, "cr") > 0)
		{
			fDelay = 20.0*nAreaIndex;
			nAreaIndex++;
			DelayCommand(fDelay, RunOnArea(oDev, oArea));
		}
		oArea = GetNextArea();
	}
	
	DelayCommand(11.0f, SendMessageToPC(oDev, "There are " + IntToString(nAreaIndex+1) + " areas to jump through, taking " + FloatToString(fDelay) + " seconds. Sit back and enjoy the ride."));
	DelayCommand(18.0f, SendMessageToPC(oDev, "There are " + IntToString(nAreaIndex+1) + " areas to jump through, taking " + FloatToString(fDelay) + " seconds. Sit back and enjoy the ride."));
}

