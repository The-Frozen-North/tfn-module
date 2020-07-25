int StartingConditional()
{
    object oPC = GetPCSpeaker();
    return GetPCPublicCDKey(oPC) == "" || GetIsDM(oPC) || GetIsDMPossessed(oPC);
}
