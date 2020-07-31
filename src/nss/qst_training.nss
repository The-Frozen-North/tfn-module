#include "inc_quest"
#include "x0_i0_position"

void main()
{
    int nXP = GetXP(OBJECT_SELF);

    if (nXP < 1000)
    {
        object oPavel = GetObjectByTag("pavel");

        SetXP(OBJECT_SELF, 1000);
        FadeToBlack(OBJECT_SELF);
        DelayCommand(2.5, AssignCommand(OBJECT_SELF, ActionJumpToObject(GetObjectByTag("qst_training"))));
        DelayCommand(5.0, FadeFromBlack(OBJECT_SELF));

        DelayCommand(6.0, TurnToFaceObject(OBJECT_SELF, oPavel));
        DelayCommand(6.0, AssignCommand(oPavel, ActionPlayAnimation(ANIMATION_FIREFORGET_GREETING)));
        DelayCommand(6.0, AssignCommand(oPavel, PlaySound("vs_hhenchm1_067")));
        DelayCommand(6.0, AssignCommand(oPavel, SpeakString("Finally, you're up. I was afraid you were going to sleep all day... I guess the instructors work you pretty hard here at the academy.")));
    }
}
