#include "nw_i0_generic"

void main()
{
    if (GetHasEffect(EFFECT_TYPE_CUTSCENEGHOST, OBJECT_SELF)) return;

    effect eLink = EffectLinkEffects(EffectCutsceneGhost(), EffectConcealment(50));
    ApplyEffectToObject(DURATION_TYPE_PERMANENT, SupernaturalEffect(eLink), OBJECT_SELF);
}
