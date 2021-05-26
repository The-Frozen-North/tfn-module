int lcs_GetNextValidShieldModel(object oItem)
{
    int nCurrentAppearance = GetItemAppearance(oItem, ITEM_APPR_TYPE_WEAPON_MODEL, 0);
    int nBaseItemType = GetBaseItemType(oItem);
    if(nCurrentAppearance == 4)
    {
        //if(nBaseItemType == BASE_ITEM_SMALLSHIELD)
        //{
            return 1;
        //}
        //else
        //{
        //    return 11;
        //}
    }
    //else if(nCurrentAppearance == 15)
    //{
    //    return 1;
    //}
    else
    {
        return nCurrentAppearance + 1;
    }
}

int lcs_GetPreviousValidShieldModel(object oItem)
{
    int nCurrentAppearance = GetItemAppearance(oItem, ITEM_APPR_TYPE_WEAPON_MODEL, 0);
    int nBaseItemType = GetBaseItemType(oItem);
    //if(nCurrentAppearance == 11)
    //{
    //    return 4;
    //}
    if(nCurrentAppearance == 1)
    {
        //if(nBaseItemType == BASE_ITEM_SMALLSHIELD)
        //{
            return 4;
        //}
        //else
        //{
        //    return 15;
        //}
    }
    else
    {
        return nCurrentAppearance - 1;
    }
}

int lcs_GetNextValidShieldColor(object oItem)
{
    int nAppearance = GetItemAppearance(oItem, ITEM_APPR_TYPE_WEAPON_COLOR, 0);
    if(nAppearance == 3)
    {
        nAppearance = 1;
    }
    else
    {
        nAppearance = nAppearance + 1;
    }
    return nAppearance;
}

int lcs_GetPreviousValidShieldColor(object oItem)
{
    int nAppearance = GetItemAppearance(oItem, ITEM_APPR_TYPE_WEAPON_COLOR, 0);
    if(nAppearance == 1)
    {
            nAppearance = 3;
    }
    else
    {
        nAppearance = nAppearance - 1;
    }
    return nAppearance;
}

void lcs_ModifyandEquipNewShield(object oItem, int nAppearance)
{
    object oPC = GetItemPossessor(oItem);
    object oNewItem = CopyItemAndModify(oItem, ITEM_APPR_TYPE_WEAPON_MODEL, 0, nAppearance, TRUE);
    DestroyObject(oItem);
    SetCommandable(TRUE, oPC);
    AssignCommand(oPC, ActionEquipItem(oNewItem, INVENTORY_SLOT_LEFTHAND));
}

void lcs_ModifyColorandEquipNewShield(object oItem, int nAppearance)
{
    object oPC = GetItemPossessor(oItem);
    object oNewItem = CopyItemAndModify(oItem, ITEM_APPR_TYPE_WEAPON_COLOR, 0, nAppearance, TRUE);
    DestroyObject(oItem);
    SetCommandable(TRUE, oPC);
    AssignCommand(oPC, ActionEquipItem(oNewItem, INVENTORY_SLOT_LEFTHAND));
}
