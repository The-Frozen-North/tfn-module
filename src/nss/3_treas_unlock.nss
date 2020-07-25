void main()
{
// if it unlocked, then we can use the treasure opening script
    SetEventScript(OBJECT_SELF, EVENT_SCRIPT_PLACEABLE_ON_USED, "3_treas_fopen");
    SetEventScript(OBJECT_SELF, EVENT_SCRIPT_PLACEABLE_ON_MELEEATTACKED, "");
    SetPlotFlag(OBJECT_SELF, TRUE);
}
