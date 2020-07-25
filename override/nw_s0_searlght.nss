//::///////////////////////////////////////////////
//:: Searing Light
//:: s_SearLght.nss
//:: Copyright (c) 2000 Bioware Corp.
//:://////////////////////////////////////////////
//:: Focusing holy power like a ray of the sun, you project
//:: a blast of light from your open palm. You must succeed
//:: at a ranged touch attack to strike your target. A creature
//:: struck by this ray of light suffers 1d8 points of damage
//:: per two caster levels (maximum 5d8). Undead creatures suffer
//:: 1d6 points of damage per caster level (maximum 10d6), and
//:: undead creatures particularly vulnerable to sunlight, such
//:: as vampires, suffer 1d8 points of damage per caster level
//:: (maximum 10d8). Constructs and inanimate objects suffer only
//:: 1d6 points of damage per two caster levels (maximum 5d6).
//:://////////////////////////////////////////////
//:: Created By: Keith Soleski
//:: Created On: 02/05/2001
//:://////////////////////////////////////////////
//:: VFX Pass By: Preston W, On: June 25, 2001
/*
Patch 1.72

- damage dice against undead targets raised from k8 to k8 to match spell description
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DamageCap = 10;
    spell.Dice = 8;
    spell.DamageType = DAMAGE_TYPE_DIVINE;
    spell.SavingThrow = SAVING_THROW_NONE;
    spell.TargetType = SPELL_TARGET_SINGLETARGET;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    int nCasterLevel = spell.Level;
    int nDamage;
    int nDice;
    effect eDam;
    effect eVis = EffectVisualEffect(spell.DmgVfxS);
    effect eRay = EffectBeam(VFX_BEAM_HOLY, spell.Caster, BODY_NODE_HAND);
    if(spellsIsTarget(spell.Target, spell.TargetType, spell.Caster))
    {
        //Fire cast spell at event for the specified target
        SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id));
        //Make an SR Check
        if (!MyResistSpell(spell.Caster, spell.Target))
        {
            //Limit caster level
            if (nCasterLevel > spell.DamageCap)
            {
                nCasterLevel = spell.DamageCap;
            }
            //Check for racial type undead
            if (spellsIsRacialType(spell.Target, RACIAL_TYPE_UNDEAD))
            {
                nDice = spell.Dice;
            }
            //Check for racial type construct
            else if (spellsIsRacialType(spell.Target, RACIAL_TYPE_CONSTRUCT))
            {
                nCasterLevel /= 2;
                if(nCasterLevel < 1)
                {
                    nCasterLevel = 1;
                }
                nDice = 6;
            }
            else
            {
                nCasterLevel = nCasterLevel/2;
                if(nCasterLevel < 1)
                {
                    nCasterLevel = 1;
                }
                nDice = spell.Dice;
            }
            nDamage = MaximizeOrEmpower(nDice,nCasterLevel,spell.Meta);

            //1.72: this will do nothing by default, but allows to dynamically enforce saving throw
            nDamage = GetSavingThrowAdjustedDamage(nDamage, spell.Target, spell.DC, spell.SavingThrow, spell.SaveType, spell.Caster);

            //Set the damage effect
            eDam = EffectDamage(nDamage, spell.DamageType);
            //Apply the damage effect and VFX impact
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, spell.Target);
            DelayCommand(0.5, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target));
        }
    }
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eRay, spell.Target, 1.7);
}
