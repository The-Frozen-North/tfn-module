#include "inc_treasure"
#include "nwnx_events"

void main()
{
    // Boomerang items should not be able to decrease stack size
    if (GetItemHasItemProperty(OBJECT_SELF, ITEM_PROPERTY_BOOMERANG))
    {
        NWNX_Events_SkipEvent();
    }
}
