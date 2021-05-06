int StartingConditional()
{
    if (GetLocalInt(OBJECT_SELF, "fed") == 1)
    {
        return TRUE;
    }
    else
    {
        return FALSE;
    }
}
