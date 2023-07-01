#include "nw_i0_spells"

void main()
{
    object oDamager = GetLastDamager();
    int bTagForCredit = FALSE;

// if not a PC, attempt to get the master
    if (!GetIsPC(oDamager))
    {
        oDamager = GetMaster(oDamager);
    }

// tag any creatures for credit if it came from a PC
    if (GetLocalInt(OBJECT_SELF, "fire_pc_tagged") || GetIsPC(oDamager))
    {
        bTagForCredit = TRUE;
    }

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
    object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_HUGE, lTarget, TRUE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);
    //Cycle through the targets within the spell shape until an invalid object is captured.
    while (GetIsObjectValid(oTarget))
    {

        // if there was a chain reaction to other barrels, also set it on those
        SetLocalInt(oTarget, "fire_pc_tagged", 1);

        if (bTagForCredit && !GetIsPC(oTarget))
        {
             SetLocalInt(oTarget, "player_tagged", 1);
        }

        //Get the distance between the explosion and the target to calculate delay
        fDelay = GetDistanceBetweenLocations(lTarget, GetLocation(oTarget))/20;

        //Adjust the damage based on the Reflex Save, Evasion and Improved Evasion.
        nDamage = GetSavingThrowAdjustedDamage(d6(5), oTarget, 14, SAVING_THROW_REFLEX, SAVING_THROW_TYPE_FIRE);
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

       //Select the next target within the spell shape.
       oTarget = GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_HUGE, lTarget, TRUE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);
    }

    object oRemains = CreateObject(OBJECT_TYPE_PLACEABLE, "_scorch_mark", lTarget);
    AssignCommand(oRemains, SetFacing(IntToFloat(Random(360))));

    AssignCommand(GetModule(), DelayCommand(180.0, DestroyObject(oRemains)));
}
