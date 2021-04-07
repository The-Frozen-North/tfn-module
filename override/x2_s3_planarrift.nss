//::///////////////////////////////////////////////
//:: OnHit CastSpell: Planarrift
//:: x2_s3_planarrift
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*


*/
//:://////////////////////////////////////////////
//:: Created By: Georg Zoeller
//:: Created On: 2003-07-22
//:://////////////////////////////////////////////
/*
Patch 1.70

- removed death effect on PC that could be countered via death immunity anyway
- added a special immunity workaround to bypass ResistSpell bug
*/

#include "x0_i0_spells"

void main()
{
    object oItem = GetSpellCastItem(); // The item casting triggering this spellscript
    object oSpellTarget = GetSpellTargetObject(); // On a weapon: The one being hit. On an armor: The one hitting the armor
    object oSpellOrigin = OBJECT_SELF; // On a weapon: The one wielding the weapon. On an armor: The one wearing an armor
    object oFeedback = GetMaster(oSpellOrigin);

    if(!GetIsObjectValid(oFeedback))
    {
        oFeedback = oSpellOrigin;
    }

    if(GetIsPC(oSpellOrigin))
    {          // NONONO, player's are not supposed to use this
        return;//removed death effect that could be countered via immunity anyway
    }

    int nDC = 10+GetCasterLevel(oSpellOrigin);

    if(GetIsObjectValid(oItem) && GetIsObjectValid(oSpellTarget))
    {
        if(GetLocalInt(oSpellTarget,"IMMUNITY_PLANAR_RIFT"))
        {
            //special workaround to get proper feedback
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY,EffectSpellImmunity(SPELL_ALL_SPELLS),oSpellTarget,0.01);
            //to be extra sure and avoid exploits...
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY,EffectImmunity(IMMUNITY_TYPE_DEATH),oSpellTarget,0.01);
        }
        if(!MyResistSpell(oFeedback, oSpellTarget))
        {
            if(!FortitudeSave(oSpellTarget, nDC, SAVING_THROW_TYPE_DEATH, oFeedback))
            {
                ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDeath(TRUE), oSpellTarget);
            }
        }
    }
}
