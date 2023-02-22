#include "inc_ai_combat"
#include "inc_ai_event"

void main()
{
    SignalEvent(OBJECT_SELF, EventUserDefined(GS_EV_ON_COMBAT_ROUND_END));
    //if (GetArea(OBJECT_SELF) == GetArea(GetFirstPC())) SendMessageToPC(GetFirstPC(), GetName(OBJECT_SELF) + " combat round ends");

    if (GetLocalInt(OBJECT_SELF, "combat") == 0)
        SetLocalInt(OBJECT_SELF, "combat", 1);

    gsCBDetermineCombatRound();
    
    string sScript = GetLocalString(OBJECT_SELF, "combatround_script");
    if (sScript != "") ExecuteScript(sScript);
}

