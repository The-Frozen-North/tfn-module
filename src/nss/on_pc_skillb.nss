#include "nwnx_events"
#include "inc_horse"

void main()
{
    if (StringToInt(NWNX_Events_GetEventData("SKILL_ID")) == SKILL_PICK_POCKET)
    {
        object oTarget = StringToObject(NWNX_Events_GetEventData("TARGET_OBJECT_ID"));

        if (GetIsMounted(OBJECT_SELF))
        {
            SendMessageToPC(OBJECT_SELF, "You cannot pickpocket while mounted.");
            NWNX_Events_SkipEvent();
        }
        else if (GetIsPC(oTarget))
        {
            SendMessageToPC(OBJECT_SELF, "You cannot pickpocket players.");
            NWNX_Events_SkipEvent();
        }
        else if (GetIsDead(oTarget))
        {
            SendMessageToPC(OBJECT_SELF, "You cannot pickpocket dead creatures.");
            NWNX_Events_SkipEvent();
        }
        else if (GetStringLeft(GetResRef(oTarget), 3) == "hen" && GetMaster(oTarget) != OBJECT_SELF)
        {
            SendMessageToPC(OBJECT_SELF, "You cannot pickpocket other player's henchman.");
            NWNX_Events_SkipEvent();
        }
        WriteTimestampedLogEntry(GetName(OBJECT_SELF) + " attempted pickpocket on " + GetName(oTarget));
    }
}
