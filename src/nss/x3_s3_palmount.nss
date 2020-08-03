#include "inc_horse"

void main()
{
    if (GetIsMounted(OBJECT_SELF))
    {
        RemoveMount(OBJECT_SELF);
    }
    else if (GetIsInCombat(OBJECT_SELF))
    {
        FloatingTextStringOnCreature("*You cannot mount your horse in combat!*", OBJECT_SELF, FALSE);
    }
    else
    {
        ApplyMount(OBJECT_SELF, 24);
    }

    IncrementRemainingFeatUses(OBJECT_SELF, FEAT_PALADIN_SUMMON_MOUNT);
}
