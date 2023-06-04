#include "nw_inc_nui"

void main()
{
    object oPC = NuiGetEventPlayer();

    string sWindow = NuiGetWindowId(oPC, NuiGetEventWindow());
    ExecuteScript(sWindow + "_evt");

    if (GetResRef(GetArea(oPC)) == "blak_divine")
    {
        ExecuteScript("tmog_nui_event");
    }
}
