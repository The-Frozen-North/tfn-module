#include "inc_quest"

void main()
{
    AdvanceQuestSphere(OBJECT_SELF, 1);

    SetCommandable(FALSE);

    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_UNSUMMON), GetLocation(OBJECT_SELF));

    DestroyObject(OBJECT_SELF, 3.0);
}
