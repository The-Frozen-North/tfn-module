#include "nwnx_events"
#include "inc_horse"

void main()
{
// 65535 means no feat was used. allow spells from feats while mounted
    if (GetIsMounted(OBJECT_SELF) && GetIsInCombat(OBJECT_SELF) && StringToInt(NWNX_Events_GetEventData("FEAT")) == 65535)
    {
        SendMessageToPC(OBJECT_SELF, "You cannot cast spells in combat while mounted.");
        NWNX_Events_SkipEvent();
    }
}
