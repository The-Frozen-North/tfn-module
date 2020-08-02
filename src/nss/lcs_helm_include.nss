int lcs_GetNextValidHelmModel(object oItem)
{
    int nCurrentAppearance = GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_MODEL, 0);

    if(nCurrentAppearance == 32)
    {
        return 1;
    }
    else
    {
        return nCurrentAppearance + 1;
    }
}

int lcs_GetPreviousValidHelmModel(object oItem)
{
    int nCurrentAppearance = GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_MODEL, 0);

    if(nCurrentAppearance == 1)
    {
        return 32;
    }
    else
    {
        return nCurrentAppearance - 1;
    }
}

int lcs_GetNextValidHelmColor(object oItem, int nPart)
{
    int nAppearance = GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, nPart);
    if(nAppearance == 63)
    {
        nAppearance = 0;
    }
    else
    {
        nAppearance = nAppearance + 1;
    }
    return nAppearance;
}

int lcs_GetPreviousValidHelmColor(object oItem, int nPart)
{
    int nAppearance = GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, nPart);
    if(nAppearance == 0)
    {
        nAppearance = 63;
    }
    else
    {
        nAppearance = nAppearance - 1;
    }
    return nAppearance;
}

void lcs_ModifyandEquipNewHelm(object oItem, int nAppearance)
{
    object oPC = GetItemPossessor(oItem);
    object oNewItem = CopyItemAndModify(oItem, ITEM_APPR_TYPE_ARMOR_MODEL, 0, nAppearance);
    DestroyObject(oItem);
    SetCommandable(TRUE, oPC);
    AssignCommand(oPC, ActionEquipItem(oNewItem, INVENTORY_SLOT_HEAD));
}

void lcs_ModifyColorandEquipNewHelm(object oItem, int nPart, int nAppearance)
{
    object oPC = GetItemPossessor(oItem);
    object oNewItem = CopyItemAndModify(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, nPart, nAppearance);
    DestroyObject(oItem);
    SetCommandable(TRUE, oPC);
    AssignCommand(oPC, ActionEquipItem(oNewItem, INVENTORY_SLOT_HEAD));
}
