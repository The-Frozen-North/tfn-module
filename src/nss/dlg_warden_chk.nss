int StartingConditional()
{
    object oPC = GetPCSpeaker();

    if (GetLocalInt(OBJECT_SELF, "bluffed_"+GetPCPublicCDKey(oPC)+GetName(oPC)))
        return TRUE;

    return FALSE;
}
