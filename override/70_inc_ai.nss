//::///////////////////////////////////////////////
//:: Community Patch 1.70 Artificial Intelligence library
//:: 70_inc_ai
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
This include contains a special functions needed to improve AI. Since Community Patch
aiming for maximum compatibility, I had to create a special include for them even when
they would normally fit the x0_inc_generic library. But if some module contained a
modified version of this library, compiling AI scripts might fail with compile error.

Thats why these functions must stay here. I even kept the same name for them, "bk",
even though the author is not bk anymore. Simply for more readability and easy of use.
*/
//:://////////////////////////////////////////////
//:: Created By: Shadooow
//:: Created On: 17-01-2016
//:://////////////////////////////////////////////

#include "x2_inc_switches"
#include "x0_i0_enemy"
#include "x0_i0_assoc"

//More realistic omnivore behavior based on LoCash code
const int NW_FLAG_BEHAVIOR_OMNIVORE_172      = 0x00000010;

//More realistic herbivore behavior based on LoCash code
const int NW_FLAG_BEHAVIOR_HERBIVORE_172     = 0x00000020;

//private version of ChooseNewTarget to provide full compatibility with older version of the x0_inc_generic library
object ChooseDifferentTarget(object oLastTarget=OBJECT_INVALID);

// 1.72: This is a copy of the bkTalentFilter from x0_inc_generic to allow test talents
// that needs to be used at location rather than on object.
//
//    This function is the last minute filter to prevent
//    any inappropriate talents from being used.
//
//    Returns TRUE if the talent was valid, FALSE otherwise.
//
// Parameters
// bJustTest = If this is true the function only does a test
//  the action stack is NOT modified at all
int bkTalentFilterLoc(talent tUse, location lTarget, int bJustTest=FALSE);

// 1.72: This is a copy of the bkTalentFilter from x0_inc_generic to allow test spells
// as creating a talent manually with TalentSpell function doesn't work properly.
//
//    This function is the last minute filter to prevent
//    any inappropriate spells from being used.
//
//    Returns TRUE if the talent was valid, FALSE otherwise.
//
// Parameters
// bJustTest = If this is true the function only does a test
//  the action stack is NOT modified at all
int bkTalentFilterSpell(int nSpell, object oTarget, int bJustTest=FALSE);

//1.72: performs a sanity, smart and intelligence checks on given talen
//returns FALSE if talent didn't passed the checks, TRUE or spell constant if yes
int bkTalentFilterTest(int nTalentType, int nTalentId, object oTarget);

// Returns TRUE on successful use of such a talent, FALSE otherwise.
// Handles polymorphed creatures as well as polymorphing itself
int TalentShapechange(object oIntruder = OBJECT_INVALID, int bStart=FALSE);

// Choose a new nearby target. Target must be an enemy, perceived,
// and not in dying mode. If possible, we first target members of
// a class we hate.
object ChooseDifferentTarget(object oLastTarget=OBJECT_INVALID)
{
    int nHatedClass = GetLocalInt(OBJECT_SELF, "NW_L_BEHAVIOUR1") - 1;

    // * if the object has no hated class, then assign it
    // * a random one.
    // * NOTE: Classes are off-by-one
    if (nHatedClass == -1)
    {
        int nHatedClass = Random(10);
        nHatedClass = nHatedClass + 1;     // for purposes of using 0 as a
                                           // unitialized value.
                                           // will decrement in bkAcquireTarget
        SetLocalInt(OBJECT_SELF, "NW_L_BEHAVIOUR1", nHatedClass);
        nHatedClass = GetLocalInt(OBJECT_SELF, "NW_L_BEHAVIOUR1") - 1;
    }

    //MyPrintString("I hate " + IntToString(nHatedClass));

    // * First try to attack the class you hate the most
    object oTarget = GetNearestPerceivedEnemy(OBJECT_SELF, 1, CREATURE_TYPE_CLASS, nHatedClass);

    if (GetIsObjectValid(oTarget) && oTarget != oLastTarget && !GetIsDead(oTarget) && !GetHasSpellEffect(SPELL_ETHEREALNESS, oTarget) && !GetAssociateState(NW_ASC_MODE_DYING, oTarget))
        return oTarget;

    // If we didn't find one with the criteria, look
    // for a nearby one
    // * Keep looking until we find a perceived target that
    // * isn't in dying mode
    oTarget = GetNearestPerceivedEnemy(OBJECT_SELF, 1, CREATURE_TYPE_DOES_NOT_HAVE_SPELL_EFFECT, SPELL_ETHEREALNESS);
    int nNth = 1;
    while(GetIsObjectValid(oTarget))
    {
        if(oTarget != oLastTarget && !GetIsDead(oTarget) && !GetAssociateState(NW_ASC_MODE_DYING, oTarget))
        {
            break;
        }
        oTarget = GetNearestPerceivedEnemy(OBJECT_SELF, ++nNth, CREATURE_TYPE_DOES_NOT_HAVE_SPELL_EFFECT, SPELL_ETHEREALNESS);
    }

    return oTarget;
}

