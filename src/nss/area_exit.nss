#include "inc_persist"
#include "inc_restxp"

void main()
{
    object oLeaver = GetExitingObject();
    if (GetIsPC(oLeaver))
    {
        ExportMinimap(oLeaver);
        if (PlayerGetsRestedXPInArea(oLeaver, OBJECT_SELF))
        {
            SendRestedXPNotifierToPC(oLeaver);
        }
    }
}
