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
        SetCustomToken(29901, IntToString(GetCampaignInt(sCDKey, "gold")));
        PlaySound("it_coins");
    }
}

