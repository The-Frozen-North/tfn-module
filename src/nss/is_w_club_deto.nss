#include "70_inc_spells"

// Club of Detonation
// 20% chance for 1d8 fire damage
// 5% chance for 2d8 AOE fireball
// (hurts everyone, allows reflex save to all but original target)
void main()
{
    object oTarget = GetSpellTargetObject();
    if (GetIsObjectValid(oTarget))
    {
        int nRand = Random(100);
        if (nRand < 5)
        {
            // Get location and play fireball VFX
            location lTarget = GetLocation(oTarget);
            effect eExplode = EffectVisualEffect(VFX_FNF_FIREBALL);
            ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eExplode, lTarget);

            // Create variables to use for victims
            effect eVis = EffectVisualEffect(VFX_IMP_FLAME_M);
            effect eDam;
            int nDam;
            int nDC = 14;
            float fDelay;

            // Get first target
            object oVictim = FIX_GetFirstObjectInShape(
                SHAPE_SPHERE,
                RADIUS_SIZE_HUGE,
                lTarget,
                TRUE,
                OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE
            );

            //Cycle through the targets within the spell shape until an invalid object is captured.
            while (GetIsObjectValid(oVictim))
            {
                //Don't hit dead things
                if (!GetIsDead(oVictim))
                {
                    //Roll damage
                    nDam = d8(2);
                    if (oVictim != oTarget)
                    {
                        //Adjust the damage based on the Reflex Save, Evasion and Improved Evasion.
                        nDam = GetSavingThrowAdjustedDamage(nDam, oVictim, nDC, SAVING_THROW_REFLEX, SAVING_THROW_TYPE_FIRE);
                    }

                    if (nDam > 0)
                    {
                        //Set the damage effect
                        eDam = EffectDamage(nDam, DAMAGE_TYPE_FIRE);

                        //Get the distance between the explosion and the target to calculate delay
                        fDelay = GetDistanceBetweenLocations(lTarget, GetLocation(oVictim))/20;

                        //Apply damage and VFX with delay
                        DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oVictim));
                        DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oVictim));
                    }
                }

                // Get next target
                oVictim = FIX_GetNextObjectInShape(
                    SHAPE_SPHERE,
                    RADIUS_SIZE_HUGE,
                    lTarget,
                    TRUE,
                    OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE
                );
            }
        }
        else if (nRand < 25)
        {
            effect eDmg = EffectLinkEffects(
                EffectVisualEffect(VFX_IMP_FLAME_S),
                EffectDamage(d8(), DAMAGE_TYPE_FIRE)
            );
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eDmg, oTarget);
        }
    }
}
