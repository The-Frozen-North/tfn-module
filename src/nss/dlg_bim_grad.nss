int StartingConditional()
{
    object oPC = GetPCSpeaker();
    return GetLocalInt(oPC, "bim_graduate");
}
