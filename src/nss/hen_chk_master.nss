int StartingConditional()
{
// Check if speaker is the master of the henchman

    string sMaster = GetLocalString(GetModule(), GetResRef(OBJECT_SELF)+"_master");

// no master
    if (sMaster == "") return FALSE;

// incorrect master
    if (sMaster != GetObjectUUID(GetPCSpeaker())) return FALSE;

    return TRUE;

}
