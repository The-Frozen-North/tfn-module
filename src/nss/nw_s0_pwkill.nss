//::///////////////////////////////////////////////
//:: Power Word, Kill
//:: NW_S0_PWKill
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
// When power word, kill is uttered, you can either
// target a single creature or let the spell affect a
// group.
// If power word, kill is targeted at a single creature,
// that creature dies if it has 100 or fewer hit points.
// If the power word, kill is cast as an area spell, it
// kills creatures in a 15-foot-radius sphere. It only
// kills creatures that have 20 or fewer hit points, and
// only up to a total of 200 hit points of such
// creatures. The spell affects creatures with the lowest.
*/
//:://////////////////////////////////////////////
//:: Created By: Noel Borstad
//:: Created On: Dec 18, 2000
//:://////////////////////////////////////////////
//:: VFX Pass By: Preston W, On: June 22, 2001
//:: Update Pass By: Preston W, On: Aug 3, 2001
/*
Patch 1.72

- immunity check didn't correctly passed caster into consideration
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.Range = RADIUS_SIZE_LARGE;
    spell.Limit = 100;//spell kills only target with 100 or less hitpoints
    spell.TargetType = SPELL_TARGET_STANDARDHOSTILE;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    int nDamageDealt = 0;
    int nHitpoints, nMin;
    object oWeakest;
    effect eDeath = EffectDeath();
    effect eVis = EffectVisualEffect(VFX_IMP_DEATH);
    effect eWord =  EffectVisualEffect(VFX_FNF_PWKILL);
    float fDelay;
    int bKill;
    //Apply the VFX impact
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eWord, spell.Loc);
    //Check for the single creature or area targeting of the spell
    if(GetIsObjectValid(spell.Target))
    {
        if(spellsIsTarget(spell.Target, SPELL_TARGET_SINGLETARGET, spell.Caster))
        {
            //Fire cast spell at event for the specified target
            SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id));
            //Check the creatures HP
            if(GetCurrentHitPoints(spell.Target) <= spell.Limit)
            {
                if(!MyResistSpell(spell.Caster, spell.Target))
                {
                    //Apply the death effect and the VFX impact
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, eDeath, spell.Target);
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
                }
            }
        }
    }
    else
    {
        spell.Limit = spell.Limit*2;
        //Continue through the while loop while the damage deal is less than 200.
        while(nDamageDealt < spell.Limit)
        {
            //Set nMin higher than the highest HP amount allowed
            nMin = 25;
            oWeakest = OBJECT_INVALID;
            //Get the first target in the spell area
            object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc, TRUE);
            while(GetIsObjectValid(oTarget))
            {
                //Make sure the target avoids all allies.
                if(spellsIsTarget(oTarget, spell.TargetType, spell.Caster))
                {
                    bKill = GetLocalInt(oTarget, "NW_SPELL_PW_KILL_" + GetTag(spell.Caster));
                    //Get the HP of the current target
                    nHitpoints = GetCurrentHitPoints(oTarget);
                    //Check if the currently selected target is lower in HP than the weakest stored creature
                    if((nHitpoints < nMin) && ((nHitpoints > 0) && (nHitpoints <= 20)) && bKill == FALSE)
                    {
                        nMin = nHitpoints;
                        oWeakest = oTarget;
                    }
                }
                //Get next target in the spell area
                oTarget = GetNextObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc, TRUE);
            }
            //If no weak targets are available then break out of the loop
            if(!GetIsObjectValid(oWeakest))
            {
                nDamageDealt = 250;
            }
            else
            {
                fDelay = GetRandomDelay(0.75, 2.0);
                SetLocalInt(oWeakest, "NW_SPELL_PW_KILL_" + GetTag(spell.Caster), TRUE);
                //Fire cast spell at event for the specified target
                SignalEvent(oWeakest, EventSpellCastAt(spell.Caster, spell.Id));
                if(!MyResistSpell(spell.Caster, oWeakest, fDelay))
                {
                    //Apply the VFX impact and death effect
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDeath, oWeakest));
                    if(!GetIsImmune(oWeakest, IMMUNITY_TYPE_DEATH, spell.Caster))
                    {
                        DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oWeakest));
                    }
                    //Add the creatures HP to the total
                    nDamageDealt = nDamageDealt + nMin;
                    string sTag = "NW_SPELL_PW_KILL_" + GetTag(spell.Caster);
                    DelayCommand(fDelay + 0.25, DeleteLocalInt(oWeakest, sTag));
                }
            }
        }
    }
}
