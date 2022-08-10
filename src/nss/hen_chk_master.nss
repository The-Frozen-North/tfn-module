#include "inc_henchman"

int StartingConditional()
{
// Check if speaker is the master of the henchman

    string sMaster = GetLocalString(GetModule(), GetResRef(OBJECT_SELF)+"_master");
    object oPC = GetPCSpeaker();

// no master
    if (sMaster == "") return FALSE;

// incorrect master
    if (sMaster != GetObjectUUID(oPC)) return FALSE;
    
    // After curing petrification, this will add them back to the party
    if (!GetIsObjectValid(GetMaster(OBJECT_SELF)))
    {
        SetMaster(OBJECT_SELF, oPC);
    }

    return TRUE;

}
