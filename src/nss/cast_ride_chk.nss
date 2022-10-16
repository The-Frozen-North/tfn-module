#include "nwnx_events"
#include "inc_horse"

void main()
{
// check if the event item object is invalid so we can allow spells from items
    if (GetIsMounted(OBJECT_SELF) && GetIsInCombat(OBJECT_SELF) && !GetIsObjectValid(StringToObject(NWNX_Events_GetEventData("ITEM_OBJECT_ID"))))
    {
        // Dirty hardcoding: Prevent paladin's mounting feat from being blocked by this
        if (StringToInt(NWNX_Events_GetEventData("SPELL_ID")) != 818)
        {
            FloatingTextStringOnCreature("You cannot cast spells in combat while mounted.", OBJECT_SELF, FALSE);
            NWNX_Events_SkipEvent();
        }
    }
}
