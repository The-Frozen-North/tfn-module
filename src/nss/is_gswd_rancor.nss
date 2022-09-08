#include "x2_inc_itemprop"

// Rancor (greatsword)
// On hit grant EB+2 for 1 round
void main()
{
    object oTarget = GetSpellTargetObject();
    if (GetIsObjectValid(oTarget))
    {
        object oWpn = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, OBJECT_SELF);
        if (GetIsObjectValid(oWpn))
        {
            // it only lasts 1 round so it shouldn't look too ugly with stacking
            // if it didn't ignore existing props it would remove buffs like GMW
            int nReplacePolicy = X2_IP_ADDPROP_POLICY_IGNORE_EXISTING;

            itemproperty ipEB = ItemPropertyEnhancementBonus(2);
            IPSafeAddItemProperty(oWpn, ipEB, RoundsToSeconds(1), nReplacePolicy);
        }
    }
}
