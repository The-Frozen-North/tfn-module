// on stealth after
#include "nwnx_events"
#include "inc_nwnx"
#include "inc_sqlite_time"

void main()
{
    if (GetHasFeat(FEAT_HIDE_IN_PLAIN_SIGHT, OBJECT_SELF))
    {
        FloatingTextStringOnCreature("*You have successfully Hid in Plain Sight*", OBJECT_SELF, FALSE);

// Remove the feat or item property bonus feat
        object oSkin = GetItemInSlot(INVENTORY_SLOT_CARMOUR, OBJECT_SELF);
        if (GetLevelByClass(CLASS_TYPE_SHADOWDANCER, OBJECT_SELF) > 0)
        {
            NWNX_Creature_RemoveFeat(OBJECT_SELF, FEAT_HIDE_IN_PLAIN_SIGHT);
        }
        else if (GetLevelByClass(CLASS_TYPE_SHIFTER, OBJECT_SELF) >= 7 && GetResRef(oSkin) == "x2_it_koboldcomm")
        {      
            SendDebugMessage("Shifter HiPS");
            itemproperty ipItemProperty = GetFirstItemProperty(oSkin);
            while (GetIsItemPropertyValid(ipItemProperty))
            {
                if (GetItemPropertyType(ipItemProperty) == ITEM_PROPERTY_BONUS_FEAT)
                {
                    int nIPRPBonusFeat = GetItemPropertySubType(ipItemProperty);
                    if (nIPRPBonusFeat == IP_CONST_FEAT_HIDE_IN_PLAIN_SIGHT)
                    {
                        SendDebugMessage("... found itemprop");
                        RemoveItemProperty(oSkin, ipItemProperty);
                        break;
                    }
                }
                ipItemProperty = GetNextItemProperty(oSkin);
            }
        }
        int nCD = 10 - GetLevelByClass(CLASS_TYPE_SHADOWDANCER, OBJECT_SELF);
        
        SetLocalInt(OBJECT_SELF, "hips_cd", SQLite_GetTimeStamp()+nCD);
        DelayCommand(IntToFloat(nCD), GiveHiPSFeatSafely(OBJECT_SELF));
    }
    else if (GetLocalInt(OBJECT_SELF, "hips_cd"))
    {
        int nNow = SQLite_GetTimeStamp();
        int nDiff = GetLocalInt(OBJECT_SELF, "hips_cd") - nNow;
        if (nDiff <= 0)
        {
            FloatingTextStringOnCreature("*You must wait slightly longer before you can Hide in Plain Sight*", OBJECT_SELF, FALSE);
        }
        else
        {
            FloatingTextStringOnCreature("*You must wait about " + IntToString(nDiff) + " seconds before you can Hide in Plain Sight*", OBJECT_SELF, FALSE);
        }
    }
}
