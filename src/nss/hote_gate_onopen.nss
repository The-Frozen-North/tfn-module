
void CloseSelf(string sUUID)
{
    if (sUUID == GetLocalString(OBJECT_SELF, "LastOpenUUID"))
    {
        ActionCloseDoor(OBJECT_SELF);
        SetLocked(OBJECT_SELF, TRUE);
    }
}


void main()
{
    string sUUID = GetRandomUUID();
    SetLocalString(OBJECT_SELF, "LastOpenUUID", sUUID);
    DelayCommand(30.0f, CloseSelf(sUUID));
}
