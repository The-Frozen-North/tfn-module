#include "inc_debug"

// run this via dm_runscript

void main()
{
	if (GetIsDeveloper(OBJECT_SELF))
	{
		ExecuteScript("area_refresh", GetArea(OBJECT_SELF));
        SendDiscordLogMessage(GetName(OBJECT_SELF) + " forced a refresh for " + GetName(GetArea(OBJECT_SELF)));
	}
}