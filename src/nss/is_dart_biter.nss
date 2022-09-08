// Biter (dart)
// 10% chance to reduce AC by 1 for 1 turn
void main()
{
    object oTarget = GetSpellTargetObject();
    if (GetIsObjectValid(oTarget))
    {
        if (Random(100) < 10)
        {
            //use AC_DODGE so it stacks
            effect eACDecrease = ExtraordinaryEffect(EffectACDecrease(1, AC_DODGE_BONUS));
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eACDecrease, oTarget, TurnsToSeconds(1));

            effect eVis = EffectVisualEffect(VFX_IMP_ACID_S);
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
        }
    }
}
