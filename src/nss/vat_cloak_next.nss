//#include "lcs_helm_include"



int GetNextValidModel(object oItem)
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

int GetPreviousValidModel(object oItem)
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

void ModifyandEquipNew(object oItem, int nAppearance)
{
    object oPC = GetItemPossessor(oItem);
    object oNewItem = CopyItemAndModify(oItem, ITEM_APPR_TYPE_ARMOR_MODEL, 0, nAppearance);
    DestroyObject(oItem);
    SetCommandable(TRUE, oPC);
    AssignCommand(oPC, ActionEquipItem(oNewItem, INVENTORY_SLOT_CLOAK));
}

void main()
{
    object oPC = GetPCSpeaker();
    object oItem = GetItemInSlot(INVENTORY_SLOT_CLOAK, oPC);
    int iStyle = GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_MODEL, 0);
    SendMessageToPC(oPC, "Cloak style = " + IntToString(iStyle));

    object oNewItem = CopyItemAndModify(oItem, ITEM_APPR_TYPE_ARMOR_MODEL, 0, 11);
    DestroyObject(oItem);
    SetCommandable(TRUE, oPC);
    AssignCommand(oPC, ActionEquipItem(oNewItem, INVENTORY_SLOT_CLOAK));


    //int nNewLine = GetNextValidModel(oItem);

    //ModifyandEquipNew(oItem, nNewLine);
}

//0     ****
//1     Plain
//2     Arcane
//3     GreatCloak
//4     FineGreatCl
//5     Hooded
//6     Fancy
//7     Elegant
//8     Elvan
//9     Wizard
//10    Jeweled
//11    Blackgd_Cyric
//12    Paladin_Helm
//13    Champion_Torm
//14    DragonKnight
