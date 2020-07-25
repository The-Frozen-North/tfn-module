//::///////////////////////////////////////////////
//:: Weak Gas Trap
//:: 70_t1_gasweak
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
Creates a  5m poison radius gas cloud that poisons all creatures entering
the area with random (but only one per trap instance) poison from this list:
                    DC   Ability      2. roll
Striped toadstool   11     WIS          -
Nightshade          10     DEX          -
Black adder venom   12      -          STR
Bloodroot           12     WIS         CON
Tiny spider venom   11     STR         STR
Ettercap venom      13     DEX         DEX
*/
//:://////////////////////////////////////////////
//:: Created By: Shadooow for Community Patch 1.70
//:: Created On: 03-04-2011
//:://////////////////////////////////////////////

#include "70_inc_spells"

void main()
{
    //1.72: fix for bug where traps are being triggered where they really aren't
    if(GetObjectType(OBJECT_SELF) == OBJECT_TYPE_TRIGGER && !GetIsInSubArea(GetEnteringObject()))
    {
        return;
    }
    object oTarget = GetEnteringObject();
    location lTarget = GetLocation(oTarget);
    //There is no acid fog VFX, so empty AOE will workaround it...
    ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, EffectAreaOfEffect(AOE_PER_FOGACID,"****","****","****"), lTarget, 6.0);

    int nPoison = GetLocalInt(OBJECT_SELF,"POISON");
    if(nPoison < 1)
    {
        switch(d6())
        {
        case 1:
        nPoison = POISON_STRIPED_TOADSTOOL;
        break;
        case 2:
        nPoison = POISON_NIGHTSHADE;
        break;
        case 3:
        nPoison = POISON_BLACK_ADDER_VENOM;
        break;
        case 4:
        nPoison = POISON_BLOODROOT;
        break;
        case 5:
        nPoison = POISON_TINY_SPIDER_VENOM;
        break;
        case 6:
        nPoison = POISON_ETTERCAP_VENOM;
        break;
        }
        SetLocalInt(OBJECT_SELF,"POISON",nPoison);
    }

    effect ePoison = EffectPoison(nPoison);
    ePoison = ExtraordinaryEffect(ePoison);

    oTarget = FIX_GetFirstObjectInShape(SHAPE_SPHERE, 5.0, lTarget, TRUE);
    while(oTarget != OBJECT_INVALID)
    {
        if(!GetIsReactionTypeFriendly(oTarget))
        {
            ApplyEffectToObject(DURATION_TYPE_INSTANT, ePoison, oTarget);
        }
        oTarget = FIX_GetNextObjectInShape(SHAPE_SPHERE, 5.0, lTarget, TRUE);
    }
}
