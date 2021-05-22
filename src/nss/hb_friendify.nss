void main()
{
    object oPC = GetFirstPC();

    if (!GetIsObjectValid(oPC))
        return;

    while (GetIsObjectValid(oPC))
    {
        ClearPersonalReputation(oPC, OBJECT_SELF);
        SetIsTemporaryFriend(oPC, OBJECT_SELF);
        SetIsTemporaryFriend(OBJECT_SELF, oPC);
        oPC = GetNextPC();
    }
}
