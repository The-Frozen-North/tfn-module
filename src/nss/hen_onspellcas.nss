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
//:://////////////////////////////////////////////
//:: Modified By: Deva Winblood
//:: Modified On: Jan 4th, 2008
//:: Added Support for Mounted Combat Feat Support
//:://////////////////////////////////////////////
/*
Patch 1.70

- fixed attacking from disabled states like fear
- fixed teleporting when struck by AOE in different area
- fixed flat-foot issue when target of multiple AOEs
- fixed cancel when struck by own spell
+ better AOE behavior
*/

#include "x0_inc_henai"
#include "x2_i0_spells"

void main()
{
    if(!GetCommandable())
        return;

    object oAOE, oCaster = GetLastSpellCaster();
    if(GetObjectType(oCaster) == OBJECT_TYPE_AREA_OF_EFFECT)
    {
        oAOE = oCaster;
        oCaster = GetAreaOfEffectCreator(oAOE);
    }
    int nSpell = GetLastSpell();

    if(GetLastSpellHarmful())
    {
        if (GetIsEnemy(GetLastSpellCaster()))
                SpeakString("PARTY_I_WAS_ATTACKED", TALKVOLUME_SILENT_TALK);

        // * GZ Oct 3, 2003
        // * Really, the engine should handle this, but hey, this world is not perfect...
        // * If I was hurt by my master or the creature hurting me has
        // * the same master
        // * Then clear any hostile feelings I have against them
        // * After all, we're all just trying to do our job here
        // * if we singe some eyebrow hair, oh well.
        object oMyMaster = GetMaster(OBJECT_SELF);
        if ((oMyMaster != OBJECT_INVALID) && (oMyMaster == oCaster || (oMyMaster  == GetMaster(oCaster))) )
        {
            ClearPersonalReputation(oCaster, OBJECT_SELF);
            // Send the user-defined event as appropriate
            if(GetSpawnInCondition(NW_FLAG_SPELL_CAST_AT_EVENT))
            {
                SignalEvent(OBJECT_SELF, EventUserDefined(EVENT_SPELL_CAST_AT));
            }
            return;
        }

        int bAttack = TRUE;
        // * AOE Behavior

        if (MatchAreaOfEffectSpell(nSpell) && !GetIsHenchmanDying() && !GetHasEffect(EFFECT_TYPE_POLYMORPH))
        {
            //* GZ 2003-Oct-02 : New AoE Behavior AI
            int nAI = (GetBestAOEBehavior(GetLastSpell()));
            switch(nAI)
            {
                case X2_SPELL_AOEBEHAVIOR_DISPEL_L:
                case X2_SPELL_AOEBEHAVIOR_DISPEL_N:
                case X2_SPELL_AOEBEHAVIOR_DISPEL_M:
                case X2_SPELL_AOEBEHAVIOR_DISPEL_G:
                case X2_SPELL_AOEBEHAVIOR_DISPEL_C:
                    bAttack = FALSE;
                    ClearAllActions();
                    ActionCastSpellAtLocation(nAI, GetLocation(GetIsObjectValid(oAOE) ? oAOE : OBJECT_SELF));
                    ActionDoCommand(SetCommandable(TRUE));
                    SetCommandable(FALSE);
                break;
                case X2_SPELL_AOEBEHAVIOR_FLEE:
                    bAttack = FALSE;
                    if(!GetIsObjectValid(oCaster) || GetArea(oCaster) != GetArea(OBJECT_SELF))
                    {
                        oCaster = GetNearestEnemy();
                    }
                    if(!GetIsObjectValid(oCaster))
                    {
                        ClearActions(CLEAR_NW_C2_DEFAULTB_GUSTWIND);
                        ActionMoveAwayFromLocation(GetLocation(GetIsObjectValid(oAOE) ? oAOE : OBJECT_SELF), TRUE, 10.0);
                    }
                    else if(GetAttackTarget() == OBJECT_INVALID || GetWeaponRanged(GetItemInSlot(INVENTORY_SLOT_RIGHTHAND)))
                    {
                        ClearActions(CLEAR_NW_C2_DEFAULTB_GUSTWIND);
                        ActionMoveToObject(oCaster, TRUE, 2.0);//no teleporting anymore
                        ActionDoCommand(HenchmenCombatRound(oCaster));
                    }
                break;
                case X2_SPELL_AOEBEHAVIOR_GUST:
                    bAttack = FALSE;
                    ClearAllActions();
                    ActionCastSpellAtLocation(SPELL_GUST_OF_WIND, GetLocation(GetObjectType(oCaster) == OBJECT_TYPE_AREA_OF_EFFECT ? oCaster : OBJECT_SELF));
                    ActionDoCommand(SetCommandable(TRUE));
                    SetCommandable(FALSE);
                break;
            }
        }

        if(bAttack &&
         (!GetIsObjectValid(GetAttackTarget()) &&
         !GetIsObjectValid(GetAttemptedSpellTarget()) &&
         !GetIsObjectValid(GetAttemptedAttackTarget()) &&
         !GetIsObjectValid(GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, OBJECT_SELF, 1, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN)) &&
         !GetIsFriend(oCaster))
        )
        {
            //Shout Attack my target, only works with the On Spawn In setup
            SpeakString("NW_ATTACK_MY_TARGET", TALKVOLUME_SILENT_TALK);
            //Shout that I was attacked
            SpeakString("NW_I_WAS_ATTACKED", TALKVOLUME_SILENT_TALK);
            HenchmenCombatRound(oCaster);
        }
    }
}