int bkTalentFilterLoc(talent tUse, location lTarget, int bJustTest=FALSE)
{
    if(!GetIsTalentValid(tUse)) return FALSE;

    int nType = GetTypeFromTalent(tUse);
    int iId = GetIdFromTalent(tUse);
    int nNotValid = FALSE;

    /*
    TODO: this is a great place to modify the target location to cast the spell optimaly to hit multiple enemies or to avoid hit allies
    */
    if(nType == TALENT_TYPE_SPELL)//polymorph casting check, engine allows npcs to cast spells while polymorphed, this code will check whether this is the case and cancels polymorph if the talent is powerful enough to be worth it
    {
        effect eSearch = GetFirstEffect(OBJECT_SELF);
        while(GetIsEffectValid(eSearch))
        {
            if(GetEffectType(eSearch) == EFFECT_TYPE_POLYMORPH)
            {
                if(Get2DAString("spells","UserType",iId) == "1")//solve only ordinary spells
                {
                    if(GetEffectCreator(eSearch) == OBJECT_SELF && StringToInt(Get2DAString("spells","Innate",iId)) >= 5)//spell is powerful enought to make it worth cancel polymorph and cast it
                    {
                        if(!bJustTest)
                        {
                            RemoveEffect(OBJECT_SELF,eSearch);//cancel polymorph
                        }
                    }
                    else//if the polymorph is from other source than self, then no casting will be allowed at all
                    {
                        nNotValid = TRUE;
                    }
                }
                break;
            }
            eSearch = GetNextEffect(OBJECT_SELF);
        }
    }

    if(bJustTest)
    {
        return !nNotValid;//1.71: return value for testing purposes moved here so it doesn't try to cast spells below
    }

    //1.72: high AI and henchman casters will try to use defensive casting when appropriate
    /*
    if(nType == TALENT_TYPE_SPELL && (GetAILevel() >= AI_LEVEL_HIGH || GetAssociateType(OBJECT_SELF) == ASSOCIATE_TYPE_HENCHMAN) && !GetHasFeat(FEAT_EPIC_IMPROVED_COMBAT_CASTING))
    {
        //do not go into defensive casting when already in (improved) expertise action mode
        if(!GetActionMode(OBJECT_SELF,ACTION_MODE_DEFENSIVE_CAST) && !GetActionMode(OBJECT_SELF,ACTION_MODE_EXPERTISE) && !GetActionMode(OBJECT_SELF,ACTION_MODE_IMPROVED_EXPERTISE))
        {
            int numIntruders;
            location lLoc = GetLocation(OBJECT_SELF);
            object oIntruder = GetFirstObjectInShape(SHAPE_SPHERE,RADIUS_SIZE_MEDIUM,lLoc);
            while(GetIsObjectValid(oIntruder))
            {
                if(oIntruder != OBJECT_SELF && !GetIsDead(oIntruder) && GetIsReactionTypeHostile(oIntruder))
                {
                    numIntruders++;
                }
                oIntruder = GetNextObjectInShape(SHAPE_SPHERE,RADIUS_SIZE_MEDIUM,lLoc);
            }
            if(numIntruders > 0 && Get2DAString("spells","UserType",iId) == "1")//only spells with UserType 1 causes AOO, ignore others
            {
                int nDC = 15+StringToInt(Get2DAString("spells","Innate",iId))+(GetHasFeat(FEAT_COMBAT_CASTING) ? 0 : 4);
                int nRank = GetSkillRank(SKILL_CONCENTRATION);
                int nChance = nRank >= nDC ? 100 : (21-(nDC-nRank))*100/20;
                if(nChance >= 25)//only try this if the chance to succeed is at least 25% or more
                {
                    if(nChance < 100) nChance = nChance+nChance*numIntruders*20/100;
                    if(d100() <= nChance)
                    {
                        SetActionMode(OBJECT_SELF,ACTION_MODE_DEFENSIVE_CAST,TRUE);
                    }
                }
            }
        }
    }
    */

    //1.72: no more attacking when *this* talent is not valid, there still might be other valid talent that creature can use
    if(!nNotValid)
    {
        ClearAllActions();
        if(nType == TALENT_TYPE_FEAT)//1.72: workaround for bug in ActionUseTalentAtLocation with feat type of talents
        {
            string s2DA = Get2DAString("feat","SPELLID",iId);
            if(s2DA != "" && s2DA != "****")
            {
                ActionCastSpellAtLocation(StringToInt(s2DA),lTarget,METAMAGIC_NONE,TRUE);
                ActionDoCommand(DecrementRemainingFeatUses(OBJECT_SELF,iId));
                return TRUE;
            }
            return FALSE;
        }
        ActionUseTalentAtLocation(tUse, lTarget);
        return TRUE;
    }
    return FALSE;
}

