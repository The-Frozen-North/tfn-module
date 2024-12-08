
// This deals with loot balancing between party members - evening out the loot received rather than rolling equal odds for every item

#include "inc_general"
#include "inc_treasure"
#include "inc_party"

// "Owings" and "tracked debt" (because it feels bad when someone gets all the bad loot)
// A PC tracks how much each henchman and other player "owes" them (based on gold value disparity)
// -> Use this to weight the probability of who gets what items
// The PC-henchman owings are tracked in the PC BIC DB
// PC-PC owings are, at least for now, tracked in a serverside Cdkey-Cdkey db
// This might be a bit weird but permanently tracking characters seems like a significantly more difficult problem

// For the sake of implementation, each henchman/PC in the party starts with 1000 "points"
// If they "owe" some other party member(s) loot, they give some of their points to the people they owe to
// Then roll a d(total number of points) and see whose band the roll lands in, and they get the item

// This falls down when one party member tries to give out more than their 1000 "points"
// ... in which case their points need to instead be distributed relative to the people demanding them
// eg if three people demand 100/400/800 points from me (total 1300), first person gets 100/1.3, second gets 400/1.3, third gets 800/1.3

// Return the amount of gold value oDebtor owes oReceiver.
// If oReceiver instead owes oDebtor, the value returned is negative.
int GetOwedGoldValue(object oReceiver, object oDebtor);

// Return how many "owing points" to transfer from oDebtor to oReceiver for getting an item of nItemGoldValue
// If oReceiver owes oDebtor value, this will be negative.
int GetLootWeightingTransferBasedOnOwings(object oReceiver, object oDebtor, int nItemGoldValue);

// Increase the debt of oDebtor to oReceiver by nAmount.
void AdjustOwedGoldValue(object oReceiver, object oDebtor, int nAmount);

// Take the loot item (in the treasure area chest) and return the index of the party member that should recieve it.
// Assumes SetPartyData(oLootSource) has been called, else results will be nonsensical.
int DeterminePartyMemberThatGetsItem(object oItem, int nStartWeights=1000);

// Whether or not to write debug messages about loot owing to the log
const int LOOT_OWING_DEBUG = 1;


// Return the amount of gold value oDebtor owes oReceiver.
// If oReceiver instead owes oDebtor, the value returned is negative.
int GetOwedGoldValue(object oReceiver, object oDebtor)
{
    if (!GetIsPC(oReceiver) && !GetIsPC(oDebtor))
    {
        int nSaved = GetCampaignInt("lootowings", "hench_" + GetTag(oReceiver) + "-" + GetTag(oDebtor));
        if (nSaved == 0)
        {
            nSaved = GetCampaignInt("lootowings", "hench_" + GetTag(oDebtor) + "-" + GetTag(oReceiver)) * -1;
        }
        return nSaved;
    }
    if (GetIsPC(oReceiver) && GetIsPC(oDebtor))
    {
        int nSaved = GetCampaignInt("lootowings", GetPCPublicCDKey(oReceiver) + "-" + GetPCPublicCDKey(oDebtor));
        if (nSaved == 0)
        {
            nSaved = GetCampaignInt("lootowings", GetPCPublicCDKey(oDebtor) + "-" + GetPCPublicCDKey(oReceiver)) * -1;
        }
        return nSaved;
    }
    // If we get here, exactly one of oDebtor and oReceiver is a PC and the other is a henchman
    object oPC;
    object oHen;
    if (GetIsPC(oReceiver))
    {
        oPC = oReceiver;
        oHen = oDebtor;
    }
    else
    {
        oPC = oDebtor;
        oHen = oReceiver;
    }
    // Check the PC's BIC db for the amount
    int nAmt = SQLocalsPlayer_GetInt(oPC, "lootowing_" + GetTag(oHen));
    // This is how much the hench owes the player, make it negative if the function was called the other way round
    if (oDebtor == oPC)
    {
        nAmt *= -1;
    }
    return nAmt;
}

