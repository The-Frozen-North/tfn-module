int StartingConditional()
{
    if (GetPCPublicCDKey(GetPCSpeaker()) == GetLocalString(OBJECT_SELF, "cd_key")) return TRUE;

    return FALSE;
}
