int StartingConditional()
{
    object oDoor = GetObjectByTag("q4c_jail_door");
    if (GetIsOpen(oDoor))
    {
        return 1;
    }
    return 0;
}
