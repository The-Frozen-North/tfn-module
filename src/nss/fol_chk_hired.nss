#include "inc_follower"
#include "inc_quest"

int StartingConditional()
{
    object oPC = GetPCSpeaker();

// if PC hasn't finished academy, don't continue
    if (!GetIsAtQuestStage(OBJECT_SELF, oPC, 1)) return FALSE;

// Check if the henchman is hired by someone else...
    string sMaster = GetLocalString(OBJECT_SELF, "master");

// no master
    if (sMaster == "") return FALSE;

// correct master?
    if (sMaster == GetObjectUUID(oPC)) return FALSE;

// only arrive here if incorrect master and passed academy
    return TRUE;

}
