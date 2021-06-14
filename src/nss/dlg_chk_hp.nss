int StartingConditional()
{
    if (GetLocalInt(OBJECT_SELF, "follower") == 1)
        return FALSE;

    if (GetCurrentHitPoints(OBJECT_SELF) <= 50)
    {
        return TRUE;
    }
    {
        return FALSE;
    }
}