int bkTalentFilterSpell(int nSpell, object oTarget, int bJustTest=FALSE)
{
    if(!GetHasSpell(nSpell)) return FALSE;

    int nNotValid = FALSE;

    int bSpellTest = bkTalentFilterTest(TALENT_TYPE_SPELL,nSpell,oTarget);
    if(bSpellTest > TRUE)//spell substituted
    {
        return bkTalentFilterSpell(bSpellTest,oTarget,bJustTest);
    }
    else if(!bSpellTest)//talent didn't passed the filter tests
    {
        nNotValid = TRUE;
    }
    else//polymorph casting check, engine allows npcs to cast spells while polymorphed, this code will check whether this is the case and cancels polymorph if the talent is powerful enough to be worth it
    {
        effect eSearch = GetFirstEffect(OBJECT_SELF);
        while(GetIsEffectValid(eSearch))
        {
            if(GetEffectType(eSearch) == EFFECT_TYPE_POLYMORPH)
            {
                if(Get2DAString("spells","UserType",nSpell) == "1")//solve only ordinary spells
                {
                    if(GetEffectCreator(eSearch) == OBJECT_SELF && StringToInt(Get2DAString("spells","Innate",nSpell)) >= 5)//spell is powerful enought to make it worth cancel polymorph and cast it
                    {
                        if(!bJustTest)
                        {
                            RemoveEffect(OBJECT_SELF,eSearch);//cancel polymorph
                        }
                    }
                    else//if the polymorph is from other source than self, then no casting will be allowed at all
                    {
                        nNotValid = TRUE;
                    }
                }
                break;
            }
            eSearch = GetNextEffect(OBJECT_SELF);
        }
    }

    if(bJustTest)
    {
        return !nNotValid;//1.71: return value for testing purposes moved here so it doesn't try to cast spells below
    }

    //1.72: high AI and henchman casters will try to use defensive casting when appropriate
    /*
    if((GetAILevel() >= AI_LEVEL_HIGH || GetAssociateType(OBJECT_SELF) == ASSOCIATE_TYPE_HENCHMAN) && !GetHasFeat(FEAT_EPIC_IMPROVED_COMBAT_CASTING))
    {
        //do not go into defensive casting when already in (improved) expertise action mode
        if(!GetActionMode(OBJECT_SELF,ACTION_MODE_DEFENSIVE_CAST) && !GetActionMode(OBJECT_SELF,ACTION_MODE_EXPERTISE) && !GetActionMode(OBJECT_SELF,ACTION_MODE_IMPROVED_EXPERTISE))
        {
            int numIntruders;
            location lLoc = GetLocation(OBJECT_SELF);
            object oIntruder = GetFirstObjectInShape(SHAPE_SPHERE,RADIUS_SIZE_MEDIUM,lLoc);
            while(GetIsObjectValid(oIntruder))
            {
                if(oIntruder != OBJECT_SELF && !GetIsDead(oIntruder) && GetIsReactionTypeHostile(oIntruder))
                {
                    numIntruders++;
                }
                oIntruder = GetNextObjectInShape(SHAPE_SPHERE,RADIUS_SIZE_MEDIUM,lLoc);
            }
            if(numIntruders > 0 && Get2DAString("spells","UserType",nSpell) == "1")//only spells with UserType 1 causes AOO, ignore others
            {
                int nDC = 15+StringToInt(Get2DAString("spells","Innate",nSpell))+(GetHasFeat(FEAT_COMBAT_CASTING) ? 0 : 4);
                int nRank = GetSkillRank(SKILL_CONCENTRATION);
                int nChance = nRank >= nDC ? 100 : (21-(nDC-nRank))*100/20;
                if(nChance >= 25)//only try this if the chance to succeed is at least 25% or more
                {
                    if(nChance < 100) nChance = nChance+nChance*numIntruders*20/100;
                    if(d100() <= nChance)
                    {
                        SetActionMode(OBJECT_SELF,ACTION_MODE_DEFENSIVE_CAST,TRUE);
                    }
                }
            }
        }
    }
    */

    //1.72: no more attacking when *this* talent is not valid, there still might be other valid talent that creature can use
    if(!nNotValid)
    {
        ClearAllActions();
        ActionCastSpellAtObject(nSpell,oTarget);
        return TRUE;
    }
    return FALSE;
}

