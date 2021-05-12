//::///////////////////////////////////////////////
//:: Henchmen: On Spell Cast At
//:: NW_CH_ACB
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    This determines if the spell just cast at the
    target is harmful or not.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Dec 6, 2001
//:://////////////////////////////////////////////


#include "X0_INC_HENAI"
//#include "x2_i0_spells"

#include "inc_hai"


void main()
{
    object oCaster = GetLastSpellCaster();


    // **************************************
    // * CHAPTER 1
    // * Player brings back a dead henchmen
    // * for the first time
    // *
    // **************************************
    //This should only fire the first time they are raised - when they have
        //first been discovered in Undermountain
    if (GetLocalInt(OBJECT_SELF, "X2_SavedInUndermountain") == FALSE && GetTag(GetModule()) == "x0_module1")
    {
        if (GetLastSpell() == SPELL_RAISE_DEAD || GetLastSpell() == SPELL_RESURRECTION)
        {
            SetLocalInt(OBJECT_SELF, "X2_SavedInUndermountain", 1);

            object oPC = oCaster;

            if (GetTag(OBJECT_SELF) == "x2_hen_sharwyn")
            {
                AddJournalQuestEntry("q2sharwyn", 20, oPC);
            }
            else if (GetTag(OBJECT_SELF) == "x2_hen_tomi")
            {
                AddJournalQuestEntry("q2tomi", 20, oPC);
            }
            else if (GetTag(OBJECT_SELF) == "x2_hen_daelan")
            {
                AddJournalQuestEntry("q2daelan", 20, oPC);
            }


            if (GetHitDice(oPC) < 15)
            {
                Reward_2daXP(oPC, 12, TRUE); //600 xp reward if PC is less than 15th level
            }
            else
            {
                Reward_2daXP(oPC, 11, TRUE); //200 xp reward if PC is 15th level or higher

            }

        }
    }   // special case, first time being raised (if original henches

    if(GetLastSpellHarmful())
    {

        SetCommandable(TRUE);
        // * GZ Oct 3, 2003
        // * Really, the engine should handle this, but hey, this world is not perfect...
        // * If I was hurt by my master or the creature hurting me has
        // * the same master
        // * Then clear any hostile feelings I have against them
        // * After all, we're all just trying to do our job here
        // * if we singe some eyebrow hair, oh well.
        object oMyMaster = GetMaster(OBJECT_SELF);
        if ((oMyMaster != OBJECT_INVALID) && (oMyMaster == oCaster || (oMyMaster  == GetMaster(oCaster)))  )
        {
            ClearPersonalReputation(oCaster, OBJECT_SELF);
            // Send the user-defined event as appropriate
            if(GetSpawnInCondition(NW_FLAG_SPELL_CAST_AT_EVENT))
            {
                SignalEvent(OBJECT_SELF, EventUserDefined(EVENT_SPELL_CAST_AT));
            }
            return;
        }
        if (
// Auldar: Don't react if we are Taunting.
         GetCurrentAction() != ACTION_TAUNT &&
         !GetIsObjectValid(GetAttackTarget()) &&
         !GetIsObjectValid(GetAttemptedSpellTarget()) &&
         !GetIsObjectValid(GetAttemptedAttackTarget()) &&
         !GetIsObjectValid(GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, OBJECT_SELF, 1, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN)) &&
         !GetIsFriend(oCaster))
        {
            SetCommandable(TRUE);
            HenchDetermineCombatRound(oCaster);
        }
    }
    // * Make a henchman initiate with the player if they've just been raised or resurrected
    else if(GetLastSpell() == SPELL_RAISE_DEAD || GetLastSpell()  == SPELL_RESURRECTION)
    {
       // * restore merchant faction to neutral
       SetStandardFactionReputation(STANDARD_FACTION_MERCHANT, 100, oCaster);
       SetStandardFactionReputation(STANDARD_FACTION_COMMONER, 100, oCaster);
       SetStandardFactionReputation(STANDARD_FACTION_DEFENDER, 100, oCaster);
       ClearPersonalReputation(oCaster, OBJECT_SELF);
       AssignCommand(OBJECT_SELF, SurrenderToEnemies());
        object oHench = OBJECT_SELF;
        AssignCommand(oHench, ClearAllActions(TRUE));
        string sFile = GetDialogFileToUse(oCaster);

        // * reset henchmen attack state - Oct 28 (BK)
        SetAssociateState(NW_ASC_MODE_DEFEND_MASTER, FALSE, oHench);
        SetAssociateState(NW_ASC_MODE_STAND_GROUND, FALSE, oHench);

        // * Oct 30 - If player previously hired this hench
        // * then just have them rejoin automatically
        if (GetPlayerHasHired(oCaster, oHench) == TRUE)
        {
            // Feb 11, 2004 - Jon: Don't fire the HireHenchman function if the
            // henchman is already oCaster's associate. Fixes a silly little problem
            // that occured when you try to raise a henchman who wasn't actually dead.
            if(GetMaster(oHench)!=oCaster) HireHenchman(oCaster, oHench, TRUE);
        }
        // * otherwise, they talk
        else
        {
            AssignCommand(oCaster, ActionStartConversation(oHench, sFile));
        }
    }

}

