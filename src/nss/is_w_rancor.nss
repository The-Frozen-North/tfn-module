#include "x2_inc_itemprop"
#include "inc_itemevent"

// Rancor (greatsword)
// On hit grant EB+2 for 1 round
void main()
{
    if (GetCurrentItemEventType() == ITEM_EVENT_ACTIVATED)
    {
        object oTarget = GetSpellTargetObject();
        if (GetIsObjectValid(oTarget))
        {
            object oWpn = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, OBJECT_SELF);
            if (GetIsObjectValid(oWpn))
            {
                // temporary EB IPs will be removed (e.g. from GMW)... but why use GMW with this anyway?
                itemproperty ipEB = ItemPropertyEnhancementBonus(2);
                IPSafeAddItemProperty(oWpn, ipEB, RoundsToSeconds(1));
            }
        }
    }
}
