// on stealth after
#include "nwnx_events"
#include "inc_nwnx"

void main()
{
    if (GetHasFeat(FEAT_HIDE_IN_PLAIN_SIGHT, OBJECT_SELF))
    {
        FloatingTextStringOnCreature("*You have successfully Hid in Plain Sight*", OBJECT_SELF);

// Remove the feat or item property bonus feat
        object oSkin = GetItemInSlot(INVENTORY_SLOT_CARMOUR, OBJECT_SELF);
        if (GetLevelByClass(CLASS_TYPE_SHADOWDANCER, OBJECT_SELF) > 0)
        {
            NWNX_Creature_RemoveFeat(OBJECT_SELF, FEAT_HIDE_IN_PLAIN_SIGHT);
        }
        else if (GetLevelByClass(CLASS_TYPE_SHIFTER, OBJECT_SELF) >= 7 && GetResRef(oSkin) == "x2_it_koboldcomm")
        {
            itemproperty ipItemProperty = GetFirstItemProperty(oSkin);
            itemproperty ipBonusFeatHiPS = ItemPropertyBonusFeat(FEAT_HIDE_IN_PLAIN_SIGHT);
            while (GetIsItemPropertyValid(ipItemProperty))
            {
                if (ipItemProperty == ipBonusFeatHiPS)
                {
                    RemoveItemProperty(oSkin, ipItemProperty);
                    break;
                }

                ipItemProperty = GetNextItemProperty(oSkin);
            }
        }

        SetLocalInt(OBJECT_SELF, "hips_cd", 1);
        DelayCommand(10.0 - IntToFloat(GetLevelByClass(CLASS_TYPE_SHADOWDANCER, OBJECT_SELF)), GiveHiPSFeatSafely(OBJECT_SELF));
    }
    else if (GetLocalInt(OBJECT_SELF, "hips_cd") == 1)
    {
        FloatingTextStringOnCreature("*You must wait longer before you can Hide in Plain Sight*", OBJECT_SELF);
    }
}
