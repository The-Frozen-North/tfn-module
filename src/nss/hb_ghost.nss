#include "nw_i0_generic"

void main()
{
    if (GetHasEffect(EFFECT_TYPE_CUTSCENEGHOST, OBJECT_SELF)) return;
    
    ApplyEffectToObject(DURATION_TYPE_PERMANENT, SupernaturalEffect(EffectCutsceneGhost()), OBJECT_SELF);
}
