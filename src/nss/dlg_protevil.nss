void main()
{
    ActionCastSpellAtObject(SPELL_PROTECTION_FROM_EVIL, GetPCSpeaker(), METAMAGIC_ANY, TRUE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
    object oPC = GetPCSpeaker();
    object oTest = GetFirstFactionMember(oPC);
    while (GetIsObjectValid(oTest))
    {
        ActionCastSpellAtObject(SPELL_PROTECTION_FROM_EVIL, oTest, METAMAGIC_ANY, TRUE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
        oTest = GetNextFactionMember(oPC);
    }
}