int bkTalentFilterTest(int nTalentType, int nTalentId, object oTarget)
{
    int bSpell = nTalentType == TALENT_TYPE_SPELL;
    int bFeat = nTalentType == TALENT_TYPE_FEAT;
    int nTargetRacialType = GetRacialType(oTarget);
    int nIntelligence = GetAbilityModifier(ABILITY_INTELLIGENCE);

    // Check for undead!
    if(nTargetRacialType == RACIAL_TYPE_UNDEAD && oTarget != OBJECT_SELF && GetIsReactionTypeHostile(oTarget,OBJECT_SELF))//1.72: no additional verification for inflict spells when casting on self or allies
    {
        // DO NOT USE SILLY HARM ON THEM; substitute a heal spell if possible
        if(bSpell)
        {
            switch(nTalentId)
            {
            case SPELL_INFLICT_MINOR_WOUNDS:
                if(GetHasSpell(SPELL_CURE_MINOR_WOUNDS))
                    return SPELL_CURE_MINOR_WOUNDS;
            case SPELL_INFLICT_LIGHT_WOUNDS:
            case SPELL_NEGATIVE_ENERGY_RAY:
                if(GetHasSpell(SPELL_CURE_LIGHT_WOUNDS))
                    return SPELL_CURE_LIGHT_WOUNDS;
            case SPELL_INFLICT_MODERATE_WOUNDS:
            case SPELL_NEGATIVE_ENERGY_BURST:
                if(GetHasSpell(SPELL_CURE_MODERATE_WOUNDS))
                    return SPELL_CURE_MODERATE_WOUNDS;
            case SPELL_INFLICT_SERIOUS_WOUNDS:
                if(GetHasSpell(SPELL_CURE_SERIOUS_WOUNDS))
                    return SPELL_CURE_SERIOUS_WOUNDS;
            case SPELL_INFLICT_CRITICAL_WOUNDS:
                if(GetHasSpell(SPELL_CURE_CRITICAL_WOUNDS))
                    return SPELL_CURE_CRITICAL_WOUNDS;
            case SPELL_HARM:
                if(GetHasSpell(SPELL_HEAL) && GetChallengeRating(oTarget) > 8.0)
                    return SPELL_HEAL;
                return FALSE;
            }
        }
        else if(bFeat)
        {
            switch(nTalentId)
            {
            case FEAT_INFLICT_SERIOUS_WOUNDS:
                if(GetHasSpell(SPELL_CURE_SERIOUS_WOUNDS))
                    return SPELL_CURE_SERIOUS_WOUNDS;
            case FEAT_INFLICT_CRITICAL_WOUNDS:
                if(GetHasSpell(SPELL_CURE_CRITICAL_WOUNDS))
                    return SPELL_CURE_CRITICAL_WOUNDS;
                if(GetHasSpell(SPELL_HEAL) && GetChallengeRating(oTarget) > 8.0)
                    return SPELL_HEAL;
                return FALSE;
            }
        }
    }
    //1.72: do not use cure critical wounds - others on self
    if(bSpell && nTalentId == 567)
    {
        return oTarget != OBJECT_SELF;
    }
    //1.71: do not spam petrify talents on creatures already petrified
    if(bSpell && (nTalentId == 495 || nTalentId == 496 || nTalentId == 497 || nTalentId == 687))
    {
        return !GetHasEffect(EFFECT_TYPE_PETRIFY,oTarget);
    }
    //1.71: don't cast haste on targets with haste effect
    if(bSpell && nTalentId == SPELL_HASTE)
    {
        if(GetHasEffect(EFFECT_TYPE_HASTE,oTarget))
            return FALSE;
        int nSlot = INVENTORY_SLOT_CARMOUR;
        object oItem;
        for(;nSlot>-1;nSlot--)
        {
            oItem = GetItemInSlot(nSlot,oTarget);
            if(GetIsObjectValid(oItem) && GetItemHasItemProperty(oItem,ITEM_PROPERTY_HASTE))
                return FALSE;
        }
        return TRUE;
    }
    //1.72: don't cast revealing spells if we have true seeing
    if(bSpell && (nTalentId == SPELL_SEE_INVISIBILITY || nTalentId == SPELL_DARKVISION || nTalentId == SPELL_TRUE_SEEING))
    {
        if(GetHasEffect(EFFECT_TYPE_TRUESEEING,oTarget))
            return FALSE;
        int nSlot = INVENTORY_SLOT_CARMOUR;
        object oItem;
        for(;nSlot>-1;nSlot--)
        {
            oItem = GetItemInSlot(nSlot,oTarget);
            if(GetIsObjectValid(oItem) && GetItemHasItemProperty(oItem,ITEM_PROPERTY_TRUE_SEEING))
                return FALSE;
        }
        return TRUE;
    }
    //1.72: don't cast stone bones on non undead target
    if(bSpell && nTalentId == SPELL_STONE_BONES)
    {
        return nTargetRacialType == RACIAL_TYPE_UNDEAD;
    }
    //1.72: don't cast sanctuary with GS
    if(bSpell && nTalentId == SPELL_SANCTUARY)
    {
        return !GetHasSpellEffect(SPELL_ETHEREALNESS,oTarget);
    }
    //1.72: don't cast minor globe of invulnerability if already under effect of different/stronger version of this spell
    if(bSpell && (nTalentId == SPELL_MINOR_GLOBE_OF_INVULNERABILITY || nTalentId == SPELL_GREATER_SHADOW_CONJURATION_MINOR_GLOBE))
    {
        if(GetHasSpellEffect(SPELL_GLOBE_OF_INVULNERABILITY,oTarget) || GetHasSpellEffect(SPELL_MINOR_GLOBE_OF_INVULNERABILITY,oTarget) || GetHasSpellEffect(SPELL_GREATER_SHADOW_CONJURATION_MINOR_GLOBE,oTarget))
        {
            return FALSE;
        }
        return TRUE;
    }
    //1.72: don't cast ghostly visage if already under effect of different version of this spell or ethereal visage
    if((bSpell && (nTalentId == SPELL_GHOSTLY_VISAGE || nTalentId == SPELL_GREATER_SHADOW_CONJURATION_MIRROR_IMAGE)) || (bFeat && nTalentId == FEAT_PRESTIGE_SPELL_GHOSTLY_VISAGE))
    {
        if(GetHasSpellEffect(SPELL_ETHEREAL_VISAGE,oTarget) || GetHasSpellEffect(SPELL_GHOSTLY_VISAGE,oTarget) || GetHasSpellEffect(SPELL_GREATER_SHADOW_CONJURATION_MIRROR_IMAGE,oTarget) || GetHasSpellEffect(SPELLABILITY_AS_GHOSTLY_VISAGE))
        {
            return FALSE;
        }
        return TRUE;
    }
    //1.72: invisibility doesn't stack
    if((bSpell && (nTalentId == SPELL_INVISIBILITY || nTalentId == SPELL_IMPROVED_INVISIBILITY || nTalentId == SPELL_INVISIBILITY_SPHERE)) ||
                    (bFeat && (nTalentId == FEAT_HARPER_INVISIBILITY || nTalentId == FEAT_PRESTIGE_INVISIBILITY_1 || nTalentId == FEAT_PRESTIGE_INVISIBILITY_2)))
    {
        return !GetHasEffect(EFFECT_TYPE_INVISIBILITY,oTarget);
    }
    //1.72: spell mantle doesn't stack, so if creature has any spell mantle effect, don't allow cast another spell mantle spell
    if(bSpell && (nTalentId == SPELL_SPELL_MANTLE || nTalentId == SPELL_LESSER_SPELL_MANTLE || nTalentId == SPELL_GREATER_SPELL_MANTLE))
    {
        if(GetHasSpellEffect(SPELL_SPELL_MANTLE,oTarget) || GetHasSpellEffect(SPELL_LESSER_SPELL_MANTLE,oTarget) || GetHasSpellEffect(SPELL_GREATER_SPELL_MANTLE,oTarget))
        {
            return FALSE;
        }
        return TRUE;
    }
    // * Check: (Dec 19 2002) Don't waste Power Word Kill
    // on Targets with more than 100hp
    if(bSpell && nTalentId == SPELL_POWER_WORD_KILL)
    {
        int nLimit = GetLocalInt(GetModule(),"131_LIMIT_OVERRIDE");//1.72: if the 100hp limit is overriden, AI will count with it
        if(!nLimit) nLimit = GetLocalInt(OBJECT_SELF,"131_LIMIT_OVERRIDE");
        if(!nLimit) nLimit = 100;
        return GetCurrentHitPoints(oTarget) <= nLimit;
    }
    //1.72: intelligence controls - remaining spell checks should be only performed by smart creatures
    int nSmart = GetAILevel();
    if(nSmart < AI_LEVEL_HIGH)
    {
        switch(GetRacialType(OBJECT_SELF))
        {
            case RACIAL_TYPE_ELF:
            case RACIAL_TYPE_HALFELF:
            case RACIAL_TYPE_DWARF:
            case RACIAL_TYPE_HUMAN:
            case RACIAL_TYPE_HALFLING:
            case RACIAL_TYPE_HALFORC:
            case RACIAL_TYPE_GNOME:
            case RACIAL_TYPE_MAGICAL_BEAST:
            case RACIAL_TYPE_ABERRATION:
            case RACIAL_TYPE_OUTSIDER:
            case RACIAL_TYPE_FEY:
            case RACIAL_TYPE_DRAGON:
                nSmart = TRUE;
                break;
            case RACIAL_TYPE_HUMANOID_GOBLINOID:
            case RACIAL_TYPE_HUMANOID_MONSTROUS:
            case RACIAL_TYPE_HUMANOID_ORC:
            case RACIAL_TYPE_HUMANOID_REPTILIAN:
            case RACIAL_TYPE_CONSTRUCT:
            case RACIAL_TYPE_UNDEAD:
            case RACIAL_TYPE_ELEMENTAL:
            case RACIAL_TYPE_GIANT:
            case RACIAL_TYPE_SHAPECHANGER:
                if(GetAbilityScore(OBJECT_SELF,ABILITY_INTELLIGENCE,TRUE) < 10)
                    return TRUE;
                nSmart = TRUE;
                break;
            default://beast, animal, ooze, vermin, invalid or custom race
                return TRUE;
        }
    }
    // * Negative damage does nothing to undead or constructs. Don't use it.
    if(nTargetRacialType == RACIAL_TYPE_CONSTRUCT && (nTalentId == SPELL_NEGATIVE_ENERGY_BURST || nTalentId == SPELL_NEGATIVE_ENERGY_RAY || nTalentId == SPELL_RAY_OF_ENFEEBLEMENT))//1.72: added ray of enfeeblement
    {
        return FALSE;
    }
    //sleep
    if((bSpell && (nTalentId == SPELL_SLEEP || nTalentId == SPELL_DAZE)) || (bFeat && nTalentId == FEAT_HARPER_SLEEP))
    {
        if(GetHitDice(oTarget) > nTalentId == SPELL_DAZE ? 5 : 4)//1.72: Check if the daze spell is being used appropriately.
        {
            return FALSE;
        }
        // * elves and half-elves are immune to sleep
        else if(nSmart > 1 && (nTargetRacialType == RACIAL_TYPE_ELF || nTargetRacialType == RACIAL_TYPE_HALFELF))
        {
            return FALSE;
        }
        return TRUE;
    }
    // * Don't use drown against nonliving opponents
    if(bSpell && nTalentId == SPELL_DROWN)
    {
        switch(nTargetRacialType)
        {
            case RACIAL_TYPE_CONSTRUCT:
            case RACIAL_TYPE_ELEMENTAL:
            case RACIAL_TYPE_UNDEAD:
            case RACIAL_TYPE_OOZE://1.70: added ooze racial type
                return FALSE;
        }
        return TRUE;
    }
    // * August 2003
    // * If casting certain spells that should not harm creatures
    // * who are immune to losing levels, try another
    if(bSpell && (nTalentId == SPELL_ENERGY_DRAIN || nTalentId == SPELL_ENERVATION) && GetIsImmune(oTarget, IMMUNITY_TYPE_NEGATIVE_LEVEL))
    {
        switch(nTargetRacialType)//1.72: don't cheat, block spell only when immunity is obvious.
        {
            case RACIAL_TYPE_UNDEAD:
            case RACIAL_TYPE_CONSTRUCT:
                return FALSE;
        }
        return TRUE;
    }
    // Check if person spells are being used appropriately.
    if(bSpell && MatchPersonSpells(nTalentId))
    {
        switch(nTargetRacialType)
        {
            case RACIAL_TYPE_ELF:
            case RACIAL_TYPE_HALFELF:
            case RACIAL_TYPE_DWARF:
            case RACIAL_TYPE_HUMAN:
            case RACIAL_TYPE_HALFLING:
            case RACIAL_TYPE_HALFORC:
            case RACIAL_TYPE_GNOME:
            case RACIAL_TYPE_HUMANOID_GOBLINOID:
            case RACIAL_TYPE_HUMANOID_MONSTROUS:
            case RACIAL_TYPE_HUMANOID_ORC:
            case RACIAL_TYPE_HUMANOID_REPTILIAN:
                return TRUE;
        }
        return FALSE;
    }
    // Do a final check for mind affecting spells.
    if(bSpell && MatchMindAffectingSpells(nTalentId) && GetIsImmune(oTarget,IMMUNITY_TYPE_MIND_SPELLS))
    {
        switch(nTargetRacialType)//1.70: don't cheat, block spell only when immunity is obvious.
        {
        case RACIAL_TYPE_UNDEAD:
        case RACIAL_TYPE_ELEMENTAL:
        case RACIAL_TYPE_CONSTRUCT:
        case RACIAL_TYPE_VERMIN:
        case RACIAL_TYPE_OOZE:
            return FALSE;
        }
        return TRUE;
    }
    //1.72: smarter dispel usage
    if(nSmart > 1 && bSpell && (nTalentId == SPELL_LESSER_DISPEL || nTalentId == SPELL_DISPEL_MAGIC || nTalentId == SPELL_GREATER_DISPELLING || nTalentId == SPELL_MORDENKAINENS_DISJUNCTION))
    {
        //substitute with breach if target has spell mantle effect
        if(nTalentId != SPELL_MORDENKAINENS_DISJUNCTION && (GetHasSpellEffect(SPELL_SPELL_MANTLE,oTarget) || GetHasSpellEffect(SPELL_LESSER_SPELL_MANTLE,oTarget) || GetHasSpellEffect(SPELL_GREATER_SPELL_MANTLE,oTarget) || GetHasSpellEffect(SPELL_SHADOW_SHIELD,oTarget)))
        {
            if(GetHasSpell(SPELL_LESSER_SPELL_BREACH))
                return SPELL_LESSER_SPELL_BREACH;
            else if(GetHasSpell(SPELL_GREATER_SPELL_BREACH))
                return SPELL_GREATER_SPELL_BREACH;
        }
        return TRUE;
    }
    //1.72: smarter spell breach usage
    if(nSmart > 1 && bSpell && (nTalentId == SPELL_LESSER_SPELL_BREACH || nTalentId == SPELL_GREATER_SPELL_BREACH))
    {
        return GetHasSpellEffect(SPELL_GREATER_SPELL_MANTLE,oTarget) || GetHasSpellEffect(SPELL_PREMONITION,oTarget) ||
           GetHasSpellEffect(SPELL_SPELL_MANTLE,oTarget) || GetHasSpellEffect(SPELL_SHADOW_SHIELD,oTarget) ||
           GetHasSpellEffect(SPELL_GREATER_STONESKIN,oTarget) || GetHasSpellEffect(SPELL_ETHEREAL_VISAGE,oTarget) ||
           GetHasSpellEffect(SPELL_GLOBE_OF_INVULNERABILITY,oTarget) || GetHasSpellEffect(SPELL_ENERGY_BUFFER,oTarget) ||
           GetHasSpellEffect(SPELL_ETHEREALNESS,oTarget) || GetHasSpellEffect(SPELL_MINOR_GLOBE_OF_INVULNERABILITY,oTarget) ||
           GetHasSpellEffect(SPELL_SPELL_RESISTANCE,oTarget) || GetHasSpellEffect(SPELL_STONESKIN,oTarget) ||
           GetHasSpellEffect(SPELL_LESSER_SPELL_MANTLE,oTarget) || GetHasSpellEffect(SPELL_MESTILS_ACID_SHEATH,oTarget) ||
           GetHasSpellEffect(SPELL_MIND_BLANK,oTarget) || GetHasSpellEffect(SPELL_ELEMENTAL_SHIELD,oTarget) ||
           GetHasSpellEffect(SPELL_PROTECTION_FROM_SPELLS,oTarget) || GetHasSpellEffect(SPELL_PROTECTION_FROM_ELEMENTS,oTarget) ||
           GetHasSpellEffect(SPELL_RESIST_ELEMENTS,oTarget) || GetHasSpellEffect(SPELL_DEATH_ARMOR,oTarget) ||
           GetHasSpellEffect(SPELL_GHOSTLY_VISAGE,oTarget) || GetHasSpellEffect(SPELL_SHADOW_CONJURATION_MAGE_ARMOR,oTarget) ||
           GetHasSpellEffect(SPELL_NEGATIVE_ENERGY_PROTECTION,oTarget) || GetHasSpellEffect(SPELL_LESSER_MIND_BLANK,oTarget);
    }
    return TRUE;
}

