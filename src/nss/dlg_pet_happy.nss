int StartingConditional()
{
    if (GetLocalInt(OBJECT_SELF, "fed") != 1) return FALSE;

    object oPC = GetPCSpeaker();
    if (GetLocalInt(OBJECT_SELF, GetPCPublicCDKey(oPC, TRUE)+GetName(oPC)+"_petted") != 1) return FALSE;

    return TRUE;
}
