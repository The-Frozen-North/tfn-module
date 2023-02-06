#include "inc_ctoken"

void main()
{
    object oPC = GetPCSpeaker();

    int nGold = GetGold(oPC);
    if (nGold >= 1)
    {
        string sCDKey = GetPCPublicCDKey(oPC);

        TakeGoldFromCreature(nGold, oPC, TRUE);
        SetCampaignInt(sCDKey, "gold", GetCampaignInt(sCDKey, "gold")+nGold);
        SetCustomToken(CTOKEN_HOUSE_GOLDSTORAGE, IntToString(GetCampaignInt(sCDKey, "gold")));
        ExportSingleCharacter(oPC);
        PlaySound("it_coins");
    }
}

