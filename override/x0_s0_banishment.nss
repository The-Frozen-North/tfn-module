//::///////////////////////////////////////////////
//:: Banishment
//:: x0_s0_banishment.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    All summoned creatures within 30ft of caster
    make a save and SR check or be banished
    + As well any Outsiders being must make a
    save and SR check or be banished (up to
    2 HD creatures / level can be banished)
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Oct 22, 2001
//:://////////////////////////////////////////////
//:: VFX Pass By: Preston W, On: June 20, 2001
/*
Patch 1.70

- area of effect was implemented around the caster (visually not correct because you can cast it at distant location)
- HD Pool was lowered only in case that target resisted the spell or suceeded in save
- killing method could fail in special case (magic damage immune/resistant + death magic immune)
- added delay as its usual in other similar spells
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.Range = RADIUS_SIZE_COLOSSAL;
    spell.SavingThrow = SAVING_THROW_WILL;
    spell.TargetType = SPELL_TARGET_STANDARDHOSTILE;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    //the only proper way how to slain even those extra resistant beasts
    effect eDeath = SupernaturalEffect(EffectDeath(FALSE, FALSE));
    effect eVis = EffectVisualEffect(VFX_IMP_UNSUMMON);
    // * the pool is the number of hit dice of creatures that can be banished
    int nPool = 2* spell.Level;
    float fDelay;

    effect eImpact = EffectVisualEffect(VFX_FNF_LOS_EVIL_30);
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImpact, spell.Loc);

    //Get the first object in the are of effect
    object oTarget = FIX_GetFirstObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc, TRUE);
    while(GetIsObjectValid(oTarget))
    {
        if(nPool > 0 && (GetAssociateType(oTarget) == ASSOCIATE_TYPE_SUMMONED ||
                         GetAssociateType(oTarget) == ASSOCIATE_TYPE_FAMILIAR ||
                         GetAssociateType(oTarget) ==  ASSOCIATE_TYPE_ANIMALCOMPANION ||
                         spellsIsRacialType(oTarget, RACIAL_TYPE_OUTSIDER)))
        {
            // * March 2003. Added a check so that 'friendlies' will not be
            // * unsummoned.
            if (spellsIsTarget(oTarget, spell.TargetType, spell.Caster))
            {
                //signal spell cast event even though the creature doesn't have to be affected (HD limit)
                SignalEvent(oTarget, EventSpellCastAt(spell.Caster, spell.Id));
                // * Must be enough points in the pool to destroy target
                if (nPool >= GetHitDice(oTarget))
                {
                    //HD pool must be lowered even if the target resist the effect
                    nPool = nPool - GetHitDice(oTarget);
                    //random delay so each creature is killed in different moment
                    fDelay = GetRandomDelay();
                    // * Make SR and will save checks
                    if (!MyResistSpell(spell.Caster, oTarget, fDelay) && !MySavingThrow(spell.SavingThrow, oTarget, spell.DC, SAVING_THROW_TYPE_NONE, spell.Caster, fDelay))
                    {
                        //Apply the unsummon VFX
                        DelayCommand(fDelay, ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eVis, GetLocation(oTarget)));
                        //Apply the death effect, in order to get feedback, XP, and run creature death script
                        DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDeath, oTarget));
                        if (CanCreatureBeDestroyed(oTarget) && !GetIsPC(oTarget))
                        {
                            //don't try to destroy outsider PCs, it should fail, but we can still exclude them for sure
                            DestroyObject(oTarget, fDelay+0.05);
                        }
                    }
                }
            }
        }
        //Get next creature in the shape.
        oTarget = FIX_GetNextObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc, TRUE);
    }
}
