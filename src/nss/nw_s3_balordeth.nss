//::///////////////////////////////////////////////
//:: Balor On Death
//:: NW_S3_BALORDETH
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Fireball explosion does 50 damage to all within
    20ft
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Jan 9, 2002
//:://////////////////////////////////////////////
/*
Patch 1.72
- script will additionally run default OnDeath script handler for npcs
Patch 1.71
- fixed spell resistance issue that in certain situation blocked damage application
*/

#include "70_inc_spells"
#include "nw_i0_spells"

void main()
{
    //Declare major variables
    object oCaster = OBJECT_SELF;
    int nMetaMagic = GetMetaMagicFeat();
    int nDamage;
    float fDelay;
    effect eExplode = EffectVisualEffect(VFX_FNF_FIREBALL);
    effect eVis = EffectVisualEffect(VFX_IMP_FLAME_M);
    effect eDam;
    //Get the spell target location as opposed to the spell target.
    location lTarget = GetLocation(OBJECT_SELF);
    //Limit Caster level for the purposes of damage
    //Apply the fireball explosion at the location captured above.
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eExplode, lTarget);
    //Declare the spell shape, size and the location.  Capture the first target object in the shape.
    object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_HUGE, lTarget, TRUE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR);
    //Cycle through the targets within the spell shape until an invalid object is captured.
    while (GetIsObjectValid(oTarget))
    {
       //Fire cast spell at event for the specified target
        SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELL_FIREBALL));
        //Get the distance between the explosion and the target to calculate delay
        fDelay = GetDistanceBetweenLocations(lTarget, GetLocation(oTarget))/20;
        if (MyResistSpell(OBJECT_SELF, oTarget, fDelay) <= 0)
        {
            //Adjust the damage based on the Reflex Save, Evasion and Improved Evasion.
            nDamage = GetSavingThrowAdjustedDamage(50, oTarget, GetSpellSaveDC(), SAVING_THROW_REFLEX, SAVING_THROW_TYPE_FIRE);
            //Set the damage effect
            eDam = EffectDamage(nDamage, DAMAGE_TYPE_FIRE);
            if(nDamage > 0)
            {
                // Apply effects to the currently selected target.
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget));
                //This visual effect is applied to the target object not the location as above.  This visual effect
                //represents the flame that erupts on the target not on the ground.
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
            }
         }
       //Select the next target within the spell shape.
       oTarget = GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_HUGE, lTarget, TRUE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR);
    }

    //1.72: checking this is neccessary in order to avoid endless loop that would lock down game
    //in a case where user would already do this but the other way around, ie. executing this
    //script from nw_c2_default7
    if(GetEventScript(OBJECT_SELF,EVENT_SCRIPT_CREATURE_ON_DEATH) == "nw_s3_balordeth")
    {
        ExecuteScript(GetAssociateType(OBJECT_SELF) == ASSOCIATE_TYPE_NONE ? "nw_c2_default7" : "nw_ch_ac7",OBJECT_SELF);
    }
}
