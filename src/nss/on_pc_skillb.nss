#include "nwnx_events"
#include "nwnx_object"
#include "inc_horse"

void main()
{
    if (StringToInt(NWNX_Events_GetEventData("SKILL_ID")) == SKILL_PICK_POCKET)
    {
        if (GetIsMounted(OBJECT_SELF))
        {
            SendMessageToPC(OBJECT_SELF, "You cannot pickpocket while mounted.");
            NWNX_Events_SkipEvent();
        }
        else if (GetIsPC(NWNX_Object_StringToObject(NWNX_Events_GetEventData("TARGET_OBJECT_ID"))))
        {
            SendMessageToPC(OBJECT_SELF, "You cannot pickpocket players.");
            NWNX_Events_SkipEvent();
        }
    }
}
