void Befriend(object oCreature)
{
    ClearPersonalReputation(oCreature, OBJECT_SELF);
    SetIsTemporaryFriend(oCreature, OBJECT_SELF);
    SetIsTemporaryFriend(OBJECT_SELF, oCreature);
}

void main()
{
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_NATURES_BALANCE), GetLocation(OBJECT_SELF));

    object oPC = GetFirstPC();

    if (!GetIsObjectValid(oPC))
        return;

    while (GetIsObjectValid(oPC))
    {
        Befriend(oPC);
        object oAssociate = GetFirstFactionMember(oPC, FALSE);
        while (GetIsObjectValid(oAssociate))
        {
             Befriend(oAssociate);
            oAssociate = GetNextFactionMember(oPC, FALSE);
        }
        oPC = GetNextPC();
    }
}
