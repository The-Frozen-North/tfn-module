#include "x0_i0_spells"
#include "inc_itemevent"

void main()
{
    if (GetCurrentItemEventType() == ITEM_EVENT_ACTIVATED)
    {
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_PULSE_COLD), OBJECT_SELF);
        location lSelf = GetLocation(OBJECT_SELF);
        object oTest = GetFirstObjectInShape(SHAPE_SPHERE, 5.0, lSelf, TRUE);
        while (GetIsObjectValid(oTest))
        {
            if (spellsIsTarget(oTest, SPELL_TARGET_STANDARDHOSTILE, OBJECT_SELF))
            {
                int nDmg = GetSavingThrowAdjustedDamage(d6(3), oTest, 16, SAVING_THROW_REFLEX, SAVING_THROW_TYPE_COLD);
                if (nDmg > 0)
                {
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_FROST_S), oTest);
                    DelayCommand(0.0, ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(nDmg, DAMAGE_TYPE_COLD), oTest));
                }
            }
            oTest = GetNextObjectInShape(SHAPE_SPHERE, 5.0, lSelf, TRUE);
        }
    }
}
