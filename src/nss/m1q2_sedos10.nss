#include "NW_I0_PLOT"

int StartingConditional()
{
    object oReagent = GetItemPossessedBy(GetPCSpeaker(),"M1Q2PlotReagent");
    if (!GetIsObjectValid(oReagent))
    {
        return CheckIntelligenceLow();
    }
    return FALSE;
}
