#include "1_inc_quest"

void main()
{
      if (GetIsCurrentlyAtQuestStage(OBJECT_SELF, GetPCSpeaker(), 1))
      {
        SetLocked(OBJECT_SELF, FALSE);
        AssignCommand(OBJECT_SELF, ActionOpenDoor(OBJECT_SELF));
      }
}
