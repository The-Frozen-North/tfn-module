//con_q2amaehouse1
int StartingConditional()
{
    object oPC = GetPCSpeaker();
    object oRing = GetItemPossessedBy(oPC, "q2amaeviirkey");
    if (GetIsObjectValid(oRing) == TRUE)
    {
        SetLocalObject(OBJECT_SELF, "oRing", oRing);
        return TRUE;
    }
    return FALSE;
}
