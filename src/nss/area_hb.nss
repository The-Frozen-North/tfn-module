#include "inc_debug"

void main()
{

// item clean up
    object oItem = GetFirstObjectInArea(OBJECT_SELF);
    int nDestroyCount;
    while (GetIsObjectValid(oItem))
    {
        if(GetObjectType(oItem) == OBJECT_TYPE_ITEM )
        {
            nDestroyCount = GetLocalInt(oItem, "destroy_count");
            if (nDestroyCount == 50)
            {
                DestroyObject(oItem);
            }
            else
            {
                SetLocalInt(oItem, "destroy_count", nDestroyCount+1);
            }
        }
        oItem = GetNextObjectInArea(OBJECT_SELF);
    }

// execute the heartbeat script if there is one
    string sScript = GetLocalString(OBJECT_SELF, "heartbeat_script");
    if (sScript != "") ExecuteScript(sScript, OBJECT_SELF);
}
