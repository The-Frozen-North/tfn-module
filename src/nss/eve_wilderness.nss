#include "inc_debug"
#include "inc_event"

void main()
{
    string sScript;
    int nRoll = Random(10);
    sScript = "eve_ranger";
    if (nRoll == 0)
        sScript = "eve_bears";
    else if (nRoll == 1)
        sScript = "eve_wolves";
    else if (nRoll == 2)
        sScript = "eve_travelmer";
    else if (nRoll == 3)
        sScript = "eve_ranger";
    else if (nRoll == 4 && GetStringLeft(GetResRef(GetArea(OBJECT_SELF)), 2) == "nw")
    {
        if (d2() == 1)
            sScript = "eve_militia";
        else
            sScript = "eve_neverwinter";
    }
    else if (nRoll <= 8)
        sScript = "eve_advparty";
    else
        sScript = "eve_adventure";

    ExecuteScript(sScript);

    SendDebugMessage("event script executed: "+sScript, TRUE);
}
