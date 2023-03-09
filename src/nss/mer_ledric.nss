#include "inc_merchant"
#include "inc_rand_equip"

object TryCopyingGlovesOfTier(int nTier, int nUniqueChance)
{
    int i;
    for (i=0; i<10; i++)
    {
        //object GetTieredItemOfType(int nBaseItem, int nTier, int nUniqueChance=0)
        object oGloves = GetTieredItemOfType(BASE_ITEM_GLOVES, nTier, nUniqueChance);
        int bValid = 0;
        itemproperty ipTest = GetFirstItemProperty(oGloves);
        while (GetIsItemPropertyValid(ipTest))
        {
            int nItemPropertyType = GetItemPropertyType(ipTest);
            if (nItemPropertyType == ITEM_PROPERTY_ATTACK_BONUS || nItemPropertyType == ITEM_PROPERTY_DAMAGE_BONUS)
            {
                bValid = 1;
                break;
            }
            ipTest = GetNextItemProperty(oGloves);
        }
        if (bValid)
        {
            object oRet = CopyItem(oGloves, OBJECT_SELF, 1);
            return oRet;
        }
    }
    return OBJECT_INVALID;
}

void main()
{
    ApplyEWRAndInfiniteItems(OBJECT_SELF);

    CopyChest(OBJECT_SELF, "_MeleeCommonT1NonUnique", BASE_ITEM_QUARTERSTAFF, "", TRUE);
    CopyChest(OBJECT_SELF, "_MeleeCommonT2NonUnique", BASE_ITEM_QUARTERSTAFF, "", TRUE);
    CopyChest(OBJECT_SELF, "_MeleeCommonT3NonUnique", BASE_ITEM_QUARTERSTAFF, "", TRUE);

    CopyChest(OBJECT_SELF, "_MeleeRareT1NonUnique", BASE_ITEM_KAMA, "", TRUE);
    CopyChest(OBJECT_SELF, "_MeleeRareT2NonUnique", BASE_ITEM_KAMA, "", TRUE);
    CopyChest(OBJECT_SELF, "_MeleeRareT3NonUnique", BASE_ITEM_KAMA, "", TRUE);

    CopyChest(OBJECT_SELF, "_RangeRareT1NonUnique", BASE_ITEM_SHURIKEN, "", TRUE);
    CopyChest(OBJECT_SELF, "_RangeRareT2NonUnique", BASE_ITEM_SHURIKEN, "", TRUE);
    CopyChest(OBJECT_SELF, "_RangeRareT3NonUnique", BASE_ITEM_SHURIKEN, "", TRUE);
    
    int nRoll = d100();
    if (nRoll < 80)
    {
        TryCopyingGlovesOfTier(4, 100);
    }
    nRoll = d100();
    if (nRoll < 20)
    {
        TryCopyingGlovesOfTier(4, 100);
    }
    nRoll = d100();
    if (nRoll < 8)
    {
        TryCopyingGlovesOfTier(5, 100);
    }
}
