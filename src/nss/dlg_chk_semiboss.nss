int StartingConditional()
{
    if (GetLocalInt(OBJECT_SELF, "semiboss") == 1)
    {
        return TRUE;
    }
    else
    {
        return FALSE;
    }
}
