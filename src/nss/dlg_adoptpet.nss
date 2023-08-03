#include "inc_housing"

void main()
{
    object oPC = GetPCSpeaker();

    AssignCommand(oPC, ActionPlayAnimation(ANIMATION_LOOPING_GET_LOW));

    AdoptPet(oPC, OBJECT_SELF);

    ActionMoveAwayFromLocation(GetLocation(OBJECT_SELF), TRUE);
    DestroyObject(OBJECT_SELF, 3.0);
}
