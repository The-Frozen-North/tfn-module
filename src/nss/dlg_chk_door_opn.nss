int StartingConditional()
{
    object oDoor = GetObjectByTag(GetScriptParam("door"));

    if (GetIsOpen(oDoor))
    {
        return TRUE;
    }
    else
    {
        return FALSE;
    }
}
