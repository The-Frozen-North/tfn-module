///Player drinks drow ale
//play animation and add drunk effect

//apply a temp int hit, make player "wobbly"

#include "nw_i0_plot"

void DrinkIt(object oTarget)
{
   AssignCommand(oTarget, ActionPlayAnimation(ANIMATION_FIREFORGET_DRINK));
   AssignCommand(oTarget,ActionSpeakStringByStrRef(10499));
}

void MakeDrunk(object oTarget, int nPoints)
{
    int nRandom = Random(100) + 1;
    if (nRandom < 40)
        DelayCommand(1.0, AssignCommand(oTarget, ActionPlayAnimation(ANIMATION_LOOPING_TALK_LAUGHING)));
    else if (nRandom < 80)
        DelayCommand(1.0, AssignCommand(oTarget, ActionPlayAnimation(ANIMATION_LOOPING_PAUSE_DRUNK)));
    else
        DelayCommand(1.0, AssignCommand(oTarget, ActionPlayAnimation(ANIMATION_LOOPING_SPASM)));

    effect eDumb = EffectAbilityDecrease(ABILITY_INTELLIGENCE, nPoints);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eDumb, oTarget, 60.0);
 //   AssignCommand(oTarget, SpeakString(IntToString(GetAbilityScore(oTarget,ABILITY_INTELLIGENCE))));
}
void main()
{
    object oTarget = GetPCSpeaker();


    DrinkIt(oTarget);
    {
        MakeDrunk(oTarget, 3);
    }
}
