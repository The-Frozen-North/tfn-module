//::///////////////////////////////////////////////
//:: x2_ai_shadow
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Shadows should only do touch attacks.
*/
//:://////////////////////////////////////////////
//:: Created By: Brent
//:: Created On: September 2003
//:://////////////////////////////////////////////
/*
Patch 1.70

- AI rewritten to fix being flatfooted and the issue when clerallactions called outside of this script could break AI and shadow couldn't attack
*/

#include "x2_inc_switches"
#include "nw_i0_generic"

void main()
{
    //--------------------------------------------------------------------------
    // Shadowdancer shadows have a 66% chance of running the default combat AI
    //--------------------------------------------------------------------------
    if (GetAssociateType(OBJECT_SELF) == ASSOCIATE_TYPE_SUMMONED)
    {
        if (d3() > 1)
        {
            return;
        }

    }

    SetCreatureOverrideAIScriptFinished(OBJECT_SELF);

    if(__InCombatRound())
        return;
    ClearAllActions();

    object oEnemy = bkAcquireTarget();
    if (GetIsObjectValid(oEnemy))
    {
        __TurnCombatRoundOn(TRUE);

        object oSelf = OBJECT_SELF;
        // * just slightly random so they don't appear synchronized. //Shadooow: disabled as that only made shadow flatfooted
        //int nRoundDelay = Random(2) + 1;
        //float fDelay = IntToFloat(nRoundDelay);

        ActionCastSpellAtObject(769, oEnemy, METAMAGIC_ANY, TRUE);
        __TurnCombatRoundOn(FALSE);
        ActionAttack(oEnemy);//this will make sure the shadow stays focused on his target and follow him although he can't attack yet
    }
}
