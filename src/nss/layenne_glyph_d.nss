void ZapGolem(int nAmt)
{
    object oGolem = GetObjectByTag("layenne_golem");
    SetPlotFlag(oGolem, FALSE);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(nAmt, DAMAGE_TYPE_ELECTRICAL), oGolem);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_LIGHTNING_M), oGolem);
    if (!GetIsDead(oGolem))
    {
        SetPlotFlag(oGolem, TRUE);
    }
}

void main()
{
    int bAllDead = 1;
    int i;
    for (i=1; i<=4; i++)
    {
        object oWP = GetWaypointByTag("LayenneGlyph" + IntToString(i));
        object oOldGlyph = GetLocalObject(oWP, "LayenneGlyphPlc");
        if (GetIsObjectValid(oOldGlyph) && !GetIsDead(oOldGlyph))
        {
            bAllDead = 0;
            break;
        }
    }
    object oGolem = GetObjectByTag("layenne_golem");
    object oPC = GetLastKiller();
    if (bAllDead)
    {
        SetPlotFlag(oGolem, FALSE);
        AssignCommand(oPC, ZapGolem(500 + Random(500)));
        // If AssignCommand fails for any reason, make sure it still dies
        DelayCommand(3.0, AssignCommand(oGolem, ZapGolem(500 + Random(500))));
        DelayCommand(6.0, AssignCommand(GetModule(), ZapGolem(500 + Random(500))));
    }
    else
    {
        // At least do a little zap to him :)
        ZapGolem(d6() + 3);
    }
}
