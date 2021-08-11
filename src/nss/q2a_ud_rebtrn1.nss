//::///////////////////////////////////////////////
//:: Name q2a_ud_rebtrn1
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Maeviir Training Soldier User Defined
    Fire arrows at Targets if PC is in the house
*/
//:://////////////////////////////////////////////
//:: Created By: Keith Warner
//:: Created On: Sept 23/03
//:://////////////////////////////////////////////

#include "nw_i0_plot"

void main()
{
    if (GetAILevel(OBJECT_SELF) == AI_LEVEL_VERY_LOW)
        return;

    //Check to see if anyone is in the way.
    int nObstructed = FALSE;
    object oTrigger = GetObjectByTag("q2arebtrig_left");
    object oObstructor = GetFirstPC();

    while (GetIsObjectValid(oObstructor) == TRUE)
    {
        if (GetIsInSubArea(oObstructor, oTrigger) == TRUE)
        {
            nObstructed = TRUE;

        }
        oObstructor = GetNextPC();
    }

    //if Not obstructed by a PC - fire at target - else yell
    if (nObstructed == FALSE)
    {
        object oTarget = GetObjectByTag("q2a_rebtarget_left");
        ActionAttack(oTarget);
    }
    else
    {
        int nYell;
        int nAnimation;
        int nRandom = Random(5);
        switch (nRandom)
        {
            case 0:     nYell = 85757;// "Get out of the way!";
                        nAnimation = ANIMATION_LOOPING_TALK_FORCEFUL;
                        break;
            case 1:     nYell = 85758;// "What are you doing!";
                        nAnimation = ANIMATION_LOOPING_TALK_FORCEFUL;
                        break;
            case 2:     nYell = 85759;// "Stupid!";
                        nAnimation = ANIMATION_LOOPING_TALK_PLEADING;
                        break;
            case 3:     nYell = 85760;// "You have the brains of a rothe!";
                        nAnimation = ANIMATION_LOOPING_PAUSE;
                        break;
            case 4:     nYell = 85761;// "Ignorant fool!";
                        nAnimation = ANIMATION_LOOPING_TALK_FORCEFUL;
                        break;
        }
        ClearAllActions(TRUE);
        //DelayCommand(0.5, ActionDoCommand(SetFacingPoint(GetPosition(oObstructor))));
        int nAction = Random(5);
        if(nAction == 0)
        {
            PlaySpeakSoundByStrRef(nYell);
        }
        else if (nAction == 1)
        {
            PlayVoiceChat(VOICE_CHAT_BADIDEA);
        }
        else if (nAction == 2)
        {
            PlayVoiceChat(VOICE_CHAT_CUSS);
        }
        else if (nAction == 3)
        {
            PlayVoiceChat(VOICE_CHAT_MOVEOVER);
        }
        else if (nAction == 4)
        {
            PlaySpeakSoundByStrRef(nYell);
        }
        DelayCommand(0.5, ActionDoCommand(ActionPlayAnimation(nAnimation, 1.0, IntToFloat(Random(4) + 1))));
    }


    DelayCommand(4.0 + IntToFloat(Random(4)), SignalEvent(OBJECT_SELF, EventUserDefined(99)));
}
