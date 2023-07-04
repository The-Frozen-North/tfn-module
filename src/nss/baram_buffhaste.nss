void main()
{
    object oBaram = GetObjectByTag("baram");
    if(GetIsObjectValid(oBaram))
    {
        if(!GetHasSpellEffect(SPELL_HASTE, oBaram))
        {
            ActionCastSpellAtObject(SPELL_HASTE, oBaram, METAMAGIC_ANY, TRUE);
        }
    }
}