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
        else if (!GetLockKeyRequired(OBJECT_SELF) && !GetIsInCombat(oPC) && GetSkillRank(SKILL_OPEN_LOCK, oPC, TRUE) > 0 && ((GetSkillRank(SKILL_OPEN_LOCK, oPC)+20) >= GetLockLockDC(OBJECT_SELF)))
        {
            //PlaySound("as_sw_genericlk1");
            //FloatingTextStringOnCreature("*locked*", oPC, FALSE);

            // can't use object self or it attempts to unlock yourself
            object oDoor = OBJECT_SELF;
            AssignCommand(oPC, ActionUnlockObject(oDoor));
        }
        /*
        else
        {
            PlaySound("as_sw_genericlk1");
            FloatingTextStringOnCreature("*locked*", oPC, FALSE);    
        }
        */
    }
    string sScript = GetLocalString(OBJECT_SELF, "onfailtoopen_script");
    if (sScript != "")
    {
        ExecuteScript(sScript, OBJECT_SELF);
    }
}
