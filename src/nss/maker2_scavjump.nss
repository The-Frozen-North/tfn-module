// Scavenger golem jumps to next wp

#include "nw_i0_plot"

void ReallyJumpToObject(object oTarget)
{
    ClearAllActions(TRUE);
    DeleteLocalObject(OBJECT_SELF, "GS_CB_ATTACK_TARGET");
    JumpToObject(oTarget);
    //SendMessageToPC(GetFirstPC(), "jump");
    // This seems to stop GS AI immediately deciding it wants to keep fighting...
    // ... maybe?
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectCutsceneParalyze(), OBJECT_SELF, 6.0);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectCutsceneImmobilize(), OBJECT_SELF, 6.0);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectBlindness(), OBJECT_SELF, 6.0);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectDeaf(), OBJECT_SELF, 6.0);
    //DelayCommand(6.0, SendMessageToPC(GetFirstPC(), "canmove"));
    DelayCommand(6.0, ClearAllActions(TRUE));
}

void main()
{
    // This can at most be 5th furthest waypoint
    object oWP = GetNearestObjectByTag("q4b_wp_scav_jump", OBJECT_SELF, 4);
    if(GetLocalInt(OBJECT_SELF, "JUMPING") == 1)
        return;
    SetLocalInt(OBJECT_SELF, "JUMPING", 1);
    ClearAllActions(TRUE);
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
    DelayCommand(3.0, ReallyJumpToObject(oWP));
    DelayCommand(4.0, SetLocalInt(OBJECT_SELF, "JUMPING", 0));
}