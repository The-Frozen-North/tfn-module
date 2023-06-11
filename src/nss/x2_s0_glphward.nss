//::///////////////////////////////////////////////
//:: Glyph of Warding
//:: X2_S0_GlphWard
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    The caster creates a trapped area which detects
    the entrance of enemy creatures into 3 m area
    around the spell location.  When tripped it
    causes a sonic explosion that does 1d8 per
    two caster levels up to a max of 5d8 damage.

Custom content note:
    vfx_persistent.2da - setting DurationVFX on line 38 to 445 will make the glyph
    visible all times without the placeable workaround.
*/
//:://////////////////////////////////////////////
//:: Created By: Andrew Nobbs
//:: Created On: Dec 04, 2002
//:://////////////////////////////////////////////
/*
Patch 1.72
- added support for customization of the AOE in vfx_persistent
- DC for this spell was always 14
- this spell didn't allow spellcraft saving throw bonus
- will vanish after rest
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void GlyphOfWardingPseudoHB(object oAOE)
{
    //if caster rested or aoe have been dispelled, destroy placeable as well
    if(!GetIsObjectValid(oAOE))
    {
        DestroyObject(OBJECT_SELF);
    }
    else
    {
        DelayCommand(6.0,GlyphOfWardingPseudoHB(oAOE));
    }
}

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DamageCap = 5;
    spell.Dice = 8;
    spell.DamageType = DAMAGE_TYPE_SONIC;
    spell.DurationType = SPELL_DURATION_TYPE_TURNS;
    spell.Range = 5.0;
    spell.SavingThrow = SAVING_THROW_REFLEX;
    spell.TargetType = SPELL_TARGET_STANDARDHOSTILE;

    if(GetObjectType(OBJECT_SELF) == OBJECT_TYPE_AREA_OF_EFFECT)
    {
        //Declare major variables
        aoesDeclareMajorVariables();
        spell.Loc = GetLocation(OBJECT_SELF);
        if(GetLocalInt(aoe.AOE,"DO_ONCE"))
        {
            return;//fix for situation where cast into pack of creatures
        }

        SetLocalInt(aoe.AOE,"DO_ONCE",TRUE);
        object oEntering = GetEnteringObject();
        int nDamage;
        float fDelay;
        int nCasterLevel = spell.Level / 2;
        //Limit caster level
        if(nCasterLevel > spell.DamageCap)
        {
            nCasterLevel = spell.DamageCap;
        }
        else if (nCasterLevel < 1)
        {
            nCasterLevel = 1;
        }

        effect eDam;
        effect eVis = EffectVisualEffect(spell.DmgVfxS);
        effect eExplode = EffectVisualEffect(VFX_FNF_ELECTRIC_EXPLOSION);
        ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eExplode, spell.Loc);

        //Cycle through the targets in the explosion area
        object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc, TRUE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);
        while(GetIsObjectValid(oTarget))
        {
            if(spellsIsTarget(oTarget, spell.TargetType, aoe.Creator))
            {
                //Fire cast spell at event for the specified target
                SignalEvent(oTarget, EventSpellCastAt(aoe.AOE, spell.Id));
                //Get the distance between the explosion and the target to calculate delay
                fDelay = GetDistanceBetweenLocations(spell.Loc, GetLocation(oTarget))/20;
                //Make SR check
                if(!MyResistSpell(aoe.Creator, oTarget, fDelay))
                {
                    nDamage = MaximizeOrEmpower(spell.Dice,nCasterLevel,spell.Meta);
                    //Change damage according to Reflex, Evasion and Improved Evasion
                    nDamage = GetSavingThrowAdjustedDamage(nDamage, oTarget, spell.DC, spell.SavingThrow, spell.SaveType, aoe.Creator);

                    if(nDamage > 0)
                    {
                        //Set up the damage effect
                        eDam = EffectDamage(nDamage, spell.DamageType);
                        //Apply VFX impact and damage effect
                        DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
                        DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget));
                    }
                }
            }
            //Get next target in the sequence
            oTarget = GetNextObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc, TRUE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);
        }
        //VFX placeable holder workaround
        object oPlc = GetLocalObject(aoe.AOE,"VFX_PLACEABLE");
        effect eSearch = GetFirstEffect(oPlc);
        while(GetIsEffectValid(eSearch))
        {
            RemoveEffect(oPlc,eSearch);
            eSearch = GetNextEffect(oPlc);
        }
        //the placeable must be destroyed later in order to VFX could disappear "nicely"
        DestroyObject(oPlc,1.0);
        DestroyObject(aoe.AOE,1.0);
        return;
    }

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();

    //spell cast directly on single target
    if(spell.Target != OBJECT_INVALID && spellsIsTarget(spell.Target, spell.TargetType, spell.Caster))
    {
        int nDamage;
        float fDelay;
        int nCasterLevel = spell.Level / 2;
        //Limit caster level
        if(nCasterLevel > spell.DamageCap)
        {
            nCasterLevel = spell.DamageCap;
        }
        else if (nCasterLevel < 1)
        {
            nCasterLevel = 1;
        }
        effect eDam;
        effect eExplode = EffectVisualEffect(VFX_FNF_ELECTRIC_EXPLOSION);
        effect eVis = EffectVisualEffect(spell.DmgVfxS);
        ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eExplode, spell.Loc);
        //Cycle through the targets in the explosion area
        object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc, TRUE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);
        while(GetIsObjectValid(oTarget))
        {
            if(spellsIsTarget(oTarget, spell.TargetType, spell.Caster))
            {
                //Fire cast spell at event for the specified target
                SignalEvent(oTarget, EventSpellCastAt(spell.Caster, spell.Id));
                //Get the distance between the explosion and the target to calculate delay
                fDelay = GetDistanceBetweenLocations(spell.Loc, GetLocation(oTarget))/20;
                //Make SR check
                if(!MyResistSpell(spell.Caster, oTarget, fDelay))
                {
                    nDamage = MaximizeOrEmpower(spell.Dice,nCasterLevel,spell.Meta);
                    //Change damage according to Reflex, Evasion and Improved Evasion
                    nDamage = GetSavingThrowAdjustedDamage(nDamage, oTarget, spell.DC, spell.SavingThrow, spell.SaveType, spell.Caster);

                    if(nDamage > 0)
                    {
                        //Set up the damage effect
                        eDam = EffectDamage(nDamage, spell.DamageType);
                        //Apply VFX impact and damage effect
                        DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
                        DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget));
                    }
                }
            }
            //Get next target in the sequence
            oTarget = GetNextObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc, TRUE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);
        }
    }
    else
    {
        effect eAOE = EffectAreaOfEffect(AOE_PER_GLYPH_OF_WARDING,"x2_s0_glphward");
        object oGlyph;
        int nTh = 2;
        int nDuration = spell.Level/2;
        if(nDuration < 1)
        {
            nDuration = 1;
        }
        if(spell.Meta & METAMAGIC_EXTEND)
        {
            nDuration *= 2;
        }
        float fDuration = DurationToSeconds(nDuration);
        //disallow player to stack multiple aoes at the same position
        object oAOE = GetNearestObjectToLocation(OBJECT_TYPE_AREA_OF_EFFECT, spell.Loc);
        while(GetIsObjectValid(oAOE) && GetDistanceBetweenLocations(GetLocation(oAOE), spell.Loc) < 4.75)
        {                                                                                   //lets be a little tolerant
            if(GetTag(oAOE) == "VFX_PER_GLYPH")
            {
                //there is already this AoE in near the spell location, the spell thus ends there
                FloatingTextStrRefOnCreature(84612, spell.Caster);
                return;
            }
            oAOE = GetNearestObjectToLocation(OBJECT_TYPE_AREA_OF_EFFECT, spell.Loc, nTh++);
        }
        //should be glyph invisible or not?
        if(!GetLocalInt(GetModule(),"X2_SWITCH_GLYPH_OF_WARDING_INVISIBLE"))
        {
            //if the customized vfx_persistent has visual effect set for Glyph of Warding, there is no need to make it visible
            if(Get2DAString("vfx_persistent","DurationVFX",38) == "")
            {
                //ok it isn't, placeable workaround have to be used then :/
                oGlyph = CreateObject(OBJECT_TYPE_PLACEABLE,"plc_invisobj",spell.Loc,FALSE,"X2_PLC_GLYPH");
                SetPlotFlag(oGlyph,TRUE);
                effect eVis = EffectVisualEffect(VFX_DUR_GLYPH_OF_WARDING);
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eVis, oGlyph, fDuration);
                DestroyObject(oGlyph,fDuration);
            }
        }
        else
        {
            //it should, so let the VFX appear only for a short while like in original script
            eAOE = EffectLinkEffects(eAOE,EffectVisualEffect(VFX_DUR_GLYPH_OF_WARDING));
        }
        //lets make the AOE
        ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eAOE, spell.Loc, fDuration);
        //if the placeable VFX holder was created, it must be set up on the new AOE object in order to destroy it later
        oAOE = spellsSetupNewAOE("VFX_PER_GLYPH");
        if(oGlyph != OBJECT_INVALID)
        {
            SetLocalObject(oAOE,"VFX_PLACEABLE",oGlyph);
            AssignCommand(oGlyph,GlyphOfWardingPseudoHB(oAOE));
        }
    }
}
