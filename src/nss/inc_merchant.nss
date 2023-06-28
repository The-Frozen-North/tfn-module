#include "inc_treasure"
#include "inc_gold"
#include "inc_sqlite_time"
#include "inc_debug"

// The time, in seconds, between reloading a store's contents
const int MERCHANT_STORE_RESTOCK_TIME = 82800; // 23h, can shop at the same time each day for new stock if you want

// Set on stores to indicate the last time (SQLite_GetTimeStamp)
// the store was last restocked at
const string MERCHANT_STORE_LAST_RESTOCKED_AT = "mer_last_restocked_time";

// Use 256 for all item types.
void CopyChest(object oTarget, string sChest, int nBaseItemType = BASE_ITEM_INVALID, string sDescriptionFilter = "", int bInfinite = FALSE);

// Adds enchanted weight reduction, and infinite if applicable
void ApplyEWRAndInfiniteItems(object oTarget);

// Checks whether it's been long enough since the last time this store was restocked
int ShouldRestockMerchant(object oStore);

// Do restocking of the merchant.
// Returns the new store object.
object AttemptMerchantRestock(object oTarget);

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

    if (ShouldRestockMerchant(oStore))
    {
        oStore = AttemptMerchantRestock(oStore);
    }

    object oPC = GetLastSpeaker();

    int nCap = MERCHANT_MODIFIER_CAP;

    int nPCAppraise = GetSkillRank(SKILL_APPRAISE, oPC);
    int nPCCharisma = GetAbilityScore(oPC, ABILITY_CHARISMA) - 10;

    int nAdjust = 0;
    nAdjust = nPCAppraise + nPCCharisma;

    string sCharm = "";
    if (GetLocalInt(oMerchant, "charmed") == 1)
    {
        sCharm = ", Charmed: 5";
        nAdjust = nAdjust + 5;
    }

    if (nAdjust != 0) nAdjust = nAdjust/2;

    if (nAdjust > nCap) nAdjust = nCap;
    if (nAdjust < -nCap) nAdjust = -nCap;

    FloatingTextStringOnCreature("*Merchant Reaction: " + IntToString(nAdjust)+" (Appraise: "+IntToString(nPCAppraise)+", Charisma: "+IntToString(nPCCharisma)+sCharm+")*", oPC, FALSE);

    OpenStore(oStore, oPC, -nAdjust, nAdjust);
}

int ShouldRestockMerchant(object oStore)
{
    // This means merchant stock will change every time you open a store in dev mode
    if (GetIsDevServer())
    {
        return 1;
    }
    int nTimeNow = SQLite_GetTimeStamp();
    int nLast = GetLocalInt(oStore, MERCHANT_STORE_LAST_RESTOCKED_AT);
    int nDiff = nTimeNow - nLast;
    if (nTimeNow - nLast >= MERCHANT_STORE_RESTOCK_TIME)
    {
        SendDebugMessage("Restock time for store " + GetTag(oStore) + ": Now=" + IntToString(nTimeNow) + ", last=" + IntToString(nLast) + ", diff=" + IntToString(nDiff));
        return 1;
    }
    return 0;
}

object AttemptMerchantRestock(object oStore)
{
    string sResRef = GetResRef(oStore);

    object oBaseArea = GetObjectByTag("_BASE");
    // Dynamically created stores, IE travelling merchants apparently don't
    // make their stores in the system area - if the store in question isn't
    // there, don't destroy it, as it'll likely be cleared as a result of
    // some other cleaning up script anyway
    object oNewStore;
    if (GetArea(oStore) == oBaseArea && !GetLocalInt(oStore, "norestock"))
    {
        SendDebugMessage("Restock store: " + GetTag(oStore));
        DestroyObject(oStore);
        location lLocation = Location(oBaseArea, Vector(1.0, 1.0, 1.0), 0.0);
        oNewStore = CreateObject(OBJECT_TYPE_STORE, sResRef, lLocation);
        ExecuteScript(GetTag(oNewStore), oNewStore);
    }
    else
    {
        SendDebugMessage("Store " + GetTag(oStore) + " should not restock!");
        oNewStore = oStore;
    }

    int nTimeNow = SQLite_GetTimeStamp();
    SetLocalInt(oNewStore, MERCHANT_STORE_LAST_RESTOCKED_AT, nTimeNow);
    return(oNewStore);
}

//void main() {}
