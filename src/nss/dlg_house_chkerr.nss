int StartingConditional()
{
    if (!GetIsObjectValid(GetObjectByTag(GetLocalString(OBJECT_SELF, "area"))))
    {
        return TRUE;
    }
    else
    {
        return FALSE;
    }
}
