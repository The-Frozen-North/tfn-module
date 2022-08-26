int StartingConditional()
{
    object oAltar = GetObjectByTag("pedestal_cyric");
    if (GetIsObjectValid(oAltar) && !GetIsDead(oAltar))
    {
        return 1;
    }
    return 0;
}