int TalentShapechange(object oIntruder = OBJECT_INVALID, int bStart=FALSE)
{
    effect eSearch = GetFirstEffect(OBJECT_SELF);
    while(GetIsEffectValid(eSearch))
    {
        if(GetEffectType(eSearch) == EFFECT_TYPE_POLYMORPH)
        {
            break;
        }
        eSearch = GetNextEffect(OBJECT_SELF);
    }
  if(bStart)
  {
    if(GetIsEffectValid(eSearch))//is in polymorph
    {
        object oCreator = GetEffectCreator(eSearch);
        //subject of someone else's polymorph
        if(GetIsObjectValid(oCreator) && oCreator != OBJECT_SELF && GetObjectType(oCreator) == OBJECT_TYPE_CREATURE && !GetIsReactionTypeFriendly(oCreator))
        {
            //shapechangers can cancel hostile polymorph effects
            if(GetRacialType(OBJECT_SELF) == RACIAL_TYPE_SHAPECHANGER || GetLevelByClass(CLASS_TYPE_SHIFTER) > 0)
            {
                ClearAllActions();
                ActionPlayAnimation(ANIMATION_LOOPING_CONJURE1,1.0,3.0);
                ActionDoCommand(RemoveEffect(OBJECT_SELF,eSearch));
                return TRUE;
            }
        }
        talent tBreath,tPulse,tUse;
        switch(GetAppearanceType(OBJECT_SELF))
        {
        case APPEARANCE_TYPE_CHICKEN:
            if(GetAbilityScore(OBJECT_SELF,ABILITY_STRENGTH,TRUE) >= 34) break;//super chicken polymorph, this one should fight back
        case APPEARANCE_TYPE_PENGUIN:
        case APPEARANCE_TYPE_COW:
            //special behavior, if npc is polymorphed into one of these shapes, it will not try to fight at all
            if(!GetIsObjectValid(oIntruder) || GetIsDead(oIntruder))
            {
                oIntruder = GetLastHostileActor();
                if(!GetIsObjectValid(oIntruder) || GetIsDead(oIntruder))
                {
                    oIntruder = GetNearestCreature(CREATURE_TYPE_REPUTATION,REPUTATION_TYPE_ENEMY,OBJECT_SELF,1,CREATURE_TYPE_PERCEPTION,PERCEPTION_SEEN);
                }
            }
            if(GetIsObjectValid(oIntruder) && !GetIsDead(oIntruder))
            {
                ClearAllActions();
                ActionMoveAwayFromObject(oIntruder, TRUE, 10.0);
                DelayCommand(4.0, ClearAllActions());
                return TRUE;
            }
        break;
        case APPEARANCE_TYPE_DRAGON_BLUE:
        tBreath = TalentSpell(796);
        break;
        case APPEARANCE_TYPE_DRAGON_GREEN:
        tBreath = TalentSpell(798);
        break;
        case APPEARANCE_TYPE_DRAGON_RED:
        tBreath = TalentSpell(797);
        break;
        case APPEARANCE_TYPE_ELEMENTAL_WATER:
        case APPEARANCE_TYPE_ELEMENTAL_WATER_ELDER:
        tPulse = TalentSpell(SPELLABILITY_PULSE_DROWN);
        break;
        case APPEARANCE_TYPE_ELEMENTAL_AIR:
        case APPEARANCE_TYPE_ELEMENTAL_AIR_ELDER:
        tPulse = TalentSpell(SPELLABILITY_PULSE_WHIRLWIND);
        break;
        case APPEARANCE_TYPE_BASILISK:
        case APPEARANCE_TYPE_MEDUSA:
        if(GetLocalInt(OBJECT_SELF,"X2_GWILDSHP_LIMIT_687") > 0 && !GetHasEffect(EFFECT_TYPE_PETRIFY,oIntruder))
        {
            tBreath = TalentSpell(687);
        }
        break;
        case APPEARANCE_TYPE_MANTICORE:
        tBreath = TalentSpell(692);
        break;
        case APPEARANCE_TYPE_HARPY:
        tUse = TalentSpell(686);
        if(!GetHasSpellEffect(686) && GetCreatureHasTalent(tUse) && !GetHasEffect(EFFECT_TYPE_SILENCE,OBJECT_SELF))
        {
            ClearAllActions();
            ActionUseTalentOnObject(tUse,OBJECT_SELF);
            return TRUE;
        }
        break;
        case APPEARANCE_TYPE_MINDFLAYER:
        tUse = TalentSpell(741);
        if(!GetHasSpellEffect(741) && GetCreatureHasTalent(tUse))
        {
            ClearAllActions();
            ActionCastSpellAtObject(GetIdFromTalent(tUse),OBJECT_SELF,METAMAGIC_ANY,TRUE);
            return TRUE;
        }
        if(GetLocalInt(OBJECT_SELF,"X2_GWILDSHP_LIMIT_693") > 0 && !GetHasSpellEffect(693,oIntruder))
        {
            tBreath = TalentSpell(693);
        }
        break;
        case APPEARANCE_TYPE_SPECTRE:
        tBreath = TalentSpell(802);
        break;
        case APPEARANCE_TYPE_VAMPIRE_FEMALE:
        case APPEARANCE_TYPE_VAMPIRE_MALE:
        if(GetLocalInt(OBJECT_SELF,"X2_GWILDSHP_LIMIT_800") > 0 && !GetHasSpellEffect(800,oIntruder))
        {
            tBreath = TalentSpell(800);
        }
        break;
        case APPEARANCE_TYPE_RAKSHASA_TIGER_FEMALE:
        case APPEARANCE_TYPE_RAKSHASA_TIGER_MALE:
        tUse = d4() == 1 ? TalentSpell(SPELL_MESTILS_ACID_BREATH) : TalentSpell(SPELL_ICE_STORM);
        if(GetCreatureHasTalent(tUse))
        {
            ClearAllActions();
            ActionUseTalentOnObject(tUse,oIntruder);
            return TRUE;
        }
        break;
        }
        if(GetIsTalentValid(tBreath) && GetCreatureHasTalent(tBreath) && GetLocalInt(OBJECT_SELF, "NW_GENERIC_DRAGONS_BREATH") >= 2)
        {
            SetLocalInt(OBJECT_SELF, "NW_GENERIC_DRAGONS_BREATH", 0);
            ClearAllActions();
            ActionCastSpellAtObject(GetIdFromTalent(tBreath),oIntruder,METAMAGIC_ANY,TRUE);//workaround for bug in ActionUseTalent which fails in this case
            return TRUE;
        }
        else if(GetIsTalentValid(tPulse) && GetCreatureHasTalent(tPulse) && GetLocalInt(OBJECT_SELF, "NW_GENERIC_DRAGONS_BREATH") >= 3)
        {
            if(GetIdFromTalent(tPulse) != SPELLABILITY_PULSE_DROWN || GetCurrentHitPoints() < GetMaxHitPoints()/5)//use the drowning pulse only if on less than 20% HPs
            {
                SetLocalInt(OBJECT_SELF, "NW_GENERIC_DRAGONS_BREATH", 0);
                ClearAllActions();
                ActionCastSpellAtObject(GetIdFromTalent(tPulse),oIntruder,METAMAGIC_ANY,TRUE);//workaround for bug in ActionUseTalent which fails in this case
                return TRUE;
            }
        }
        return FALSE;
    }
  }
  else if(!GetIsEffectValid(eSearch))//not in polymorph
  {
    if(!GetLocalInt(OBJECT_SELF,"70_ALLOW_SHAPECHANGE")) return FALSE;//not allowed to polymorph

    if(GetHasFeat(FEAT_EPIC_WILD_SHAPE_DRAGON))
    {
        ClearAllActions();
        ActionUseFeat(FEAT_EPIC_WILD_SHAPE_DRAGON,OBJECT_SELF);
        return TRUE;
    }
    else if(GetHasFeat(FEAT_EPIC_WILD_SHAPE_UNDEAD))
    {
        ClearAllActions();
        ActionUseFeat(FEAT_EPIC_WILD_SHAPE_UNDEAD,OBJECT_SELF);
        return TRUE;
    }
    else if(GetHasFeat(FEAT_EPIC_OUTSIDER_SHAPE))
    {
        ClearAllActions();
        ActionUseFeat(FEAT_EPIC_OUTSIDER_SHAPE,OBJECT_SELF);
        return TRUE;
    }
    else if(GetHasFeat(FEAT_EPIC_CONSTRUCT_SHAPE))
    {
        ClearAllActions();
        ActionUseFeat(FEAT_EPIC_CONSTRUCT_SHAPE,OBJECT_SELF);
        return TRUE;
    }
    else if(GetHasFeat(FEAT_HUMANOID_SHAPE))
    {
        ClearAllActions();
        ActionUseFeat(FEAT_HUMANOID_SHAPE,OBJECT_SELF);
        return TRUE;
    }
    else if(GetHasFeat(FEAT_GREATER_WILDSHAPE_4))
    {
        ClearAllActions();
        ActionUseFeat(FEAT_GREATER_WILDSHAPE_4,OBJECT_SELF);
        return TRUE;
    }
    else if(GetHasFeat(FEAT_ELEMENTAL_SHAPE))
    {
        ClearAllActions();
        ActionUseFeat(FEAT_ELEMENTAL_SHAPE,OBJECT_SELF);
        return TRUE;
    }
    else if(GetHasSpell(SPELL_SHAPECHANGE))
    {
        ClearAllActions();
        ActionCastSpellAtObject(SPELL_SHAPECHANGE,OBJECT_SELF);
        return TRUE;
    }
    else if(GetHasSpell(SPELL_TENSERS_TRANSFORMATION))
    {
        ClearAllActions();
        ActionCastSpellAtObject(SPELL_TENSERS_TRANSFORMATION,OBJECT_SELF);
        return TRUE;
    }
    else if(GetHasFeat(FEAT_GREATER_WILDSHAPE_3))
    {
        ClearAllActions();
        ActionUseFeat(FEAT_GREATER_WILDSHAPE_3,OBJECT_SELF);
        return TRUE;
    }
    else if(GetHasFeat(FEAT_GREATER_WILDSHAPE_2))
    {
        ClearAllActions();
        ActionUseFeat(FEAT_GREATER_WILDSHAPE_2,OBJECT_SELF);
        return TRUE;
    }
    if(GetChallengeRating(OBJECT_SELF) < 8.0)//remaining polymorphs are only for weak creatures
    {
        if(GetHasFeat(FEAT_GREATER_WILDSHAPE_1))
        {
            ClearAllActions();
            ActionUseFeat(FEAT_GREATER_WILDSHAPE_1,OBJECT_SELF);
            return TRUE;
        }
        else if(GetHasFeat(FEAT_WILD_SHAPE))
        {
            ClearAllActions();
            ActionUseFeat(FEAT_WILD_SHAPE,OBJECT_SELF);
            return TRUE;
        }
        else if(GetHasSpell(SPELL_POLYMORPH_SELF))
        {
            ClearAllActions();
            ActionCastSpellAtObject(SPELL_POLYMORPH_SELF,OBJECT_SELF);
            return TRUE;
        }
    }
  }
    return FALSE;
}
