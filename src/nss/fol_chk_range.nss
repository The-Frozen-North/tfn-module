int StartingConditional()
{
    if(GetLocalInt(OBJECT_SELF, "range") == 1)
    {
        return TRUE;
    }
    return FALSE;
}
