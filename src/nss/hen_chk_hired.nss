int StartingConditional()
{
// Check if the henchman is hired by someone else...

    string sMaster = GetLocalString(GetModule(), GetResRef(OBJECT_SELF)+"_master");

// no master
    if (sMaster == "") return FALSE;

// correct master
    if (sMaster == GetObjectUUID(GetPCSpeaker())) return FALSE;

    return TRUE;

}
