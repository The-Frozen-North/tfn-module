#include "70_inc_spells"
#include "x0_i0_spells"

// Blacmist (halberd)
// Cast 3/day as AOE blindness (DC 14) around user, affecting everyone (incl. user)
void main()
{
    //Play area impact VFX
    location lLoc = GetLocation(OBJECT_SELF);
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_PULSE_COLD, FALSE, 0.5f), lLoc);
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_GAS_EXPLOSION_GREASE, FALSE, 4.0f, Vector(0.f,0.f,-1.f)), lLoc);

    // create blindness effect with expiration vfx, link them
    effect eBlind =  EffectBlindness();
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eLink = EffectLinkEffects(eBlind, eDur);

    // create impact vfx
    effect eVis = EffectVisualEffect(VFX_IMP_BLIND_DEAF_M);

    //Get the first target in the spell area
    object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_MEDIUM, lLoc, TRUE);
    while (GetIsObjectValid(oTarget))
    {
        //Make Fort save
        if (!MySavingThrow(SAVING_THROW_FORT, oTarget, 14))
        {
            //Apply linked and impact effects
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, RoundsToSeconds(6));
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
        }
        //Get next object in spell area
        oTarget = GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_MEDIUM, lLoc, TRUE);
    }
}
