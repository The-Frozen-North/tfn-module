//:://////////////////////////////////////////////////
//:: X0_O2_SEC_DOOR2
//::    This is an OnEntered script for a generic trigger.
//::    When a PC enters the trigger area, it will perform
//::    a check to determine if the secret item is revealed,
//::    then make it appear if so.
//::
//::    Secret item to be revealed: Secret Stone Door
//::    Checking for: SKILL_SEARCH
//::
//:: Copyright (c) 2002 Floodgate Entertainment
//:: Created By: Naomi Novik
//:: Created On: 12/08/2002
//:://////////////////////////////////////////////////

#include "x0_i0_secret"

void CPP_DetectSecretItem_pseudo(object oPC, object oDetectTrigger=OBJECT_SELF, int nSkillType=SKILL_SEARCH)
{
    string sVarName = "PseudoRunning_"+ObjectToString(oPC);
    if (!GetIsObjectValid(oPC) || !GetIsObjectValid(oDetectTrigger) || GetIsSecretItemRevealed(oDetectTrigger) || !GetIsInSubArea(oPC,oDetectTrigger))
    {
        //SendMessageToPC(GetFirstPC(),"FIX_DetectSecretItem: Exit 2");
        SetLocalInt(oDetectTrigger, sVarName, FALSE);
        return;
    }
    //SendMessageToPC(GetFirstPC(),"FIX_DetectSecretItem: making roll");
    if (QuickDetectSecret(oPC, oDetectTrigger) || (GetSkillRank(nSkillType, oPC) + d20() > StringToInt(GetLockKeyTag(oDetectTrigger))))
    {
        //SendMessageToPC(GetFirstPC(),"FIX_DetectSecretItem: Found!");
        // Mark the PC as having found it
        SetLocalInt(oPC, sFoundPrefix + GetTag(oDetectTrigger), TRUE);

        if (!GetIsPC(oPC))
        {
            // If a henchman, alert the PC if we make the detect check
            object oMaster = GetMaster(oPC);
            if (GetIsObjectValid(oMaster) && oPC == GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oMaster))
            {
                AssignCommand(oPC, PlayVoiceChat(VOICE_CHAT_SEARCH));
            }
        }
        else
        {
            // It's a PC, reveal the item
            AssignCommand(oPC, PlayVoiceChat(VOICE_CHAT_LOOKHERE));
            RevealSecretItem("x0_sec_door1");
        }
        SetLocalInt(oDetectTrigger, sVarName, FALSE);
        return;
    }
    //SendMessageToPC(GetFirstPC(),"FIX_DetectSecretItem: running pseudo");
    SetLocalInt(oDetectTrigger, sVarName, TRUE);
    float fDelay = GetActionMode(oPC, ACTION_MODE_DETECT) ? 3.0 : 6.0;
    DelayCommand(fDelay, CPP_DetectSecretItem_pseudo(oPC, oDetectTrigger, nSkillType));
}

void CPP_DetectSecretItem(object oPC, object oDetectTrigger=OBJECT_SELF, int nSkillType=SKILL_SEARCH)
{
    string sVarName = "PseudoRunning_"+ObjectToString(oPC);
    if (!GetIsObjectValid(oPC) || !GetIsObjectValid(oDetectTrigger) || GetIsSecretItemRevealed(oDetectTrigger) || !GetIsInSubArea(oPC,oDetectTrigger))
    {
        //SendMessageToPC(GetFirstPC(),"FIX_DetectSecretItem: Exit 0");
        SetLocalInt(oDetectTrigger, sVarName, FALSE);
        return;
    }
    if(GetLocalInt(oDetectTrigger, sVarName))
    {
        //SendMessageToPC(GetFirstPC(),"FIX_DetectSecretItem: Exit 1");
        return;
    }
    //SendMessageToPC(GetFirstPC(),"FIX_DetectSecretItem: starting pseudo");
    SetLocalInt(oDetectTrigger, sVarName, TRUE);
    CPP_DetectSecretItem_pseudo(oPC, oDetectTrigger, nSkillType);
}

void main()
{
    object oEntered = GetEnteringObject();

    if(GetIsSecretItemRevealed())
    {
        return;
    }

    CPP_DetectSecretItem(oEntered);
}
