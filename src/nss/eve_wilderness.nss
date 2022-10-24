#include "inc_debug"
#include "inc_event"

void main()
{
    string sScript;
    sScript = "eve_ranger";

    switch (d10())
    {
        case 1: sScript = "eve_adventure"; break;
        case 2: sScript = "eve_adventure"; break;
        case 3: sScript = "eve_bears"; break;
        case 4: sScript = "eve_militia"; break;
        case 5: sScript = "eve_adventure"; break;
        case 6: sScript = "eve_advparty"; break;
        case 7: sScript = "eve_travelmer"; break;
        case 8: sScript = "eve_wolves"; break;
        case 9:
            if (GetStringLeft(GetResRef(GetArea(OBJECT_SELF)), 2) == "nw")
                sScript = "eve_neverwinter";
        break;
        case 10: sScript = "eve_ranger"; break;
    }

    ExecuteScript(sScript);

    SendDebugMessage("event script executed: "+sScript, TRUE);
}
