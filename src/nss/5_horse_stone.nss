#include "1_inc_horse"

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
        ApplyMount(OBJECT_SELF, GetLocalInt(GetItemActivated(), "horse"));
    }
}
