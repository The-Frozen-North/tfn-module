void main()
{
    SetName(OBJECT_SELF, "Underdark");

    SetLocalInt(OBJECT_SELF, "underdark", 1);

    DeleteLocalString(OBJECT_SELF, "refresh_script"); // do this only once
}
