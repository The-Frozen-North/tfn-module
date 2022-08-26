void Unlock()
{
    SetLocked(OBJECT_SELF, 0);
    ActionOpenDoor(OBJECT_SELF);
    SpeakString("With the death of the mummy, the door creaks open on its own.");
}

void main()
{
    object oDoor = GetObjectByTag("beg_warren_innerdoor");
    AssignCommand(oDoor, Unlock());
}
