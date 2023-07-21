#include "nw_inc_nui"
#include "inc_housing"

void main()
{
    object oPC = NuiGetEventPlayer();

    string sWindow = NuiGetWindowId(oPC, NuiGetEventWindow());
    // Sometimes there are reasons why you might want to throw a window's events
    // through a different event script, nice to have the option
    json jUserData = NuiGetUserData(oPC, NuiGetEventWindow());
    json jScript = JsonObjectGet(jUserData, "event_script");
    if (jScript != JsonNull())
    {
        ExecuteScript(JsonGetString(jScript));
    }
    else
    {
        ExecuteScript(sWindow + "_evt");
    }



    if (GetResRef(GetArea(oPC)) == "blak_divine")
    {
        ExecuteScript("tmog_nui_event");
    }
    else if (GetHomeTag(oPC) == GetTag(GetArea(oPC)))
    {
        ExecuteScript("placeable_nui");
    }
}
