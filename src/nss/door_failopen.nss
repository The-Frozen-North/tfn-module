#include "inc_key"
#include "inc_general"

void main()
{
    object oPC = GetClickingObject();
    ExecuteScript("remove_invis", oPC);
    string sKeyTag = GetLockKeyTag(OBJECT_SELF);
    if (GetIsPC(oPC))
    {
        if (GetHasKey(oPC, sKeyTag))
        {
            SendMessageToPC(oPC, "You open the lock with the " + GetKeyName(sKeyTag) + " in your key bag.");
            IncrementPlayerStatistic(oPC, "key_doors_opened");
            SetLocked(OBJECT_SELF, FALSE);
            AssignCommand(OBJECT_SELF, ActionOpenDoor(OBJECT_SELF));
            
            string sScript = GetLocalString(OBJECT_SELF, "onopen_script");
            if (sScript != "")
            {
                ExecuteScript(sScript, OBJECT_SELF);
            }
        }
    }
    string sScript = GetLocalString(OBJECT_SELF, "onfailtoopen_script");
    if (sScript != "")
    {
        ExecuteScript(sScript, OBJECT_SELF);
    }
}
