void main()
{
    object oTarget = GetSpellTargetObject();
    if (!GetIsObjectValid(oTarget))
    {
        location lTarget = GetSpellTargetLocation();
        oTarget = GetNearestCreatureToLocation(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, lTarget, 1, CREATURE_TYPE_IS_ALIVE, TRUE, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN);
    }

    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_DIVINE_STRIKE_HOLY), GetLocation(oTarget));
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_BIGBYS_FORCEFUL_HAND), oTarget);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(d6(3)), oTarget);
    if (!GetIsSkillSuccessful(oTarget, SKILL_DISCIPLINE, 25))
    {
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectKnockdown(), oTarget, 6.0);
    }
}
