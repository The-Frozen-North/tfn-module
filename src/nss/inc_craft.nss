//#include "inc_debug"

const int BASE_CRAFT_DC = 10;

const int CRAFT_GOLD_STEP_DC = 150;

int DetermineAmmoCraftingCost(object oAmmo)
{
    int nValue = GetGoldPieceValue(oAmmo);

    int nBaseItemType = GetBaseItemType(oAmmo);

    if (nBaseItemType == BASE_ITEM_BOLT || nBaseItemType == BASE_ITEM_BULLET || nBaseItemType == BASE_ITEM_ARROW)
    {
        nValue = nValue/80;
    }
    else
    {
        nValue = nValue/50;
    }

    return nValue;
}

int DetermineAmmoCraftingDC(object oAmmo)
{
    int nValue = GetGoldPieceValue(oAmmo);

    int nDC;
    for (nDC = 0; nDC < 21; nDC++)
    {
        //SendDebugMessage("nDC: "+IntToString(nDC)+" nValue: "+IntToString(nValue)+" DeviceCostMax: "+Get2DAString("skillvsitemcost", "DeviceCostMax", nDC));
        if (nValue < StringToInt(Get2DAString("skillvsitemcost", "DeviceCostMax", nDC)))
            break;
    }

    if (nDC > 2)
        nDC = nDC/2;

    return BASE_CRAFT_DC + nDC;
}

//void main() {}
