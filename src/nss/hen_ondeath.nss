#include "inc_henchman"
#include "inc_general"

void main()
{
    FloatingTextStringOnCreature("*Your henchman has died*", GetMaster(OBJECT_SELF), FALSE);

    KillTaunt(GetLastHostileActor(OBJECT_SELF), OBJECT_SELF);
}
