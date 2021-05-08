#include "inc_treasure"
#include "inc_gold"

// Use 256 for all item types.
void CopyChest(object oTarget, string sChest, int nBaseItemType = BASE_ITEM_INVALID, string sDescriptionFilter = "", int bInfinite = FALSE);

// Adds enchanted weight reduction, and infinite if applicable
void ApplyEWRAndInfiniteItems(object oTarget);

void CopyChest(object oTarget, string sChest, int nBaseItemType = BASE_ITEM_INVALID, string sDescriptionFilter = "", int bInfinite = FALSE)
{
    object oChest = GetObjectByTag(sChest);

    if (!GetIsObjectValid(oChest)) return;

    object oNewItem;

    int bMatchesDescription;

    object oItem = GetFirstItemInInventory(oChest);
    while ( oItem != OBJECT_INVALID ) {

        if (sDescriptionFilter != "")
        {
            if (FindSubString(GetDescription(oItem), sDescriptionFilter) > -1)
            {
                bMatchesDescription = TRUE;
            }
            else
            {
                bMatchesDescription = FALSE;
            }
        }
        else
        {
            bMatchesDescription = TRUE;
        }

        if (bMatchesDescription && (nBaseItemType == BASE_ITEM_INVALID || nBaseItemType == GetBaseItemType(oItem)))
        {
            oNewItem = CopyItem(oItem, oTarget, TRUE);

            switch (GetBaseItemType(oNewItem))
            {
                case BASE_ITEM_ARROW:
                case BASE_ITEM_BOLT:
                case BASE_ITEM_BULLET:
                case BASE_ITEM_DART:
                case BASE_ITEM_THROWINGAXE:
                case BASE_ITEM_SHURIKEN: SetItemStackSize(oNewItem, 99); break;
                default: SetItemStackSize(oNewItem, 1); break;
            }

            SetInfiniteFlag(oNewItem, bInfinite);
        }

        oItem = GetNextItemInInventory(oChest);
    }
}

void ApplyEWRAndInfiniteItems(object oTarget)
{
    object oItem = GetFirstItemInInventory(oTarget);
    while (GetIsObjectValid(oItem))
    {
        InitializeItem(oItem);
        SetInfiniteFlag(oItem, TRUE);
        oItem = GetNextItemInInventory(oTarget);
    }
}

void OpenMerchant(object oMerchant, object oStore, object oPC)
{

// stop if store doesn't exist
    if (!GetIsObjectValid(oStore))
    {
        SendDebugMessage("Store doesn't exist: "+GetName(oMerchant));
        return;
    }

// PC? don't do it
    if (GetIsPC(oMerchant)) return;

    object oPC = GetLastSpeaker();

    int nCap = MERCHANT_MODIFIER_CAP;

    int nPCAppraise = GetSkillRank(SKILL_APPRAISE, oPC);
    int nPCCharisma = GetAbilityScore(oPC, ABILITY_CHARISMA) - 10;

    int nAdjust = 0;
    nAdjust = nPCAppraise + nPCCharisma;

    if (nAdjust != 0) nAdjust = nAdjust/2;

    if (nAdjust > nCap) nAdjust = nCap;
    if (nAdjust < -nCap) nAdjust = -nCap;

    FloatingTextStringOnCreature("*Merchant Reaction: " + IntToString(nAdjust)+" (Appraise: "+IntToString(nPCAppraise)+", Charisma: "+IntToString(nPCCharisma)+")*", oPC, FALSE);

    OpenStore(oStore, oPC, -nAdjust, nAdjust);
}

//void main() {}
