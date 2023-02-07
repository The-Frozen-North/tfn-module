#include "inc_ctoken"

void main()
{
    object oPC = GetPCSpeaker();
    string sCDKey = GetPCPublicCDKey(oPC);

    int nGoldInStorage = GetCampaignInt(sCDKey, "gold");
    if (nGoldInStorage >= 1)
    {
        SetCampaignInt(sCDKey, "gold", 0);
        GiveGoldToCreature(oPC, nGoldInStorage);
        SetCustomToken(CTOKEN_HOUSE_GOLDSTORAGE, IntToString(GetCampaignInt(sCDKey, "gold")));
        ExportSingleCharacter(oPC);
        PlaySound("it_coins");
    }
}


