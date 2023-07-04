void main()
{
    object oBaram = GetObjectByTag("baram");
    if(GetIsObjectValid(oBaram))
    {
        if(!GetHasSpellEffect(SPELL_STONESKIN, oBaram))
        {
            ActionCastSpellAtObject(SPELL_STONESKIN, oBaram, METAMAGIC_ANY, TRUE);
        }
    }
}