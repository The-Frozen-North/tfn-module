int StartingConditional()
{
    if (GetCampaignInt(GetPCPublicCDKey(GetPCSpeaker()), "gold") >= StringToInt(GetScriptParam("gold")))
    {
        return TRUE;
    }
    else
    {
        return FALSE;
    }
}
