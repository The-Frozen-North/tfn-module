int StartingConditional()
{
    if(GetLocalInt(OBJECT_SELF, "range") == 0)
    {
        return TRUE;
    }
    return FALSE;
}
