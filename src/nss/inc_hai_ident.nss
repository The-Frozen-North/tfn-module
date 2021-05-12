/*

    Henchman Inventory And Battle AI

*/

//
//void main() {}


int HenchGetMaxGPToIdentify()
{
    int nMyLore = GetSkillRank(SKILL_LORE, OBJECT_SELF); // henchman lore rank
    string sMaxValue = Get2DAString("SkillVsItemCost", "DeviceCostMax", nMyLore); // max value that the henchman can id
    int nMaxValue = StringToInt(sMaxValue);

    // * Handle overflow (November 2003 - BK)
    if (sMaxValue == "")
    {
        nMaxValue = 120000000;
    }
    return nMaxValue;
}

int HenchIdentifyItem(object oItem, int iMaxGPIdentify)
{
    if (GetIdentified(oItem))
    {
        return TRUE;
    }
    SetIdentified(oItem,TRUE);
    int nValue = GetGoldPieceValue(oItem) / GetNumStackedItems(oItem);
    if (nValue <= iMaxGPIdentify)
    {
        return TRUE;
    }
    SetIdentified(oItem, FALSE);
    return FALSE;
}