// Return how many "owing points" to transfer from oDebtor to oReceiver for getting an item of nItemGoldValue
// If oReceiver owes oDebtor value, this will be negative.
int GetLootWeightingTransferBasedOnOwings(object oReceiver, object oDebtor, int nItemGoldValue)
{
    int nDebt = GetOwedGoldValue(oReceiver, oDebtor);
    // This is the fastest outcome, and will cause dividing by zero later if not dealt with now
    if (nDebt == 0)
    {
        return 0;
    }
    if (nDebt < 0)
    {
        return -1*GetLootWeightingTransferBasedOnOwings(oDebtor, oReceiver, nItemGoldValue);
    }
    // Base premise:
    // points to transfer when owing = 10 + (itemvalue/min(debt, 22000))^1.5 * 55
    // min(debt, 22000) is because 22000 is the highest possible in one item (upper value bracket of t5)
    // adding 10 means the split is 60/40 for all items
    // the exponential expression means that items are much more skewed the closer they are to the debt size
    // In TFN item gold value does not scale linearly with "desirableness" and this is an attempt to capture that

    // If the item value > debt size, calc how much it exceeds by and subtract that from the item value
    // this will mean that the curve mirrors as value passes debt size and rapidly drops down to more even values
    // as the debt is exceeded
    if (nDebt < nItemGoldValue)
    {
        // (but don't make the item value go negative)
        nItemGoldValue = max(0, nDebt - (nItemGoldValue - nDebt));
    }
    float fItemGoldValue = IntToFloat(nItemGoldValue);
    float fDebt = IntToFloat(min(nDebt, MAX_VALUE));
    float fTransfer = 100 + (pow(fItemGoldValue/fDebt, 1.5) * 850);
    return FloatToInt(fTransfer);
}

// Increase the debt of oDebtor to oReceiver by nAmount.
void AdjustOwedGoldValue(object oReceiver, object oDebtor, int nAmount)
{
    if (!GetIsPC(oReceiver) && !GetIsPC(oDebtor))
    {
        string sVar = "hench_" + GetTag(oReceiver) + "-" + GetTag(oDebtor);
        int nSaved = GetCampaignInt("lootowings", sVar);
        if (nSaved == 0)
        {
            sVar = "hench_" + GetTag(oDebtor) + "-" + GetTag(oReceiver);
            nSaved = GetCampaignInt("lootowings", sVar);
            nAmount *= -1;
        }
        if (LOOT_OWING_DEBUG)
        {
            WriteTimestampedLogEntry("Added " + IntToString(nAmount) + " to the amount " + GetName(oDebtor) + " owes " + GetName(oReceiver) + ": now " + IntToString(nSaved + nAmount));
        }
        SetCampaignInt("lootowings", sVar, nSaved + nAmount);
        return;
    }
    if (GetIsPC(oReceiver) && GetIsPC(oDebtor))
    {
        // Figure out which one is being used
        string sVar = GetPCPublicCDKey(oReceiver) + "-" + GetPCPublicCDKey(oDebtor);
        int nSaved = GetCampaignInt("lootowings", sVar);
        if (nSaved == 0)
        {
            sVar = GetPCPublicCDKey(oDebtor) + "-" + GetPCPublicCDKey(oReceiver);
            nSaved = GetCampaignInt("lootowings", sVar);
            nAmount *= -1;
        }
        if (LOOT_OWING_DEBUG)
        {
            WriteTimestampedLogEntry("Added " + IntToString(nAmount) + " to the amount " + GetName(oDebtor) + " owes " + GetName(oReceiver) + ": now " + IntToString(nSaved + nAmount));
        }
        SetCampaignInt("lootowings", sVar, nSaved + nAmount);
        return;
    }
    // If we get here, exactly one of oDebtor and oReceiver is a PC and the other is a henchman
    object oPC;
    object oHen;
    if (GetIsPC(oReceiver))
    {
        oPC = oReceiver;
        oHen = oDebtor;
    }
    else
    {
        oPC = oDebtor;
        oHen = oReceiver;
        nAmount *= -1;
    }
    // Check the PC's BIC db for the amount
    int nSaved = SQLocalsPlayer_GetInt(oPC, "lootowing_" + GetTag(oHen));
    if (LOOT_OWING_DEBUG)
    {
        WriteTimestampedLogEntry("Added " + IntToString(nAmount) + " to the amount " + GetName(oHen) + " owes " + GetName(oPC) + ": now " + IntToString(nSaved + nAmount));
    }
    SQLocalsPlayer_SetInt(oPC, "lootowing_" + GetTag(oHen), nSaved + nAmount);
}

