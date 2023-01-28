#include "inc_debug"
void main()
{
    object oDev = OBJECT_SELF;
    if (!GetIsDevServer())
    {
        SendMessageToAllDMs(GetName(oDev) + " tried to run dev_revealmap, but the server is not in developer mode");
        return;
    }

    if (!GetIsDeveloper(oDev))
    {
        SendMessageToAllDMs(GetName(oDev) + " tried to run dev_revealmap, but they are not a developer");
        return;
    }
    SendMessageToAllDMs(GetName(oDev) + " is running dev_revealmap in area: " + GetName(GetArea(oDev)) + ", tag: " + GetTag(GetArea(oDev)));
    SendDiscordLogMessage(GetName(oDev) + " used the developer script to fully explore " + GetName(GetArea(oDev)) + ", tag: " + GetTag(GetArea(oDev)));
	ExploreAreaForPlayer(GetArea(oDev), oDev);
}

