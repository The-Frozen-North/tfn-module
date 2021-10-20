void main()
{
    object oPC = GetPCSpeaker();
    string sCDKey = GetPCPublicCDKey(oPC);

    int nGoldInStorage = GetCampaignInt(sCDKey, "gold");
    if (nGoldInStorage >= 1)
    {
        SetCampaignInt(sCDKey, "gold", 0);
        GiveGoldToCreature(oPC, nGoldInStorage);
        SetCustomToken(29901, IntToString(GetCampaignInt(sCDKey, "gold")));
        PlaySound("it_coins");
    }
}


