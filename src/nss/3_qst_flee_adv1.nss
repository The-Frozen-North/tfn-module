#include "1_inc_quest"

void main()
{
    AdvanceQuestSphere(OBJECT_SELF, 1);

    ActionMoveToObject(GetWaypointByTag("EXIT_"+GetTag(OBJECT_SELF)));
    ActionDoCommand(DestroyObject(OBJECT_SELF));
    SetCommandable(FALSE);
}
