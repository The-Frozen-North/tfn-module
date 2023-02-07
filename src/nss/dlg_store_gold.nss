#include "inc_ctoken"

void main()
{
    object oPC = GetPCSpeaker();

    int nGold = StringToInt(GetScriptParam("gold"));
    if (GetGold(oPC) >= nGold)
    {
        string sCDKey = GetPCPublicCDKey(oPC);

        TakeGoldFromCreature(nGold, oPC, TRUE);
        SetCampaignInt(sCDKey, "gold", GetCampaignInt(sCDKey, "gold")+nGold);
        SetCustomToken(CTOKEN_HOUSE_GOLDSTORAGE, IntToString(GetCampaignInt(sCDKey, "gold")));
        ExportSingleCharacter(oPC);
        PlaySound("it_coins");
    }
}
