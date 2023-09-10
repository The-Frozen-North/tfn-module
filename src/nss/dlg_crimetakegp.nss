int StartingConditional()
{
    object oPC = GetPCSpeaker();

    int nGold = GetLocalInt(oPC, "crime_gold");

    if (GetGold(oPC) >= nGold)
    {
        TakeGoldFromCreature(nGold, oPC, TRUE);
        return TRUE;
    }

    return FALSE;
}
