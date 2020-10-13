int StartingConditional()
{
    object oPC = GetPCSpeaker();

    if (GetLocalString(OBJECT_SELF, "current") == GetScriptParam("target"))
    {
        return FALSE;
    }
    else
    {
        return TRUE;
    }
}
