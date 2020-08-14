#include "inc_follower"
#include "inc_quest"

int StartingConditional()
{
    object oPC = GetPCSpeaker();

// Check if the henchman is hired by someone else...
    string sMaster = GetLocalString(OBJECT_SELF, "master");

// no master
    if (sMaster == "") return FALSE;

// correct master?
    if (sMaster == GetObjectUUID(oPC)) return FALSE;

    return TRUE;

}
