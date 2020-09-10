#include "inc_debug"
#include "inc_horse"
#include "inc_persist"
#include "inc_quest"

void WarningMessage(object oPC)
{
    string sMessage = "";
    int nQuest = GetQuestEntry(oPC, "q_wailing");

    if (nQuest < 2)
    {
        sMessage = "You should return to the academy and speak to Sedos.";
    }
    else if (nQuest < 3)
    {
        sMessage = "You should return to the academy and head downstairs to Harben to complete your training.";
    }
    else if (nQuest < 4)
    {
        sMessage = "You should return to the academy and speak to Sedos to get your first mission.";
    }
    else
    {
        return;
    }

    if (sMessage != "") FloatingTextStringOnCreature(sMessage, oPC, FALSE);

}


void main()
{
       object oPC = GetEnteringObject();

// only trigger this for PCs
       if (!GetIsPC(oPC)) return;

       string sResRef = GetStringLeft(GetResRef(OBJECT_SELF), 4);
       if (sResRef != "acad") DelayCommand(0.5, WarningMessage(oPC));

       SendDebugMessage(PlayerDetailedName(oPC)+" has entered "+GetName(OBJECT_SELF)+", tag: "+GetTag(OBJECT_SELF)+", resref: "+GetResRef(OBJECT_SELF), TRUE);

       SetStandardFactionReputation(STANDARD_FACTION_COMMONER, 50, oPC);
       SetStandardFactionReputation(STANDARD_FACTION_MERCHANT, 50, oPC);
       SetStandardFactionReputation(STANDARD_FACTION_DEFENDER, 50, oPC);

       ValidateMount(oPC);

       if (GetLocalInt(OBJECT_SELF, "explored") == 1)
       {
            ExploreAreaForPlayer(OBJECT_SELF, oPC);
       }
       else
       {
            ImportMinimap(oPC);
       }

       string sScript = GetLocalString(OBJECT_SELF, "enter_script");
       if (sScript != "") ExecuteScript(sScript, OBJECT_SELF);

       if (GetLocalInt(OBJECT_SELF, "instance") == 1)
       {
           string sResRef = GetResRef(OBJECT_SELF);

           int nRefresh = GetLocalInt(OBJECT_SELF, "refresh");
           if (nRefresh == 0)
           {
                SendDebugMessage(sResRef+" refresh started", TRUE);
                SetLocalInt(OBJECT_SELF, "refresh", 1);
           }
       }
}

