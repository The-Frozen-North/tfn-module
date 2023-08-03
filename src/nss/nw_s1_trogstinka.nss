//::///////////////////////////////////////////////
//:: Aura of Troglodyte Stench On Enter
//:: nw_s1_trogstinkA.nss
//:: Copyright (c) 2004 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Objects entering the Stench must make a fortitude
    saving throw (DC 13) or suffer 1D6 points of
    Strength Ability Damage.
*/
//:://////////////////////////////////////////////
//:: Created By: Craig Welburn
//:: Created On: Nov 6, 2004
//:://////////////////////////////////////////////
/*
Patch 1.70

- alignment immune creatures were ommited
- was missing immunity feedback
*/

#include "x0_i0_spells"

void main()
{
    // Declare major variables
    object oTarget = GetEnteringObject();
    object oSource = GetAreaOfEffectCreator();

    // Declare all the required effects
    effect eVis1;
    effect eVis2;

    effect eSaves = EffectSavingThrowDecrease(SAVING_THROW_ALL,1);
    effect eAttack = EffectAttackDecrease(1);
    effect eDamage = EffectDamageDecrease(1,DAMAGE_TYPE_BLUDGEONING|DAMAGE_TYPE_SLASHING|DAMAGE_TYPE_PIERCING);
    effect eSkill = EffectSkillDecrease(SKILL_ALL_SKILLS,1);
    effect ePoison = EffectPoison(POISON_GREENBLOOD_OIL);

    effect eLink = EffectLinkEffects(eAttack,eDamage);
    eLink = EffectLinkEffects(eLink,eSaves);
    eLink = EffectLinkEffects(eLink,eSkill);
    eLink = EffectLinkEffects(eLink,ePoison);

    if(!GetHasSpellEffect(SPELLABILITY_TROGLODYTE_STENCH, oTarget))
    {
        // Is the target a valid creature
        if(spellsIsTarget(oTarget, SPELL_TARGET_SELECTIVEHOSTILE, oSource))
        {
            // Notify the target that they are being attacked
            SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, AOE_MOB_TROGLODYTE_STENCH));

            // Prepare the visual effect for the casting and saving throw
            eVis1 = EffectVisualEffect(VFX_IMP_POISON_S);
            eVis2 = EffectVisualEffect(VFX_IMP_FORTITUDE_SAVING_THROW_USE);

            ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis2, oTarget);

            // Make a Fortitude saving throw, DC 13 and apply the effect if it fails
            if (!MySavingThrow(SAVING_THROW_FORT, oTarget, 13, SAVING_THROW_TYPE_POISON, oSource))
            {
                if (!GetIsImmune(oTarget, IMMUNITY_TYPE_POISON, oSource))
                {
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis1, oTarget);
                    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, RoundsToSeconds(10));
                }
                else
                {
                    //engine workaround to get proper immunity feedback
                    ApplyEffectToObject(DURATION_TYPE_PERMANENT,EffectPoison(POISON_ETTERCAP_VENOM),oTarget);
                }
            }
        }
    }
}
