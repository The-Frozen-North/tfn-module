void main()
{
    ActionCastSpellAtObject(SPELL_PROTECTION_FROM_EVIL, GetPCSpeaker(), METAMAGIC_ANY, TRUE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
    object oPC = GetPCSpeaker();
    int nAssociateType = 1;
    for (nAssociateType=1; nAssociateType<=5; nAssociateType++)
    {
        int n=1;
        object oTest;
        while (1)
        {
            oTest = GetAssociate(nAssociateType, oPC, n);
            if (!GetIsObjectValid(oTest))
            {
                break;
            }
            ActionCastSpellAtObject(SPELL_PROTECTION_FROM_EVIL, oTest, METAMAGIC_ANY, TRUE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
            n++;
        }
    }
}
