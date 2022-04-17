#include "inc_xp"
//#include "inc_debug"

// cap how much gold is lost per level
const int GOLD_LOSS_PER_LEVEL_CAP = 75;
// factor of how much gold is loss based on net worth
// i.e. with a factor of 30 and worth of 1000, 1000 / 30 = 30 gold loss
const int GOLD_LOSS_FACTOR = 30;
// how much gold is loss initially
const int GOLD_INITIAL_LOSS = 10;
// factor of how much an item is worth
// i.e. with a factor of 3 and if the item is valued at 1200,
// 1200 / 3 = item is worth 400 gold
const int GOLD_ITEM_FACTOR = 3;
// if a item is valued over this, cap it. this is done after factoring the gold
// worth
const int GOLD_ITEM_VALUE_CAP = 3000;

int GetXPOnRespawn(object oPlayer)
{
    int nXP = GetXP(oPlayer);
    int nHD = GetLevelFromXP(nXP);
    int nPenalty = 30 * nHD;
// * You cannot lose a level by dying
    int nMin = ((nHD * (nHD - 1)) / 2) * 1000;

// you cannot be reduced below 1 xp
    if (nMin < 1) nMin = 1;

    int nNewXP = nXP - nPenalty;

    if (nNewXP < nMin) nNewXP = nMin;

    return nNewXP;
}

int GetItemGoldValue(object oItem)
{
    int nGold = GetGoldPieceValue(oItem);
    SendDebugMessage(GetName(oItem)+" value before "+IntToString(nGold));
    if (nGold >= GOLD_ITEM_FACTOR)
    {
        int nGoldValue = nGold / GOLD_ITEM_FACTOR;

        if (nGoldValue > GOLD_ITEM_VALUE_CAP)
            nGoldValue = GOLD_ITEM_VALUE_CAP;

        //SendDebugMessage(GetName(oItem)+" value "+IntToString(nGoldValue));

        return nGoldValue;
    }
    else
    {
        //SendDebugMessage(GetName(oItem)+" value 0");

        return 0;
    }
}

int GetGoldLossOnRespawn(object oPlayer)
{
    int nGold = GetGold(oPlayer);
    int nXP = GetXP(oPlayer);
    int nHD = GetLevelFromXP(nXP);

    object oItem = GetFirstItemInInventory(oPlayer);

    while (oItem != OBJECT_INVALID)
    {

        if (!GetPlotFlag(oItem))
            nGold = nGold + GetItemGoldValue(oItem);

        oItem = GetNextItemInInventory(oPlayer);
    }

    // 15 and higher are creature items
    int nSlot;
    object oSlotItem;
    for (nSlot = 0; nSlot < 14; ++nSlot)
    {
        oSlotItem = GetItemInSlot(nSlot, oPlayer);

        if (!GetPlotFlag(oSlotItem))
            nGold = nGold + GetItemGoldValue(oSlotItem);
    }

    int nGoldLoss = GOLD_INITIAL_LOSS;

    nGoldLoss = nGoldLoss + nGold/GOLD_LOSS_FACTOR;

    //SendDebugMessage("gold loss before cap"+IntToString(nGoldLoss));

    int nCap = nHD * GOLD_LOSS_PER_LEVEL_CAP;

    if (nGoldLoss > nCap)
        nGoldLoss = nCap;

    return nGoldLoss;
}

//void main() {}
