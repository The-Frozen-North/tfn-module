#include "x0_i0_spells"
#include "inc_itemevent"

void main()
{
    if (GetCurrentItemEventType() == ITEM_EVENT_ACTIVATED)
    {
        object oTarget = GetSpellTargetObject();
        int nSpellID = GetSpellId();
        DoPetrification(GetHitDice(OBJECT_SELF), OBJECT_SELF, oTarget, nSpellID, 8);
    }
}