// run this via dm_runscript
// It will message all DMs with the average value of an item from each chest

string TypeIndexToString(int nTypeIndex)
{
    string sType = "INVALID";

    switch(nTypeIndex)
    {
       case 0: sType = "Misc"; break;
       case 1: sType = "Scrolls"; break;
       case 2: sType = "Melee"; break;
       case 3: sType = "Armor"; break;
       case 4: sType = "Range"; break;
       case 5: sType = "Apparel"; break;
       case 6: sType = "Potions"; break;
    }
    return sType;
}

int ItemTypeHasUniques(string sType)
{
    if (sType == "Range" || sType == "Weapon" || sType == "Armor" || sType == "Melee" || sType == "Potions")
    {
        return 1;
    }
    return 0;
}

string RarityIndexToString(int nRarityIndex)
{
    switch (nRarityIndex)
    {
        case 0: return "Common"; break;
        case 1: return "Uncommon"; break;
        case 2: return "Rare"; break;
    }
    return "INVALID";
}

int GetIdentifiedItemCost(object oItem)
{
    int nState = GetIdentified(oItem);
    if (!nState)
    {
        SetIdentified(oItem, TRUE);
    }
    int nVal = GetGoldPieceValue(oItem);
    SetIdentified(oItem, nState);
    return nVal;    
}

int ItemTypeHasRarities(string sType)
{
    if (sType == "Scrolls" || sType == "Misc" || sType == "Potions")
    {
        return 0;
    }
    return 1;
}

void main()
{
    int nTypeIndex;
    int nRarityIndex;
    int nTier = 1;
    int nUniquenessIndex;
    for (nTypeIndex = 0; nTypeIndex <= 6; nTypeIndex++)
    {
        string sType = TypeIndexToString(nTypeIndex);
        for (nTier=1; nTier<=5; nTier++)
        {
            string sTier = "T" + IntToString(nTier);
            for (nUniquenessIndex=0; nUniquenessIndex < 2; nUniquenessIndex++)
            {
                //if (nUniquenessIndex == 1 && !ItemTypeHasUniques(sType))
                //{
                //    continue;
                //}
                string sNonUnique = nUniquenessIndex ? "" : "NonUnique";
                for (nRarityIndex=0; nRarityIndex <= 2; nRarityIndex++)
                {
                    string sRarity = RarityIndexToString(nRarityIndex);
                    if (!ItemTypeHasRarities(sType))
                    {
                        sRarity = "";
                    }
                    string sTag = "_"+sType+sRarity+sTier+sNonUnique;
                    object oChest = GetObjectByTag(sTag);
                    if (!GetIsObjectValid(oChest))
                    {
                        SendMessageToAllDMs("Chest not valid: " + sTag);
                    }
                    else
                    {
                        int nNumObjects = StringToInt(GetDescription(oChest));
                        int nRealObjCount = 0;
                        int nGoldTotal = 0;
                        object oTest = GetFirstItemInInventory(oChest);
                        while (GetIsObjectValid(oTest))
                        {
                            int nBaseType = GetBaseItemType(oTest);
                            if (nBaseType == BASE_ITEM_THROWINGAXE || nBaseType == BASE_ITEM_DART || nBaseType == BASE_ITEM_SHURIKEN || nBaseType == BASE_ITEM_ARROW || nBaseType == BASE_ITEM_BULLET || nBaseType == BASE_ITEM_BOLT)
                            {
                                int nOneItemGold = GetIdentifiedItemCost(oTest)/GetItemStackSize(oTest);
                                // generation sets stack size to d45 = expected 22.5
                                float fStackMultiplier = 22.5/IntToFloat(GetItemStackSize(oTest));
                                int nCost = FloatToInt(IntToFloat(GetIdentifiedItemCost(oTest)) * fStackMultiplier);
                                nGoldTotal += nCost;
                                SendMessageToAllDMs("Stackable ammo " + GetResRef(oTest) + " has expected value " + IntToString(nCost));
                            }
                            else
                            {
                                nGoldTotal += GetIdentifiedItemCost(oTest);
                            }
                            nRealObjCount++;
                            oTest = GetNextItemInInventory(oChest);
                        }
                        if (nRealObjCount != nNumObjects)
                        {
                            SendMessageToAllDMs("WARNING: Chest " + sTag + " has item count mismatch: stated " + IntToString(nNumObjects) + " vs real " + IntToString(nRealObjCount));
                        }
                        SendMessageToAllDMs("Chest: " + sTag + " avg item value: " + IntToString(nGoldTotal/nRealObjCount));
                        if (!ItemTypeHasRarities(sType))
                        {
                            break;
                        }
                    }
                }

            }
        }
    }


}
