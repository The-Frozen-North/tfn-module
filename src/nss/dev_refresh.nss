#include "inc_debug"

// run this via dm_runscript

void main()
{
	if (GetIsDeveloper(OBJECT_SELF))
	{
        if (GetLocalString(GetArea(OBJECT_SELF), "enter_script") != "")
        {
            location lOld = GetLocation(OBJECT_SELF);
            JumpToLocation(GetLocation(GetWaypointByTag("RESPAWN_NEVERWINTER")));
            DelayCommand(6.0, JumpToLocation(lOld));
            SendMessageToPC(OBJECT_SELF, "Area has an onenter script. You are being taken to Neverwinter to let that trigger.");
        }
		ExecuteScript("area_refresh", GetArea(OBJECT_SELF));
        SendDiscordLogMessage(GetName(OBJECT_SELF) + " forced a refresh for " + GetName(GetArea(OBJECT_SELF)));
	}
}