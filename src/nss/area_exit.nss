#include "inc_persist"
#include "inc_restxp"
#include "inc_quest"

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
        // Unload texture overrides
        string sScript = GetLocalString(OBJECT_SELF, "texoverride_script");
        if (sScript != "")
        {
            SetScriptParam("pc", ObjectToString(oLeaver));
            SetScriptParam("action", "unload");
            ExecuteScript(sScript, OBJECT_SELF);
        }
        // Unset any questgiver override hilites
        ClearAllQuestgiverHighlightsInAreaForPC(OBJECT_SELF, oLeaver);
    }
    
    string sScript = GetLocalString(OBJECT_SELF, "exit_script");
    if (sScript != "") { ExecuteScript(sScript); }
}
