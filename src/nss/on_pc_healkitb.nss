#include "nwnx_events"

void main()
{
    object oTarget = StringToObject(NWNX_Events_GetEventData("TARGET_OBJECT_ID"));
    if (GetIsInCombat(oTarget))
    {
        if (GetLocalInt(oTarget, "healers_kit_cd") == 1)
        {
            SendMessageToPC(OBJECT_SELF, "Unable to heal. The target is currently in combat and has had a healer's kit applied recently.");
            NWNX_Events_SkipEvent();
        }
    }
}
