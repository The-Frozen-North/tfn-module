#include "nwnx_events"
#include "inc_horse"

void main()
{
// check if the event item object is invalid so we can allow spells from items
    if (GetIsMounted(OBJECT_SELF) && GetIsInCombat(OBJECT_SELF) && !GetIsObjectValid(StringToObject(NWNX_Events_GetEventData("ITEM_OBJECT_ID"))))
    {
        SendMessageToPC(OBJECT_SELF, "You cannot cast spells in combat while mounted.");
        NWNX_Events_SkipEvent();
    }
}