int DeterminePartyMemberThatGetsItem(object oItem, int nStartWeights=1000)
{
    int nWasIdentified = GetIdentified(oItem);
    SetIdentified(oItem, 1);
    int nItemValue = GetGoldPieceValue(oItem);
    if (LOOT_OWING_DEBUG)
    {
        WriteTimestampedLogEntry("Try to assign: " + GetName(oItem) + ", value = " +IntToString(nItemValue));
    }
    SetIdentified(oItem, nWasIdentified);
    if (!GetIsObjectValid(oItem))
    {
        return -1;
    }
    // Recommended reading: inc_loot -> "owings" section
    // First, simply go through everyone and work out weightings
    // combinations need to be done EXACTLY once, PC1 vs Daelan then Daelan vs PC1 will undo itself
    int nNumLootRecievers = Party.PlayerSize + Party.HenchmanSize;
    int i, j;
    // Everyone starts on 1000
    for (i=1; i<=nNumLootRecievers; i++)
    {
        SetLocalArrayInt(OBJECT_SELF, "LootWeights", i, nStartWeights);
    }
    object oRecipient;
    for (i=1; i<=nNumLootRecievers; i++)
    {
        if (i <= Party.PlayerSize)
        {
            oRecipient = GetLocalArrayObject(OBJECT_SELF, "Players", i);
        }
        else
        {
            oRecipient = GetLocalArrayObject(OBJECT_SELF, "Henchmans", i - Party.PlayerSize);
        }
        // Check all other party members after this index
        // this should avoid the above mentioned "reverse" cases
        int nWeight = GetLocalArrayInt(OBJECT_SELF, "LootWeights", i);
        for (j=i+1; j<=nNumLootRecievers; j++)
        {
            object oDebtor;
            if (j <= Party.PlayerSize)
            {
                oDebtor = GetLocalArrayObject(OBJECT_SELF, "Players", j);
            }
            else
            {
                oDebtor = GetLocalArrayObject(OBJECT_SELF, "Henchmans", j - Party.PlayerSize);
            }
            int nTransfer = GetLootWeightingTransferBasedOnOwings(oRecipient, oDebtor, nItemValue);
            int nDebtorWeight = GetLocalArrayInt(OBJECT_SELF, "LootWeights", j);
            nDebtorWeight -= nTransfer;
            nWeight += nTransfer;
            if (LOOT_OWING_DEBUG)
            {
                WriteTimestampedLogEntry(GetName(oDebtor) + " owes " + IntToString(GetOwedGoldValue(oRecipient, oDebtor)) + " to " + GetName(oRecipient) + ": transfer " + IntToString(nTransfer) + " weighting -> " + GetName(oRecipient) + "=" + IntToString(nWeight) + ", " + GetName(oDebtor) + "=" + IntToString(nDebtorWeight));
            }
            SetLocalArrayInt(OBJECT_SELF, "LootWeights", j, nDebtorWeight);
        }
        SetLocalArrayInt(OBJECT_SELF, "LootWeights", i, nWeight);
    }
    // Make sure no weight ended up negative, if it did, repeat with a higher nStartWeights
    int nLowestWeight = 999999;
    int nTotalWeight = nStartWeights * nNumLootRecievers;
    for (i=1; i<=nNumLootRecievers; i++)
    {
        int nWeight = GetLocalArrayInt(OBJECT_SELF, "LootWeights", i);
        if (LOOT_OWING_DEBUG)
        {
            object oPerson;
            if (i <= Party.PlayerSize)
            {
                oPerson = GetLocalArrayObject(OBJECT_SELF, "Players", i);
            }
            else
            {
                oPerson = GetLocalArrayObject(OBJECT_SELF, "Henchmans", i - Party.PlayerSize);
            }
            WriteTimestampedLogEntry(GetName(oPerson) + " = " + IntToString(nWeight) + " or " + IntToString(100*nWeight/nTotalWeight) + " percent");
        }
        if (nWeight < nLowestWeight)
        {
            nLowestWeight = nWeight;
        }
    }
    if (LOOT_OWING_DEBUG)
    {
        WriteTimestampedLogEntry("Lowest weight = " + IntToString(nLowestWeight));
    }
    if (nLowestWeight < 0)
    {
        // I don't think this is perfect, but it is by far the easiest way to get out of this particular hole
        // and solve the negative weight problem
        if (LOOT_OWING_DEBUG)
        {
            WriteTimestampedLogEntry("Lowest weight is negative, try again with start points +" + IntToString(nLowestWeight*-1));
        }
        return DeterminePartyMemberThatGetsItem(oItem, nStartWeights + (nLowestWeight*-1));
    }

    int nRolledWeight = Random(nTotalWeight)+1;
    if (LOOT_OWING_DEBUG)
    {
        WriteTimestampedLogEntry("Total weight = " + IntToString(nTotalWeight));
        WriteTimestampedLogEntry("Rolled = " + IntToString(nRolledWeight));
    }
    int nAssignedIndex = -1;
    for (i=1; i<=nNumLootRecievers; i++)
    {
        int nWeight = GetLocalArrayInt(OBJECT_SELF, "LootWeights", i);
        nRolledWeight -= nWeight;
        if (LOOT_OWING_DEBUG)
        {
            WriteTimestampedLogEntry("Index = " + IntToString(i) + " subtracted " + IntToString(nWeight) + "; now rolled = " + IntToString(nRolledWeight));
        }
        if (nRolledWeight < 0)
        {
            nAssignedIndex = i;
            break;
        }
    }
    if (LOOT_OWING_DEBUG)
    {
        WriteTimestampedLogEntry("Assigned index = " + IntToString(nAssignedIndex));
    }
    // Convert back to an object to return
    if (nAssignedIndex <= Party.PlayerSize)
    {
        oRecipient = GetLocalArrayObject(OBJECT_SELF, "Players", nAssignedIndex);
        IncrementPlayerStatistic(oRecipient, "item_gold_value_assigned", nItemValue);
    }
    else
    {
        oRecipient = GetLocalArrayObject(OBJECT_SELF, "Henchmans", nAssignedIndex - Party.PlayerSize);
        for (i=1; i<= Party.PlayerSize; i++)
        {
            object oPlayer = GetLocalArrayObject(OBJECT_SELF, "Players", i);
            IncrementPlayerStatistic(oPlayer, "henchman_item_gold_value_assigned", nItemValue);
        }
    }
    // Update gold owings
    // I guess the best way to do this is to just subtract (item gold value/(party size-1)) from everyone else's owing
    // to the person who got it

    // This logic will turn into a divide by zero if solo
    if (nNumLootRecievers > 1)
    {
        int nSubtraction = -1*(nItemValue/(nNumLootRecievers-1));
        for (i=1; i<=nNumLootRecievers; i++)
        {
            object oNonRecipient;
            if (i <= Party.PlayerSize)
            {
                oNonRecipient = GetLocalArrayObject(OBJECT_SELF, "Players", i);
            }
            else
            {
                oNonRecipient = GetLocalArrayObject(OBJECT_SELF, "Henchmans", i - Party.PlayerSize);
            }
            if (i == nAssignedIndex)
            {
                continue;
            }
            AdjustOwedGoldValue(oRecipient, oNonRecipient, nSubtraction);
        }
    }
    if (LOOT_OWING_DEBUG)
    {
        WriteTimestampedLogEntry("Assigned " + GetName(oItem) + " to " + GetName(oRecipient));
    }
    return nAssignedIndex;
}