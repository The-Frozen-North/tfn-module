#include "inc_follower"
#include "x0_i0_spells"

void main()
{
     if (GetIsDead(OBJECT_SELF)) return;
     if (GetHasEffect(EFFECT_TYPE_PETRIFY, OBJECT_SELF)) return;

     CheckOrRehireFollowerMasterAssignment(OBJECT_SELF);
}
