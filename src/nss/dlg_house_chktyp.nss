int StartingConditional()
{
    if (GetScriptParam("type") == GetSubString(GetTag(OBJECT_SELF), 5, 4))
    {
        return TRUE;
    }
    else
    {
        return FALSE;
    }
}
