#include "inc_general"

void main()
{
    string sCompleted = "Incompleted at ";
    if (GetLocalInt(OBJECT_SELF, "completed") == 1) sCompleted = "Completed at ";
    SpeakString(sCompleted+"Count: "+IntToString(GetLocalInt(OBJECT_SELF, "count")), TALKVOLUME_SHOUT);

    if (GetLocalInt(OBJECT_SELF, "completed") == 1) SetEventScript(OBJECT_SELF, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, "");
}
