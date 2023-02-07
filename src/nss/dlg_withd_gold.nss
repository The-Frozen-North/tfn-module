#include "inc_ctoken"

void main()
{
    object oPC = GetPCSpeaker();
    string sCDKey = GetPCPublicCDKey(oPC);

    int nGold = StringToInt(GetScriptParam("gold"));
    int nGoldInStorage = GetCampaignInt(sCDKey, "gold");
    if (nGoldInStorage >= nGold)
    {
        SetCampaignInt(sCDKey, "gold", nGoldInStorage-nGold);
        GiveGoldToCreature(oPC, nGold);
        SetCustomToken(CTOKEN_HOUSE_GOLDSTORAGE, IntToString(GetCampaignInt(sCDKey, "gold")));
        ExportSingleCharacter(oPC);
        PlaySound("it_coins");
    }
}

