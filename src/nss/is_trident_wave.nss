// Wave (trident)
// 15% chance for 3d8 cold damage
void main()
{
    object oTarget = GetSpellTargetObject();
    if (GetIsObjectValid(oTarget))
    {
        if (Random(100) < 15)
        {
            effect eDmg = EffectLinkEffects(
                EffectVisualEffect(VFX_IMP_FROST_L),
                EffectDamage(d8(3), DAMAGE_TYPE_COLD)
            );
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eDmg, oTarget);
        }
    }
}
