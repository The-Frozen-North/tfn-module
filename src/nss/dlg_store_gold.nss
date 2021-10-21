void main()
{
    object oPC = GetPCSpeaker();

    int nGold = StringToInt(GetScriptParam("gold"));
    if (GetGold(oPC) >= nGold)
    {
        string sCDKey = GetPCPublicCDKey(oPC);

        TakeGoldFromCreature(nGold, oPC, TRUE);
        SetCampaignInt(sCDKey, "gold", GetCampaignInt(sCDKey, "gold")+nGold);
        SetCustomToken(29901, IntToString(GetCampaignInt(sCDKey, "gold")));
        ExportSingleCharacter(oPC);
        PlaySound("it_coins");
    }
}
