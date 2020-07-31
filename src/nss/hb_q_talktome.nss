// if there is a nearby PC, check if they have an eligible quest
// and do a voice chat if so
#include "inc_quest"

void main()
{

// stop if talking to another player
    if (IsInConversation(OBJECT_SELF)) return;

    int nCount = GetLocalInt(OBJECT_SELF, "count");
    SetLocalInt(OBJECT_SELF, "count", nCount+1);

    if (nCount < 2) return;

    DeleteLocalInt(OBJECT_SELF, "count");

    float fSize = 15.0;

    object oPC = GetFirstObjectInShape(SHAPE_SPHERE, fSize, GetLocation(OBJECT_SELF), TRUE, OBJECT_TYPE_CREATURE);
    //SendMessageToPC(GetFirstPC(), "Running quest speak script");
    while (GetIsObjectValid(oPC))
    {
        if (GetIsPC(oPC))
        {
            //SendMessageToPC(GetFirstPC(), "Found a PC");
            int i;
            for (i = 1; i < 10; i++)
            {
                if (GetIsQuestStageEligible(OBJECT_SELF, oPC, i))
                {
                    //SendMessageToPC(GetFirstPC(), "Quest stage "+IntToString(i)+" eligible");

                    string sTalktomeSound = GetLocalString(OBJECT_SELF, "talktome_sound");
                    AssignCommand(OBJECT_SELF, ClearAllActions());

                    if (sTalktomeSound != "")
                    {
                        DelayCommand(0.05, AssignCommand(OBJECT_SELF, PlaySound(sTalktomeSound)));
                    }
                    else
                    {
                        DelayCommand(0.05, AssignCommand(OBJECT_SELF, PlayVoiceChat(VOICE_CHAT_TALKTOME, OBJECT_SELF)));
                    }

                    string sTalktomeText = GetLocalString(OBJECT_SELF, "talktome_text");
                    if (sTalktomeText != "") DelayCommand(0.06, AssignCommand(OBJECT_SELF, SpeakString(sTalktomeText)));

                    DelayCommand(0.07, TurnToFaceObject(oPC, OBJECT_SELF));
                    DelayCommand(0.08, AssignCommand(OBJECT_SELF, PlayAnimation(ANIMATION_FIREFORGET_GREETING)));

                    return;
                }
            }
        }

        oPC = GetNextObjectInShape(SHAPE_SPHERE, fSize, GetLocation(OBJECT_SELF), TRUE, OBJECT_TYPE_CREATURE);
    }

}
