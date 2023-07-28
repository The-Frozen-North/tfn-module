#include "inc_henchman"
#include "j_inc_spawnin"

void main()
{
     CheckMasterAssignment(OBJECT_SELF);
     ScaleHenchman(OBJECT_SELF);

     // we may level up the henchman and set new spells, so we should set their spells up again
     if (ScaleHenchman(OBJECT_SELF))
     {
          AI_SetUpSpells();
     }
}
