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
        int nRefresh = GetLocalInt(OBJECT_SELF, "refresh");
        if (nRefresh >= 400)
        {
            SetLocalInt(OBJECT_SELF, "refresh", 400);
        }
    }
    
    string sScript = GetLocalString(OBJECT_SELF, "exit_script");
    if (sScript != "") { ExecuteScript(sScript); }
}
