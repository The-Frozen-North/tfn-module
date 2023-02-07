#include "inc_debug"
#include "inc_horse"
#include "inc_persist"
#include "inc_quest"
#include "inc_restxp"

void WarningMessage(object oPC)
{
    string sMessage = "";
    int nQuest = GetQuestEntry(oPC, "q_wailing");

    if (nQuest == 4 && GetQuestEntry(oPC, "q_sword_coast_boys") == 4 && GetQuestEntry(oPC, "q_prison_riot") == 4 && GetQuestEntry(oPC, "q_undead_infestation") == 4)
    {
        sMessage = "You should return to the academy and speak to Sedos as the districts are now in order.";
    }
    else if (nQuest < 2)
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

       // Texture overrides
       string sScript = GetLocalString(OBJECT_SELF, "texoverride_script");
       if (sScript != "")
       {
           SetScriptParam("pc", ObjectToString(oPC));
           SetScriptParam("action", "load");
           ExecuteScript(sScript, OBJECT_SELF);
       }
       
       // This should help confirm the rollback issue is due to NWNX_Creature_GetIsBartering returning true when it shouldn't
       if (!CanSavePCInfo(oPC))
       {
           string sFeedback = GetLocalString(GetModule(), UNABLE_TO_SAVE_INFO);
           DelayCommand(1.0, FloatingTextStringOnCreature(sFeedback, oPC, FALSE));
       }
       if (NWNX_Creature_GetIsBartering(oPC))
       {
           // Force a save on area enter. It shouldn't be possible to actually be bartering here
           SetLocalInt(oPC, IGNORE_BARTER_SAVE_CHECK, 1);
           ExportSingleCharacter(oPC);
       }

       SendDebugMessage(PlayerDetailedName(oPC)+" has entered "+GetName(OBJECT_SELF)+", tag: "+GetTag(OBJECT_SELF)+", resref: "+GetResRef(OBJECT_SELF)+", climate: "+GetLocalString(OBJECT_SELF, "climate"));

       ValidateMount(oPC);

       UpdateQuestgiverHighlights(OBJECT_SELF, oPC);

       if (PlayerGetsRestedXPInArea(oPC, OBJECT_SELF))
        {
            SendOnEnterRestedPopup(oPC);
        }

       if (GetLocalInt(OBJECT_SELF, "underdark") == 1 && !GetIsDM(oPC))
       {
           SetGuiPanelDisabled(oPC, GUI_PANEL_MINIMAP, TRUE);
       }
       else
       {
           SetGuiPanelDisabled(oPC, GUI_PANEL_MINIMAP, FALSE);

           if (GetLocalInt(OBJECT_SELF, "explored") == 1)
           {
                ExploreAreaForPlayer(OBJECT_SELF, oPC);
           }
           else if (GetLocalInt(OBJECT_SELF, "underdark") != 1)
           {
                ImportMinimap(oPC);
           }
       }

       sScript = GetLocalString(OBJECT_SELF, "enter_script");
       if (sScript != "") ExecuteScript(sScript, OBJECT_SELF);

       //if (GetLocalInt(OBJECT_SELF, "instance") == 1)
       //{
           //string sResRef = GetResRef(OBJECT_SELF);

           int nRefresh = GetLocalInt(OBJECT_SELF, "refresh");
           if (nRefresh == 0)
           {
                SendDebugMessage(GetResRef(OBJECT_SELF)+" refresh started", TRUE);
                SetLocalInt(OBJECT_SELF, "refresh", 1);
           }
       //}
}

