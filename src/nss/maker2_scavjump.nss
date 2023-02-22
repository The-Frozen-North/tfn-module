// Scavenger golem jumps to next wp

#include "nw_i0_plot"

void main()
{
    object oWP = GetNearestObjectByTag("q4b_wp_scav_jump", OBJECT_SELF, 2);
    if(GetLocalInt(OBJECT_SELF, "JUMPING") == 1)
        return;
    SetLocalInt(OBJECT_SELF, "JUMPING", 1);
    ClearAllActions();
    PlayAnimation(ANIMATION_LOOPING_CONJURE1);
    PlaySpeakSoundByStrRef(84830);
    effect eVis = EffectVisualEffect(472);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, OBJECT_SELF);
    int i = 1;
    object oCreature = GetNearestCreature(CREATURE_TYPE_IS_ALIVE, TRUE, OBJECT_SELF, i);
    while(oCreature != OBJECT_INVALID)
    {
        if(GetDistanceBetween(OBJECT_SELF, oCreature) <= 10.0)
            AssignCommand(oCreature, ClearAllActions());
        else
            break;
        i++;
        oCreature = GetNearestCreature(CREATURE_TYPE_IS_ALIVE, TRUE, OBJECT_SELF, i);
    }
    DelayCommand(3.0, JumpToObject(oWP));
    DelayCommand(4.0, SetLocalInt(OBJECT_SELF, "JUMPING", 0));
}