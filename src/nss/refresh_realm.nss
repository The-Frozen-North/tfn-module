// See also: realm_druiddeath.
// This is undoing a lot of what that does
#include "nwnx_creature"
#include "inc_debug"


void main()
{
    SetFogColor(FOG_TYPE_ALL, FOG_COLOR_RED, OBJECT_SELF);
    object oSpirit = GetObjectByTag("realm_spirit");
    int nDefeated = GetLocalInt(OBJECT_SELF, "pacified");
    
    if (nDefeated)
    {
        SendDebugMessage("refresh_realm: spirit = " + GetName(oSpirit));
        int nFaction = GetLocalInt(oSpirit, "original_faction");
        NWNX_Creature_SetFaction(oSpirit, nFaction);
        DeleteLocalString(oSpirit, "heartbeat_script");
        SetPlotFlag(oSpirit, FALSE);
        SetLocalInt(oSpirit, "defeated_webhook", 1);
        DeleteLocalInt(OBJECT_SELF, "pacified");
    }
    
}
