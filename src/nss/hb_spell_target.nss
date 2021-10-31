void main()
{
    if (d3() == 1)
    {
        object oTarget = GetObjectByTag(GetLocalString(OBJECT_SELF, "target"));

        int nSpell = SPELL_MAGIC_MISSILE;

        switch (d6())
        {
            case 1: nSpell = SPELL_ACID_SPLASH; break;
            case 2: nSpell = SPELL_ELECTRIC_JOLT; break;
            case 3: nSpell = SPELL_FLARE; break;
            case 4: nSpell = SPELL_ICE_DAGGER; break;
            case 5: nSpell = SPELL_NEGATIVE_ENERGY_RAY; break;
        }

        ActionCastSpellAtObject(nSpell, GetObjectByTag(GetLocalString(OBJECT_SELF, "target")), METAMAGIC_ANY, TRUE);
    }
}
