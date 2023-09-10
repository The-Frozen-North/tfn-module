int StartingConditional()
{
    object oPC = GetPCSpeaker();

    int nGold = GetLocalInt(oPC, "crime_gold");

    if (GetGold(oPC) >= nGold)
    {
        return TRUE;
    }

    return FALSE;
}
