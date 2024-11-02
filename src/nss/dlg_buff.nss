#include "inc_debug"
void main()
{
    object oPC = GetPCSpeaker();

    if (GetIsDeveloper(oPC))
    {
        SendDiscordLogMessage(GetName(oPC) + " used the developer menu to apply various OP buffs to themselves.");
        effect eLink = EffectAttackIncrease(20);
        eLink = EffectLinkEffects(eLink, EffectDamageIncrease(30));
        eLink = EffectLinkEffects(eLink, EffectDamageImmunityIncrease(4095, 90));
        eLink = EffectLinkEffects(eLink, EffectSpellResistanceIncrease(28));
        eLink = EffectLinkEffects(eLink, EffectMovementSpeedIncrease(99));
        eLink = EffectLinkEffects(eLink, EffectTemporaryHitpoints(200));
        eLink = EffectLinkEffects(eLink, EffectHaste());
        eLink = EffectLinkEffects(eLink, EffectSkillIncrease(SKILL_SEARCH, 50));
        eLink = EffectLinkEffects(eLink, EffectSkillIncrease(SKILL_LORE, 50));
        eLink = EffectLinkEffects(eLink, EffectSkillIncrease(SKILL_PERSUADE, 50));
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, SupernaturalEffect(eLink), oPC, 3600.0);
    }
}
