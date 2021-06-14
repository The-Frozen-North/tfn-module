int StartingConditional()
{
    if (GetIsObjectValid(GetItemPossessedBy(GetPCSpeaker(), GetScriptParam("tag"))))
    {
        return TRUE;
    }
    else
    {
        return FALSE;
    }
}
