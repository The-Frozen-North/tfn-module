#include "inc_henchman"
#include "inc_general"

void main()
{
    FloatingTextStringOnCreature("*Your henchman has died*", GetMaster(OBJECT_SELF), FALSE);
    ClearMaster(OBJECT_SELF);

    KillTaunt(GetLastHostileActor(OBJECT_SELF), OBJECT_SELF);

    location lLocation = GetLocation(OBJECT_SELF);

    effect eVis = EffectVisualEffect(VFX_IMP_RESTORATION);
    AssignCommand(GetModule(), DelayCommand(3.0, ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eVis, lLocation)));
    GibsNPC(OBJECT_SELF);
}
