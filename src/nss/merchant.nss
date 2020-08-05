#include "inc_gold"
#include "inc_debug"

void main()
{
    object oMerchant = OBJECT_SELF;

    string sMerchantTag = GetLocalString(OBJECT_SELF, "merchant");

    object oStore = GetObjectByTag(sMerchantTag);

// stop if store doesn't exist
    if (!GetIsObjectValid(oStore))
    {
        SendDebugMessage("Store doesn't exist: "+sMerchantTag);
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
