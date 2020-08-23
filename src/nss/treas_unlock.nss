void main()
{
    if (GetObjectType(GetLastUnlocked()) == OBJECT_TYPE_CREATURE) PlaySound("gui_picklockopen");

// if it unlocked, then we can use the treasure opening script
    SetEventScript(OBJECT_SELF, EVENT_SCRIPT_PLACEABLE_ON_USED, "treas_fopen");
    SetEventScript(OBJECT_SELF, EVENT_SCRIPT_PLACEABLE_ON_MELEEATTACKED, "");
    SetPlotFlag(OBJECT_SELF, TRUE);
}
