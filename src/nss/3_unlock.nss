void main()
{
    object oUnlocker = GetLastUnlocked();

    if (GetObjectType(oUnlocker) == OBJECT_TYPE_CREATURE) PlaySound("gui_picklockopen");
}
