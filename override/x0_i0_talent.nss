//:://////////////////////////////////////////////////
//:: X0_I0_TALENT
/*
  Library for talent functions.

  All of these functions attempt to use a particular category
  of skill, and return TRUE on success, FALSE on failure. This
  allows for building up fall-through chains where one talent
  after another is attempted, with the order determined by the
  creature's particular tactics.

 */
//:://////////////////////////////////////////////////
//:: Copyright (c) 2002 Floodgate Entertainment
//:: Created By: Naomi Novik
//:: Created On: 01/20/2003
//:: Modified By: Georg Zoeller, 2003-Oct-21:
//::        - commented debug strings
//::        - updated talent advanced buff to include some xp2 stuff          \
//::        - added some code to prevent TalentBardsong from breaking in
//::          epic levels
//:://////////////////////////////////////////////////

#include "70_inc_ai"
#include "x0_inc_generic"
//void main(){}
/**********************************************************************
 * CONSTANTS
 **********************************************************************/

// Added by Brent, constant for 'always get me it' things like Healing
const int TALENT_ANY = 20;


// Bitwise constants for negative conditions we might want to try to cure
const int COND_CURSE     = 0x00000001;
const int COND_POISON    = 0x00000002;
const int COND_DISEASE   = 0x00000004;
const int COND_ABILITY   = 0x00000008;
const int COND_DRAINED   = 0x00000010;
const int COND_BLINDDEAF = 0x00000020;
const int COND_FEAR             = 0x00000040;//1.72
const int COND_MINDAFFECTING    = 0x00000080;//1.72
const int COND_IMPAIREDMOBILITY = 0x00000100;//1.72
const int COND_PETRIFY          = 0x00000200;//1.72

const float WHIRL_DISTANCE = 3.0; // * Shortened distance so its more effective (went from 5.0 to 2.0 and up to 3.0)

/**********************************************************************
 * FUNCTION PROTOTYPES
 **********************************************************************/

// Buff OBJECT_SELF if OBJECT_SELF isn't already buffed with the particular spell
void BuffIfNotBuffed(int bSpell, int bInstant)
{
    if(GetHasSpell(bSpell) && !GetHasSpellEffect(bSpell))
    {
      ActionCastSpellAtObject(bSpell, OBJECT_SELF, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, bInstant);
    }
}

 // * Tries to do the Ki Damage ability
int TryKiDamage(object oTarget)
{
    if (!GetIsObjectValid(oTarget))
    {
        return FALSE;

    }
    if (GetHasFeat(FEAT_KI_DAMAGE))
    {
        // * Evaluation:
        // * Must have > 40 hitpoints AND  (damage reduction OR damage resistance)
        // * Or just have over 200 hitpoints
        int bHasDamageReduction = FALSE;
        int bHasDamageResistance = FALSE;
        int bHasHitpoints = FALSE;
        int bHasMassiveHitpoints = FALSE;
        int bOutNumbered = FALSE;

        int nCurrentHP = GetCurrentHitPoints(oTarget);
        if (nCurrentHP > 40)
            bHasHitpoints = TRUE;
        if (nCurrentHP > 200)
            bHasMassiveHitpoints = TRUE;
        if (GetHasEffect(EFFECT_TYPE_DAMAGE_REDUCTION, oTarget))
            bHasDamageReduction = TRUE;
        if (GetHasEffect(EFFECT_TYPE_DAMAGE_RESISTANCE, oTarget))
            bHasDamageResistance = TRUE;

        if (GetIsObjectValid(GetNearestEnemy(OBJECT_SELF, 3)))
        {
            bOutNumbered = TRUE;
        }

        if ((bHasHitpoints && (bHasDamageReduction || bHasDamageResistance)) || bHasMassiveHitpoints || (bHasHitpoints && bOutNumbered))
        {
            ClearAllActions();
            ActionUseFeat(FEAT_KI_DAMAGE, oTarget);
            return TRUE;
        }
    }
    return FALSE;
}

// Try a spell to produce a particular spell effect.
// This will only cast the spell if the target DOES NOT already have the
// given spell effect, and the caster possesses the spell.
//
// Returns TRUE on success, FALSE on failure.
int TrySpell(int nSpell, object oTarget=OBJECT_SELF, object oCaster=OBJECT_SELF);

// Try a spell corresponding to a particular effect.
// This will only cast the spell if the target DOES have the
// given effect, and the caster possesses the spell.
//
// Returns TRUE on success, FALSE on failure.
int TrySpellForEffect(int nSpell, int nEffect, object oTarget=OBJECT_SELF, object oCaster=OBJECT_SELF);

// Try a given talent.
// This will only cast spells and feats if the targets do not already
// have the effects of those feats, and will funnel all talents
// through bkTalentFilter for a final check.
int TryTalent(talent tUse, object oTarget=OBJECT_SELF, object oCaster=OBJECT_SELF);

// PROTECT SELF
// Returns TRUE on successful use of such a talent, FALSE otherwise.
int TalentUseProtectionOnSelf();

// PROTECT PARTY
// Returns TRUE on successful use of such a talent, FALSE otherwise.
int TalentUseProtectionOthers(object oDefault=OBJECT_INVALID);

// ENHANCE OTHERS
// Returns TRUE on successful use of such a talent, FALSE otherwise.
int TalentEnhanceOthers();

// ENHANCE SELF
// Returns TRUE on successful use of such a talent, FALSE otherwise.
int TalentUseEnhancementOnSelf();

// SPELL CASTER MELEE ATTACKED
//    Wrote this function so I could do further
//   checks such as making them not cast
//    Dispel Magic.
// * Possible Issue (brent): It may get stuck on
// * dispel magics...trying to cast them
// * and not proceed down Area Of Effect Discriminants...
//  SOLUTION: If this function returns true the TalentMeleeAttacked routine
//  will exit, however if it returns false, it will try and find some
//  other ability to use.
int genericDoHarmfulRangedAttack(talent tUse, object oTarget);

//    Will return true if it succesfully
//    used a harmful ranged talent.
int genericAttemptHarmfulRanged(talent tUse, object oTarget);

// MELEE ATTACKED
// Returns TRUE on successful use of such a talent, FALSE otherwise.
int TalentMeleeAttacked(object oIntruder = OBJECT_INVALID);

// SPELL CASTER RANGED ATTACKED
// Returns TRUE on successful use of such a talent, FALSE otherwise.
int TalentRangedAttackers(object oIntruder = OBJECT_INVALID);

// SPELL CASTER WITH RANGED ENEMIES
// Returns TRUE on successful use of such a talent, FALSE otherwise.
int TalentRangedEnemies(object oIntruder = OBJECT_INVALID);

// SUMMON ALLIES
// Returns TRUE on successful use of such a talent, FALSE otherwise.
int TalentSummonAllies();

// HEAL SELF WITH POTIONS AND SPELLS
// Returns TRUE on successful use of such a talent, FALSE otherwise.
int TalentHealingSelf(int bForce = FALSE); //Use spells and potions

//Use spells only on others and self
// Returns TRUE on successful use of such a talent, FALSE otherwise.
int TalentHeal(int nForce = FALSE, object oTarget = OBJECT_SELF);

// MELEE ATTACK OTHERS
//     ISSUE 1: Talent Melee Attack should set the Last Spell Used
//     to 0 so that melee casters can use a single special ability.
// Returns TRUE on successful use of such a talent, FALSE otherwise.
int TalentMeleeAttack(object oIntruder = OBJECT_INVALID);

// SNEAK ATTACK OTHERS
// Returns TRUE on successful use of such a talent, FALSE otherwise.
int TalentSneakAttack();

// FLEE COMBAT AND HOSTILES
// Returns TRUE on successful use of such a talent, FALSE otherwise.
int TalentFlee(object oIntruder = OBJECT_INVALID);

// TURN UNDEAD
// Returns TRUE on successful use of such a talent, FALSE otherwise.
int TalentUseTurning();

// ACTIVATE AURAS
// Returns TRUE on successful use of such a talent, FALSE otherwise.
int TalentPersistentAbilities();

// FAST BUFF SELF
// Returns TRUE on successful use of such a talent, FALSE otherwise.
int TalentAdvancedBuff(float fDistance, int bInstant = TRUE);

// USE POTIONS
//Used for Potions of Enhancement and Protection
// Returns TRUE on successful use of such a talent, FALSE otherwise.
int TalentBuffSelf();

// USE SPELLS TO DEFEAT INVISIBLE CREATURES
// THIS TALENT IS NOT USED
// Returns TRUE on successful use of such a talent, FALSE otherwise.
int TalentSeeInvisible();

// Utility function for TalentCureCondition
// Checks to see if the creature has the given condition in the
// given condition value.
// To use, you must first calculate the nCurrentConditions value
// with GetCurrentNegativeConditions.
// The value of nCondition can be any of the COND_* constants
// declared in x0_i0_talent.
int GetHasNegativeCondition(int nCondition, int nCurrentConditions);

// Utility function for TalentCureCondition
// Returns an integer with bitwise flags set that represent the
// current negative conditions on the creature.
// To be used with GetHasNegativeCondition.
int GetCurrentNegativeConditions(object oCreature);

// CURE DISEASE, POISON ETC
// Returns TRUE on successful use of such a talent, FALSE otherwise.
int TalentCureCondition();

// DRAGON COMBAT
// Returns TRUE on successful use of such a talent, FALSE otherwise.
int TalentDragonCombat(object oIntruder = OBJECT_INVALID);

// BARD SONG
// Returns TRUE on successful use of such a talent, FALSE otherwise.
int TalentBardSong();

// ADVANCED PROTECT SELF Talent 2.0
// This will use the class specific defensive spells first and
// leave the rest for the normal defensive AI
// Returns TRUE on successful use of such a talent, FALSE otherwise.
int TalentAdvancedProtectSelf();

// Cast a spell mantle or globe of invulnerability protection on
// yourself.
int TalentSelfProtectionMantleOrGlobe();

// Returns TRUE on successful use of such a talent, FALSE otherwise.
int TalentSpellAttack(object oIntruder);

// This function simply attempts to get the best protective
// talent that the caller has, the protective talents as
// follows:
// TALENT_CATEGORY_BENEFICIAL_PROTECTION_SELF
// TALENT_CATEGORY_BENEFICIAL_PROTECTION_SINGLE
// TALENT_CATEGORY_BENEFICIAL_PROTECTION_AREAEFFECT
talent StartProtectionLoop();


// * Wrapper function so that I could add a variable to allow randomization
// * to the AI.
// * WARNING: This will make the AI cast spells badly if they have a bad
// * spell selection (i.e., only turn randomization on if you know what you are doing
// *
// * nCRMax only applies if bRandom is FALSE
// * oCreature is the creature checking to see if it has the talent
talent GetCreatureTalent(int nCategory, int nCRMax, int bRandom=FALSE, object oCreature = OBJECT_SELF);

/**********************************************************************
 * FUNCTION DEFINITIONS
 **********************************************************************/

// Try a spell to produce a particular spell effect.
// This will only cast the spell if the target DOES NOT already have the
// given spell effect, and the caster possesses the spell.
//
// Returns TRUE on success, FALSE on failure.
int TrySpell(int nSpell, object oTarget=OBJECT_SELF, object oCaster=OBJECT_SELF)
{
    if (GetHasSpell(nSpell, oCaster) && !GetHasSpellEffect(nSpell, oTarget))
    {
        AssignCommand(oCaster, ActionCastSpellAtObject(nSpell, oTarget));
        return TRUE;
    }
    return FALSE;
}

// Try a spell corresponding to a particular effect.
// This will only cast the spell if the target DOES have the
// given effect, and the caster possesses the spell.
//
// Returns TRUE on success, FALSE on failure.
int TrySpellForEffect(int nSpell, int nEffect, object oTarget=OBJECT_SELF, object oCaster=OBJECT_SELF)
{
    if (GetHasSpell(nSpell, oCaster) && GetHasEffect(nEffect, oTarget))
    {
        AssignCommand(oCaster, ActionCastSpellAtObject(nSpell, oTarget));
        return TRUE;
    }
    return FALSE;
}

// Try a given talent.
// This will only cast spells and feats if the targets do not already
// have the effects of those feats, and will funnel all talents
// through bkTalentFilter for a final check.
int TryTalent(talent tUse, object oTarget=OBJECT_SELF, object oCaster=OBJECT_SELF)
{
    int nType = GetTypeFromTalent(tUse);
    int nIndex = GetIdFromTalent(tUse);
    if(nType == TALENT_TYPE_SPELL  && GetHasSpellEffect(nIndex, oTarget))
    {
        return FALSE;
    }
    else if(nType == TALENT_TYPE_FEAT && GetHasFeatEffect(nIndex, oTarget))
    {
        return FALSE;
    }
    // MODIFIED February 7 2003. Implicit else, implies success.
    if(bkTalentFilter(tUse, OBJECT_SELF))
    //MyPrintString("TryTalent Successful Exit");
        return TRUE;

    return FALSE;
}


//:://////////////////////////////////////////////////////////
//:: Talent checks and use functions
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////////////////
/*
    This is a series of functions that check
    if a particular type of talent is available and
    if so then use that talent.
*/
//:://////////////////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Oct 16, 2001
//:://////////////////////////////////////////////////////////

// PROTECT SELF
int TalentUseProtectionOnSelf()
{
    //MyPrintString("TalentUseProtectionOnSelf Enter");
    int nCR = GetCRMax();

    talent tUse = GetCreatureTalent(TALENT_CATEGORY_BENEFICIAL_PROTECTION_SELF, nCR);
    if(!GetIsTalentValid(tUse))
    {
        tUse = GetCreatureTalent(TALENT_CATEGORY_BENEFICIAL_PROTECTION_SINGLE, nCR);
    }

    if (GetIsTalentValid(tUse))
    {
        if (TryTalent(tUse))
        {
            //MyPrintString("TalentUseProtectionOnSelf Successful Exit");
            return TRUE;
        }
    }
    //MyPrintString("TalentUseProtectionOnSelf Failed Exit");
    return FALSE;
}

//PROTECT PARTY
int TalentUseProtectionOthers(object oDefault=OBJECT_INVALID)
{
    //MyPrintString("TalentUseProtectionOthers Enter");
    int nCnt = 1;
    int nCR = GetCRMax();

    talent tUse = GetCreatureTalent(TALENT_CATEGORY_BENEFICIAL_PROTECTION_SINGLE, nCR);
    talent tMass = GetCreatureTalent(TALENT_CATEGORY_BENEFICIAL_PROTECTION_AREAEFFECT, nCR);

    // Pausanias: added option for the spell to have a specified target.
    object oTarget = oDefault == OBJECT_INVALID ? GetNearestSeenFriend() : oDefault;

    //Override the nearest target if the master wants aggressive buff spells
    if(GetAssociateState(NW_ASC_AGGRESSIVE_BUFF) && GetAssociateState(NW_ASC_HAVE_MASTER))
    {
        oTarget = GetMaster();
    }

    while(GetIsObjectValid(oTarget))
    {
        if(GetIsTalentValid(tMass) && CheckFriendlyFireOnTarget(oTarget) > 2)
        {
            if (TryTalent(tMass, oTarget))
            {
                //MyPrintString("TalentUseProtectionOthers Successful Exit");
                return TRUE;
            }
        }
        if(GetIsTalentValid(tUse))
        {
            if (TryTalent(tUse, oTarget))
            {
                //MyPrintString("TalentUseProtectionOthers Successful Exit");
                return TRUE;
            }
        }
        oTarget = GetNearestSeenFriend(OBJECT_SELF, ++nCnt);
    }
    //MyPrintString("TalentUseProtectionOthers Failed Exit");
    return FALSE;
}

// ENHANCE OTHERS
int TalentEnhanceOthers()
{
    //MyPrintString("TalentEnhanceOthers Enter");
    int nCnt = 1;
    int nCR = GetCRMax();
    object oTarget = GetNearestSeenFriend();
    talent tUse = GetCreatureTalent(TALENT_CATEGORY_BENEFICIAL_ENHANCEMENT_SINGLE, nCR);
    talent tMass = GetCreatureTalent(TALENT_CATEGORY_BENEFICIAL_ENHANCEMENT_AREAEFFECT, nCR);

    //Override the nearest target if the master wants aggressive buff spells
    if(GetAssociateState(NW_ASC_AGGRESSIVE_BUFF) && GetAssociateState(NW_ASC_HAVE_MASTER))
    {
        oTarget = GetMaster();
    }
    while(GetIsObjectValid(oTarget))
    {
        if(GetIsTalentValid(tMass) && CheckFriendlyFireOnTarget(oTarget) > 2)
        {
            if (TryTalent(tMass, oTarget))
            {
                //MyPrintString("TalentEnhanceOthers Successful Exit");
                return TRUE;
            }
        }
        if(GetIsTalentValid(tUse))
        {
            if (TryTalent(tUse, oTarget))
            {
                    //MyPrintString("TalentEnhanceOthers Successful Exit");
                    return TRUE;
            }
        }
        oTarget = GetNearestSeenFriend(OBJECT_SELF, ++nCnt);
    }
    //MyPrintString("TalentEnhanceOthers Failed Exit");
    return FALSE;
}

// ENHANCE SELF
int TalentUseEnhancementOnSelf()
{
    //MyPrintString("TalentUseEnhancementOnSelf Enter");
    int nCR = GetCRMax();

    talent tUse = GetCreatureTalent(TALENT_CATEGORY_BENEFICIAL_ENHANCEMENT_SELF, nCR);
    if(!GetIsTalentValid(tUse))
    {
        tUse = GetCreatureTalent(TALENT_CATEGORY_BENEFICIAL_ENHANCEMENT_SINGLE, nCR);
    }

    if(GetIsTalentValid(tUse))
    {
        if (GetIdFromTalent(tUse) == SPELL_INVISIBILITY && Random(2) == 0)
        {
            //MyPrintString("Decided not to use Invisibility");
            return FALSE; // BRENT JULY 2002: There is a 50% chance that they will not use invisibility if they have it
        }
        if (TryTalent(tUse))
        {
            //MyPrintString("TalentUseEnhancementOnSelf Successful Exit");
            return TRUE;
        }
    }
    //MyPrintString("TalentUseEnhancementOnSelf Failed Exit");
    return FALSE;
}

// SPELL CASTER MELEE ATTACKED
//::///////////////////////////////////////////////
//:: genericDoHarmfulRangedAttack
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Wrote this function so I could do further
    checks such as making them not cast
    Dispel Magic.
// * Possible Issue (brent): It may get stuck on
// * dispel magics...trying to cast them
// * and not proceed down Area Of Effect Discriminants...
  SOLUTION: If this function returns true the TalentMeleeAttacked routine
  will exit, however if it returns false, it will try and find some
  other ability to use.

*/
//:://////////////////////////////////////////////
//:: Created By: Brent
//:: Created On: July 2002
//:://////////////////////////////////////////////

int genericDoHarmfulRangedAttack(talent tUse, object oTarget)
{
    //MyPrintString("BK: genericDoharmfulRangedAttack");

    int bConditionsMet;
    // * check to see if this talent is a spell talent
    if (GetTypeFromTalent(tUse) == TALENT_TYPE_SPELL)
    {
        int nSpellID = GetIdFromTalent(tUse);
        // * Check to see if Dispel Magic and similar spells should *not* be cast
        if (nSpellID == SPELL_DISPEL_MAGIC || nSpellID == SPELL_MORDENKAINENS_DISJUNCTION
           || nSpellID == SPELL_LESSER_DISPEL || nSpellID == SPELL_GREATER_DISPELLING)
        {
            //MyPrintString("BK: inside of dispel magic");
            effect eEffect = GetFirstEffect(oTarget);
            while (GetIsEffectValid(eEffect) == TRUE)
            {
                //MyPrintString("BK: Valid effect");
                int nEffectID = GetEffectSpellId(eEffect);
                // * JULY 14 2003
                // * If the effects originated from me (i.e., I cast
                // * a disabling effect on you. Then I will not
                // * dispel that effect
                if (GetEffectCreator(eEffect) == OBJECT_SELF)
                {

                  bConditionsMet = FALSE;
                  break;
                }
                else
                // * this effect was applied from a spell if it
                // * isn't -1
                // * dispel magic should only attempt to remove spell
                // * granted effects
                if (nEffectID == -1)
                {
                 //MyPrintString("BK: conditions NOT met");
                }
                else
                {
                    //MyPrintString("BK: conditions met");
                 bConditionsMet = TRUE;
                }
                eEffect = GetNextEffect(oTarget);
            }
        } else {
             // if not a special condition spell then conditions are met auto.
             bConditionsMet = TRUE;
        }
    }


    // * only returns true if all of the conditions are met.
    if (bConditionsMet)
    {
        //MyPrintString("BK: bCOnditionsMet == TRUE");
        //DebugPrintTalentID(tUse);
        //MyPrintString("TalentMeleeAttacked Successful Exit");
        if(bkTalentFilter(tUse, oTarget))
            return TRUE;
    }

    return FALSE;
}

//::///////////////////////////////////////////////
//:: genericAttemptHarmfulRanged
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Will return true if it succesfully
    used a harmful ranged talent.
    BK: Wrapper function to encapsulate some
    commonly used behavior in these
    scripts.
*/
//:://////////////////////////////////////////////
//:: Created By: Brent
//:: Created On: July 2002
//:://////////////////////////////////////////////

int genericAttemptHarmfulRanged(talent tUse, object oTarget)
{
    //SpawnScriptDebugger();
    if(  GetTypeFromTalent(tUse) != TALENT_TYPE_SPELL
         ||
         (GetTypeFromTalent(tUse) == TALENT_TYPE_SPELL
          && !GetHasSpellEffect(GetIdFromTalent(tUse), oTarget)
          && !CompareLastSpellCast(GetIdFromTalent(tUse)) )
      )
    {
        //MyPrintString("2164: Can try to do a DoHarmfulRangedAttack");
        if (genericDoHarmfulRangedAttack(tUse, oTarget)) {
            if( GetTypeFromTalent(tUse) == TALENT_TYPE_SPELL) {
                SetLastGenericSpellCast(GetIdFromTalent(tUse));
            }
            return TRUE;
        }
    }
    else
    // MODIFIED
    // Try to find a suitable second choice (up to 5 tries to find one)
    {
    int nSteps = 0;
    int bDone = FALSE;


      while (!bDone)
      {
        if (nSteps > 4)
            bDone = TRUE;

        nSteps++;

        tUse = GetCreatureTalentRandom(TALENT_CATEGORY_HARMFUL_RANGED);
        if (GetTypeFromTalent(tUse) != TALENT_TYPE_SPELL ||
          (GetTypeFromTalent(tUse) == TALENT_TYPE_SPELL
           && !GetHasSpellEffect(GetIdFromTalent(tUse), oTarget)
           && !CompareLastSpellCast(GetIdFromTalent(tUse)) )
           )
           {
              if (genericDoHarmfulRangedAttack(tUse, oTarget))
              {
                    if( GetTypeFromTalent(tUse) == TALENT_TYPE_SPELL)
                    {
                                 SetLastGenericSpellCast(GetIdFromTalent(tUse));
                    }
                  return TRUE;
              }
           }
       }
       // * End modification to loop through available talents

    }
    // else
    //MyPrintString("BK: Harmful Ranged will return false");
    return FALSE;
}

int TalentMeleeAttacked(object oIntruder = OBJECT_INVALID)
{
    //MyPrintString("TalentMeleeAttacked Enter");
    talent tUse;
    int nMelee = GetNumberOfMeleeAttackers();
    object oTarget = oIntruder;
    int nCR = GetCRMax();

    if(!GetIsObjectValid(oIntruder) && GetIsObjectValid(GetLastHostileActor()))
    {
        oTarget = GetLastHostileActor();
    }
    else
    {
        return FALSE;
    }

    /*
        ISSUE 1: The check in this function to use a random ability
        after failing to use best will fail in the following
        case.  The creature is unable to affect the target with
        the spell and has only 1 spell of that type.  This can
        be eliminated with a check in the else to the effect of :

            else if(!CompareLastSpellCast(GetIdFromTalent(tUse)))

        This check was not put in in version 1.0 due to time constraints.

        ISSUE 2: Given the Spell Attack is the drop out check the
        else statements in this talent should be cut.
    */

    if(nMelee == 1)
    {
        tUse = GetCreatureTalent(TALENT_CATEGORY_HARMFUL_TOUCH, nCR);
        if(GetIsTalentValid(tUse))
        {
            if( (GetTypeFromTalent(tUse) == TALENT_TYPE_SPELL &&
                !GetHasSpellEffect(GetIdFromTalent(tUse), oTarget) &&
                !CompareLastSpellCast(GetIdFromTalent(tUse)) ) ||
                GetTypeFromTalent(tUse) != TALENT_TYPE_SPELL )
            {
                if( GetTypeFromTalent(tUse) == TALENT_TYPE_SPELL)
                {
                    SetLastGenericSpellCast(GetIdFromTalent(tUse));
                }
                //DebugPrintTalentID(tUse);
                //MyPrintString("TalentMeleeAttacked HARMFUL TOUCH Successful Exit");
                if(bkTalentFilter(tUse, oTarget))
                    return TRUE;
            }
        }

        tUse = GetCreatureTalent(TALENT_CATEGORY_HARMFUL_RANGED, nCR);
        if(GetIsTalentValid(tUse))
        {
            // * BK: July 2002: Wrapped up harmful ranged into
            // * a function to make it easier to make global
            // * changes to the decision making process.
            if (genericAttemptHarmfulRanged(tUse, oTarget))
            {
                return TRUE;
            }
        }

        tUse = GetCreatureTalent(TALENT_CATEGORY_HARMFUL_AREAEFFECT_DISCRIMINANT, nCR);
        if(GetIsTalentValid(tUse))
        {
            if( (GetTypeFromTalent(tUse) == TALENT_TYPE_SPELL &&
                !GetHasSpellEffect(GetIdFromTalent(tUse), oTarget) &&
                !CompareLastSpellCast(GetIdFromTalent(tUse)) ) ||
                GetTypeFromTalent(tUse) != TALENT_TYPE_SPELL )
            {
                if( GetTypeFromTalent(tUse) == TALENT_TYPE_SPELL)
                {
                    SetLastGenericSpellCast(GetIdFromTalent(tUse));
                }
                //DebugPrintTalentID(tUse);
                //MyPrintString("TalentMeleeAttacked AREAEFFECT D Successful Exit");
                if(bkTalentFilter(tUse, oTarget))
                    return TRUE;
            }
        }
    }
    else if (nMelee > 1)
    {
        tUse = GetCreatureTalent(TALENT_CATEGORY_HARMFUL_AREAEFFECT_DISCRIMINANT, nCR);
        if(GetIsTalentValid(tUse))
        {
             if( (GetTypeFromTalent(tUse) == TALENT_TYPE_SPELL &&
                !GetHasSpellEffect(GetIdFromTalent(tUse), oTarget) &&
                !CompareLastSpellCast(GetIdFromTalent(tUse)) ) ||
                GetTypeFromTalent(tUse) != TALENT_TYPE_SPELL )
             {
                if( GetTypeFromTalent(tUse) == TALENT_TYPE_SPELL)
                {
                    SetLastGenericSpellCast(GetIdFromTalent(tUse));
                }
                //DebugPrintTalentID(tUse);
                //MyPrintString("TalentMeleeAttacked AREA EFFECT DSuccessful Exit");
                if(bkTalentFilter(tUse, oTarget))
                    return TRUE;
            }
        }
        tUse = GetCreatureTalent(TALENT_CATEGORY_HARMFUL_TOUCH, nCR);
        if(GetIsTalentValid(tUse))
        {
            if( (GetTypeFromTalent(tUse) == TALENT_TYPE_SPELL &&
                !GetHasSpellEffect(GetIdFromTalent(tUse), oTarget) &&
                !CompareLastSpellCast(GetIdFromTalent(tUse)) ) ||
                GetTypeFromTalent(tUse) != TALENT_TYPE_SPELL )
            {
                if( GetTypeFromTalent(tUse) == TALENT_TYPE_SPELL)
                {
                    SetLastGenericSpellCast(GetIdFromTalent(tUse));
                }
                //DebugPrintTalentID(tUse);
                //MyPrintString("TalentMeleeAttacked HARMFUL TOUCH Successful Exit");
                if(bkTalentFilter(tUse, oTarget))
                    return TRUE;
            }
        }

         tUse = GetCreatureTalent(TALENT_CATEGORY_HARMFUL_RANGED, nCR);
        if(GetIsTalentValid(tUse))
        {
            // * BK: July 2002: Wrapped up harmful ranged into
            // * a function to make it easier to make global
            // * changes to the decision making process.
            if (genericAttemptHarmfulRanged(tUse, oTarget))
            {
                //MyPrintString("TalentMeleeAttacked HARMFUL RANGED Successful Exit");

                return TRUE;
            }
        }

    }
    //MyPrintString("TalentMeleeAttacked Failed Exit");
    return FALSE;
}

// SPELL CASTER RANGED ATTACKED
int TalentRangedAttackers(object oIntruder = OBJECT_INVALID)
{
    //MyPrintString("TalentRangedAttackers Enter");
    //Check for Single Ranged Targets
    talent tUse;
    object oTarget = oIntruder;
    int nCR = GetCRMax();
    if(!GetIsObjectValid(oIntruder))
    {
        oTarget = GetLastHostileActor();
    }
    if(GetIsObjectValid(oTarget) && GetDistanceBetween(oTarget, OBJECT_SELF) > 5.0)
    {
        if(CheckFriendlyFireOnTarget(oTarget) > 0)
        {
            tUse = GetCreatureTalent(TALENT_CATEGORY_HARMFUL_AREAEFFECT_DISCRIMINANT, nCR);
            if(GetIsTalentValid(tUse))
            {
                if( (GetTypeFromTalent(tUse) == TALENT_TYPE_SPELL &&
                    !GetHasSpellEffect(GetIdFromTalent(tUse), oTarget) &&
                    !CompareLastSpellCast(GetIdFromTalent(tUse)) ) ||
                    GetTypeFromTalent(tUse) != TALENT_TYPE_SPELL )
                {
                    if( GetTypeFromTalent(tUse) == TALENT_TYPE_SPELL)
                    {
                        SetLastGenericSpellCast(GetIdFromTalent(tUse));
                    }
                    // DebugPrintTalentID(tUse);
                    //MyPrintString("TalentRangedAttackers Successful Exit");
                    if(bkTalentFilter(tUse, oTarget))
                        return TRUE;
                }
            }
        }
        else if(CheckEnemyGroupingOnTarget(oTarget) > 0)
        {
            tUse = GetCreatureTalent(TALENT_CATEGORY_HARMFUL_AREAEFFECT_INDISCRIMINANT, nCR);


            if(GetIsTalentValid(tUse))
            {

            //MyPrintString("2346 : Choose Talent here " + IntToString(nCR));
                if( (GetTypeFromTalent(tUse) == TALENT_TYPE_SPELL &&
                    !GetHasSpellEffect(GetIdFromTalent(tUse), oTarget) &&
                    !CompareLastSpellCast(GetIdFromTalent(tUse)) ) ||
                    GetTypeFromTalent(tUse) != TALENT_TYPE_SPELL )
                {
                    if( GetTypeFromTalent(tUse) == TALENT_TYPE_SPELL)
                    {
                        SetLastGenericSpellCast(GetIdFromTalent(tUse));
                    }
                    // DebugPrintTalentID(tUse);
                    //MyPrintString("TalentRangedAttackers Successful Exit");
                    if(bkTalentFilterLoc(tUse,GetLocation(oTarget)))
                        return TRUE;
                }
            }
        }
        else
        {
            tUse = GetCreatureTalent(TALENT_CATEGORY_HARMFUL_RANGED, nCR);
            if(GetIsTalentValid(tUse))
            {
                // * BK: July 2002: Wrapped up harmful ranged into
                // * a function to make it easier to make global
                // * changes to the decision making process.
                if (genericAttemptHarmfulRanged(tUse, oTarget))
                {
                    return TRUE;
                }
            }
       }
    }
    //MyPrintString("TalentRangedAttackers Failed Exit");
    return FALSE;
}

// SPELL CASTER WITH RANGED ENEMIES
int TalentRangedEnemies(object oIntruder = OBJECT_INVALID)
{
    //MyPrintString("TalentRangedEnemies Enter");
    talent tUse;
    object oTarget = oIntruder;
    int nCR = GetCRMax();
    if(!GetIsObjectValid(oIntruder))
    {
        oTarget = GetNearestSeenEnemy();
    }

    if(GetIsObjectValid(oTarget))
    {
        int nEnemy = CheckEnemyGroupingOnTarget(oTarget);
        if(CheckFriendlyFireOnTarget(oTarget) > 0 && nEnemy > 0)
        {
            tUse = GetCreatureTalent(TALENT_CATEGORY_HARMFUL_AREAEFFECT_DISCRIMINANT, nCR);
            if(GetIsTalentValid(tUse))
            {
                if( (GetTypeFromTalent(tUse) == TALENT_TYPE_SPELL &&
                    !GetHasSpellEffect(GetIdFromTalent(tUse), oTarget) &&
                    !CompareLastSpellCast(GetIdFromTalent(tUse)) ) ||
                    GetTypeFromTalent(tUse) != TALENT_TYPE_SPELL )
                {
                    if( GetTypeFromTalent(tUse) == TALENT_TYPE_SPELL)
                    {
                        SetLastGenericSpellCast(GetIdFromTalent(tUse));
                    }
                    // DebugPrintTalentID(tUse);
                    //MyPrintString("TalentRangedEnemies Successful Exit");
                    // * ONLY TalentFilter not to have a ClarAllActions before it(February 6 2003)
                    if(bkTalentFilter(tUse, oTarget))
                        return TRUE;
                }
            }
        }
        else if(nEnemy > 0)
        {
            tUse = GetCreatureTalent(TALENT_CATEGORY_HARMFUL_AREAEFFECT_INDISCRIMINANT, nCR);

            if(GetIsTalentValid(tUse))
            {
                //MyPrintString("2428 : Choose Talent here " + IntToString(nCR));

              if( (GetTypeFromTalent(tUse) == TALENT_TYPE_SPELL &&
                    !GetHasSpellEffect(GetIdFromTalent(tUse), oTarget) &&
                    !CompareLastSpellCast(GetIdFromTalent(tUse)) ) ||
                    GetTypeFromTalent(tUse) != TALENT_TYPE_SPELL )
                {
                    if( GetTypeFromTalent(tUse) == TALENT_TYPE_SPELL)
                    {
                        SetLastGenericSpellCast(GetIdFromTalent(tUse));
                    }
                    // DebugPrintTalentID(tUse);
                    //MyPrintString("TalentRangedEnemies Successful Exit");
                    if(bkTalentFilterLoc(tUse,GetLocation(oTarget)))
                        return TRUE;
                }
            }
            else
            {
                tUse = GetCreatureTalent(TALENT_CATEGORY_HARMFUL_AREAEFFECT_DISCRIMINANT, nCR);
                if(GetIsTalentValid(tUse))
                {
                    if( (GetTypeFromTalent(tUse) == TALENT_TYPE_SPELL &&
                        !GetHasSpellEffect(GetIdFromTalent(tUse), oTarget) &&
                        !CompareLastSpellCast(GetIdFromTalent(tUse)) ) ||
                        GetTypeFromTalent(tUse) != TALENT_TYPE_SPELL )
                    {
                        if( GetTypeFromTalent(tUse) == TALENT_TYPE_SPELL)
                        {
                            SetLastGenericSpellCast(GetIdFromTalent(tUse));
                        }
                        // DebugPrintTalentID(tUse);
                        //MyPrintString("TalentRangedEnemies Successful Exit");
                        if(bkTalentFilter(tUse, oTarget))
                            return TRUE;
                    }
                }
            }
        }
        else if(GetDistanceToObject(oTarget) > 5.0)
        {
           tUse = GetCreatureTalent(TALENT_CATEGORY_HARMFUL_RANGED, nCR);
            if(GetIsTalentValid(tUse))
            {
                // * BK: July 2002: Wrapped up harmful ranged into
                // * a function to make it easier to make global
                // * changes to the decision making process.
                if (genericAttemptHarmfulRanged(tUse, oTarget))
                {
                    return TRUE;
                }
            }
       }
    }
    //MyPrintString("TalentRangedEnemies Failed Exit");
    return FALSE;
}
// * Wrapper function so that I could add a variable to allow randomization
// * to the AI.
// * WARNING: This will make the AI cast spells badly if they have a bad
// * spell selection (i.e., only turn randomization on if you know what you are doing
// *
// * nCRMax only applies if bRandom is FALSE
// * oCreature is the creature checking to see if it has the talent
talent GetCreatureTalent(int nCategory, int nCRMax, int bRandom=FALSE, object oCreature = OBJECT_SELF)
{
    // * bRandom can be overridden by the variable X2_SPELL_RANDOM = 1
    if (!bRandom)
    {
        bRandom = GetLocalInt(OBJECT_SELF, "X2_SPELL_RANDOM");
        if(bRandom != TRUE)
        {
            bRandom = GetLevelByClass(CLASS_TYPE_SORCERER) || GetLevelByClass(CLASS_TYPE_BARD);//1.71: sorcerers and bards will cast always randomly, unless X2_SPELL_RANDOM == -1
        }
    }

    if (bRandom != TRUE)//1.71: X2_SPELL_RANDOM = -1 disables the random casting on sorcerers/bards
    {
        return GetCreatureTalentBest(nCategory, nCRMax, oCreature);
    }
    else
    {   // * randomize it
        return GetCreatureTalentRandom(nCategory, oCreature);
    }
}

/*
  ISSUE 1: The check in this function to use a random ability
  after failing to use best will fail in the following
  case.  The creature is unable to affect the target with the
  spell and has only 1 spell of that type.  This can
  be eliminated with a check in the else to the effect of :

  else if(!CompareLastSpellCast(GetIdFromTalent(tUse)))

  This check was not put in in version 1.0 due to time constraints.
  May cause an AI loop in some Mages with limited spell selection.
*/
int TalentSpellAttack(object oIntruder)
{
    //MyPrintString("Talent Spell Attack Enter");
    object oTarget = oIntruder;
    object oArea = GetArea(OBJECT_SELF);
    if(!GetIsObjectValid(oTarget) || GetArea(oTarget) != oArea || GetPlotFlag(OBJECT_SELF))
    {
        oTarget = GetLastHostileActor();
        //MyPrintString("Last Hostile Attacker: " + ObjectToString(oTarget));
        if(!GetIsObjectValid(oTarget) || GetIsDead(oTarget) || GetArea(oTarget) != oArea || GetPlotFlag(OBJECT_SELF))
        {
            oTarget = GetNearestSeenEnemy();
            //MyPrintString("Get Nearest Seen or Heard: " + ObjectToString(oTarget));
            if(!GetIsObjectValid(oTarget))
            {
                return FALSE;
            }
        }
    }
    //1.71: these three spells removed from talent routine via 2da due to their too specific usage, now they are handled manually here
    if(GetRacialType(oTarget) == RACIAL_TYPE_UNDEAD)
    {
        if(GetHasSpell(SPELL_UNDEATH_TO_DEATH) && !CompareLastSpellCast(SPELL_UNDEATH_TO_DEATH))
        {
            if(bkTalentFilterSpell(SPELL_UNDEATH_TO_DEATH,oTarget))
            {
                SetLastGenericSpellCast(SPELL_UNDEATH_TO_DEATH);
                return TRUE;
            }
        }
        else if(GetHasSpell(SPELL_CONTROL_UNDEAD) && !GetHasSpellEffect(SPELL_CONTROL_UNDEAD,oTarget) && !CompareLastSpellCast(SPELL_CONTROL_UNDEAD))
        {
            if(bkTalentFilterSpell(SPELL_CONTROL_UNDEAD,oTarget))
            {
                SetLastGenericSpellCast(SPELL_UNDEATH_TO_DEATH);
                return TRUE;
            }
        }
    }
    else if(GetHasSpell(SPELL_POWER_WORD_KILL) && !CompareLastSpellCast(SPELL_POWER_WORD_KILL))
    {
        int nLimit = GetLocalInt(GetModule(),"131_LIMIT_OVERRIDE");
        if(!nLimit) nLimit = GetLocalInt(OBJECT_SELF,"131_LIMIT_OVERRIDE");
        if(!nLimit) nLimit = 100;
        if(GetCurrentHitPoints(oTarget) <= nLimit)//1.72: if the 100hp limit is overriden, AI will count with it
        {
            if(bkTalentFilterSpell(SPELL_POWER_WORD_KILL,oTarget))
            {
                SetLastGenericSpellCast(SPELL_UNDEATH_TO_DEATH);
                return TRUE;
            }
        }
    }

    //Attack chosen target
    int bValid, nCR = GetCRMax();
    talent tUse = GetCreatureTalent(TALENT_CATEGORY_HARMFUL_AREAEFFECT_DISCRIMINANT, nCR);
    if (!GetIsTalentValid(tUse) || (GetTypeFromTalent(tUse) == TALENT_TYPE_SPELL && CompareLastSpellCast(GetIdFromTalent(tUse))))
    {
        //MyPrintString("Discriminant AOE not valid");
        //newdebug("Discriminant AOE not valid");
        // * November 2002
        // * if there are no allies near the target
        // * then feel free to grab an indiscriminant spell instead
        if (CheckFriendlyFireOnTarget(oIntruder) <= 1)
        {
            //newdebug("no friendly fire");
            tUse = GetCreatureTalent(TALENT_CATEGORY_HARMFUL_AREAEFFECT_INDISCRIMINANT, nCR);
        }
        //if (!GetIsTalentValid(tUse))
        //{
            //newdebug("SpellAttack: INDiscriminant AOE not valid");
        //}
    }

    if(GetIsTalentValid(tUse))
    {
        if(GetTypeFromTalent(tUse) == TALENT_TYPE_SPELL && !GetHasSpellEffect(GetIdFromTalent(tUse), oTarget) && !CompareLastSpellCast(GetIdFromTalent(tUse)))//1.71: if this spell was cast last round, choose other
        {
            //newdebug("Valid talent found AREA OF EFFECT DISCRIMINANT");
            //MyPrintString("Spell Attack Discriminate Chosen");
            bValid = TRUE;
        }

    }

    if(!bValid)
    {
        tUse = GetCreatureTalent(TALENT_CATEGORY_HARMFUL_RANGED, nCR);
        if(GetIsTalentValid(tUse))
        {     //  SpawnScriptDebugger();

            // * BK: July 2002: Wrapped up harmful ranged into
            // * a function to make it easier to make global
            // * changes to the decision making process.
            if (genericAttemptHarmfulRanged(tUse, oTarget))
            {
                //MyPrintString("Spell Attack Harmful Ranged Chosen");
                //bValid = FALSE; // * Keep bValid false because we have chosen
                                // * to actually cast the spell here.
                return TRUE;
            }
        }
    }

    if(!bValid)
    {
        tUse = GetCreatureTalent(TALENT_CATEGORY_HARMFUL_TOUCH, nCR);
        if(GetIsTalentValid(tUse))
        {
            if(GetTypeFromTalent(tUse) == TALENT_TYPE_SPELL && !GetHasSpellEffect(GetIdFromTalent(tUse), oTarget) && !CompareLastSpellCast(GetIdFromTalent(tUse)))
            {
                //MyPrintString("Spell Attack Harmful Ranged Chosen");
                bValid = TRUE;
            }
        }
    }

    if (bValid)
    {
        if(GetTypeFromTalent(tUse) == TALENT_TYPE_SPELL)
        {
            SetLastGenericSpellCast(GetIdFromTalent(tUse));
        }

        // DebugPrintTalentID(tUse);
        //MyPrintString("Talent Spell Attack Successful Exit");

        // Use a final filter to avoid problems
        if (bkTalentFilter(tUse, oTarget))
         return TRUE;
    }

    //MyPrintString("Talent Spell Attack Failed Exit");
    /* JULY 2003
       At this point grab a random spell attack to use, not just "best"
    */
    //SpawnScriptDebugger();
     tUse = GetCreatureTalentRandom(TALENT_CATEGORY_HARMFUL_AREAEFFECT_DISCRIMINANT);
     if (!GetIsTalentValid(tUse) || GetHasSpellEffect(GetIdFromTalent(tUse), oTarget) || !bkTalentFilter(tUse, oTarget, TRUE))
     {
         tUse = GetCreatureTalentRandom(TALENT_CATEGORY_HARMFUL_RANGED);
         //1.71: needless to check the same talent three times in a row
         if (!GetIsTalentValid(tUse) || GetHasSpellEffect(GetIdFromTalent(tUse), oTarget) || !bkTalentFilter(tUse, oTarget, TRUE))
         {
             tUse = GetCreatureTalentRandom(TALENT_CATEGORY_HARMFUL_AREAEFFECT_INDISCRIMINANT);
             if (!GetIsTalentValid(tUse) || GetHasSpellEffect(GetIdFromTalent(tUse), oTarget) || !bkTalentFilter(tUse, oTarget, TRUE))
             {
                 tUse = GetCreatureTalentRandom(TALENT_CATEGORY_HARMFUL_TOUCH);
             }
         }
     }

    // * if something was valid, attempt to use that something intelligently
    if (GetIsTalentValid(tUse))
    {
       //if (!GetHasSpellEffect(GetIdFromTalent(tUse), oTarget))//1.71: at this point it should't matter anymore
       {
         // * so far, so good
         // Use a final filter to avoid problems
         if (bkTalentFilter(tUse, oTarget))
          return TRUE;
       }
    }
    //1.71: these three spells removed from talent routine via 2da due to their too specific usage, now they are handled manually here
    else if(GetRacialType(oTarget) == RACIAL_TYPE_UNDEAD)
    {
        if(GetHasSpell(SPELL_UNDEATH_TO_DEATH))
        {
            if(bkTalentFilterSpell(SPELL_UNDEATH_TO_DEATH,oTarget))
            {
                SetLastGenericSpellCast(SPELL_UNDEATH_TO_DEATH);
                return TRUE;
            }
        }
        else if(GetHasSpell(SPELL_CONTROL_UNDEAD) && !GetHasSpellEffect(SPELL_CONTROL_UNDEAD,oTarget))
        {
            if(bkTalentFilterSpell(SPELL_CONTROL_UNDEAD,oTarget))
            {
                SetLastGenericSpellCast(SPELL_UNDEATH_TO_DEATH);
                return TRUE;
            }
        }
    }
    else if(GetHasSpell(SPELL_POWER_WORD_KILL))
    {
        int nLimit = GetLocalInt(GetModule(),"131_LIMIT_OVERRIDE");
        if(!nLimit) nLimit = GetLocalInt(OBJECT_SELF,"131_LIMIT_OVERRIDE");
        if(!nLimit) nLimit = 100;
        if(GetCurrentHitPoints(oTarget) <= nLimit)//1.72: if the 100hp limit is overriden, AI will count with it
        {
            if(bkTalentFilterSpell(SPELL_POWER_WORD_KILL,oTarget))
            {
                SetLastGenericSpellCast(SPELL_UNDEATH_TO_DEATH);
                return TRUE;
            }
        }
    }

    /* End July 11 Mods BK */
    return FALSE;
}


// SUMMON ALLIES
int TalentSummonAllies()
{
    //MyPrintString("TalentSummonAllies Enter");
    if(!GetIsObjectValid(GetAssociate(ASSOCIATE_TYPE_SUMMONED)))
    {
        talent tUse = GetCreatureTalent(TALENT_CATEGORY_BENEFICIAL_OBTAIN_ALLIES, GetCRMax());
        //1.72: high AI will be able to use strong summoning feats
        if(GetAILevel() >= AI_LEVEL_HIGH)
        {
            if(GetHasFeat(FEAT_EPIC_SPELL_DRAGON_KNIGHT) && !GetHasSpell(SPELL_EPIC_DRAGON_KNIGHT))//Epic Spell: Dragon Knight
            {
                tUse = TalentFeat(FEAT_EPIC_SPELL_DRAGON_KNIGHT);
            }
            else if(GetHasFeat(FEAT_EPIC_SPELL_MUMMY_DUST) && !GetHasSpell(SPELL_EPIC_MUMMY_DUST))//Epic Spell: Mummy Dust
            {
                tUse = TalentFeat(FEAT_EPIC_SPELL_MUMMY_DUST);
            }
            else if(GetHasFeat(FEAT_INFLICT_MODERATE_WOUNDS) && !GetHasSpell(610))//Summon Fiendish Servant
            {
                tUse = TalentFeat(FEAT_INFLICT_MODERATE_WOUNDS);//the constant has wrong name in fact its BG Summon Fied
            }
        }
        if(GetIsTalentValid(tUse))
        {
            location lSelf;
            object oTarget = FindSingleRangedTarget();
            if(GetIsObjectValid(oTarget))
            {
                vector vTarget = GetPosition(oTarget);
                vector vSource = GetPosition(OBJECT_SELF);
                vector vDirection = vTarget - vSource;
                float fDistance = VectorMagnitude(vDirection) / 2.0f;
                vector vPoint = VectorNormalize(vDirection) * fDistance + vSource;
                lSelf = Location(GetArea(OBJECT_SELF), vPoint, GetFacing(OBJECT_SELF));
                //lSelf = GetLocation(oTarget);
            }
            else
            {
                lSelf = GetLocation(OBJECT_SELF);
            }
            //This is for henchmen wizards, so they do no run off and get killed
            //summoning in allies.
            if(GetIsObjectValid(GetMaster()))
            {
                //MyPrintString("TalentSummonAllies Successful Exit");
                if(bkTalentFilterLoc(tUse,GetLocation(GetMaster())))
                    return TRUE;
            }
            else
            {
                //MyPrintString("TalentSummonAllies Successful Exit");
                if(bkTalentFilterLoc(tUse, lSelf))
                    return TRUE;
            }
        }
        //   else
            //MyPrintString("No valid Talent for summoning Allies with Difficulty " + IntToString(GetLocalInt(OBJECT_SELF,"NW_L_COMBATDIFF")));
    }
    //MyPrintString("TalentSummonAllies Failed Exit");
    return FALSE;
}

// HEAL SELF WITH POTIONS AND SPELLS
// * July 14 2003: If bForce=TRUE then force a heal
int TalentHealingSelf(int bForce = FALSE)
{
    // BK: Sep 2002
    // * Moved the racial type filter into here instead of having it
    // * out everyplace that this talent is called
    // * Will have to keep an eye out to see if this breaks anything
/*    if(GetRacialType(OBJECT_SELF) != RACIAL_TYPE_ABERRATION ||
       GetRacialType(OBJECT_SELF) != RACIAL_TYPE_BEAST ||
       GetRacialType(OBJECT_SELF) != RACIAL_TYPE_ELEMENTAL ||
       GetRacialType(OBJECT_SELF) != RACIAL_TYPE_VERMIN ||
       GetRacialType(OBJECT_SELF) != RACIAL_TYPE_MAGICAL_BEAST ||
       GetRacialType(OBJECT_SELF) != RACIAL_TYPE_UNDEAD ||
       GetRacialType(OBJECT_SELF) != RACIAL_TYPE_DRAGON    ||
//       GetRacialType(OBJECT_SELF) != RACIAL_TYPE_CONSTRUCT ||
       GetRacialType(OBJECT_SELF) != 29 || //oozes
       GetRacialType(OBJECT_SELF) != RACIAL_TYPE_ANIMAL) //
    {//1.70: whole condition is wrong, will be always true anyway   */
    //MyPrintString("TalentHealingSelf Enter");
    int nHP = GetCurrentHitPoints(OBJECT_SELF)*100/GetMaxHitPoints(OBJECT_SELF);

    if(nHP < 50 || (bForce && nHP < 100))//1.71: cancel force heal when there is nothing to heal
    {
        if(nHP < 30) bForce = TRUE;
        //1.72: high ai creatures will be able to use greater restoration
        if(bForce && GetAILevel() >= AI_LEVEL_HIGH && bkTalentFilterSpell(SPELL_GREATER_RESTORATION,OBJECT_SELF))
        {
            return TRUE;
        }
        if(GetRacialType(OBJECT_SELF) != RACIAL_TYPE_UNDEAD)
        {
            talent tUse = GetCreatureTalentBest(TALENT_CATEGORY_BENEFICIAL_HEALING_TOUCH, 20-(nHP/10+1)*2);
            if(GetIsTalentValid(tUse))
            {
                //MyPrintString("Talent\ Successful Exit");
                if(bkTalentFilter(tUse,OBJECT_SELF))
                    return TRUE;
            }
            if(bForce)
            {
                tUse = GetCreatureTalentRandom(TALENT_CATEGORY_BENEFICIAL_HEALING_TOUCH);
                if(GetIsTalentValid(tUse))
                {
                    //MyPrintString("Talent\ Successful Exit");
                    if(bkTalentFilter(tUse,OBJECT_SELF))
                        return TRUE;
                }
            }
            int nTalent;
            tUse = GetCreatureTalentRandom(TALENT_CATEGORY_BENEFICIAL_HEALING_POTION);
            while(GetIsTalentValid(tUse) && nTalent++ < 10)
            {
                if(GetTypeFromTalent(tUse) == TALENT_TYPE_SPELL)
                {
                    switch(GetIdFromTalent(tUse))
                    {
                    case SPELL_HEAL:
                    case SPELL_MASS_HEAL:
                    case SPELL_GREATER_RESTORATION://this will not happen in vanilla, GR is not healing spell by default, builder needs to change category to make this work
                        if(!bForce) break;
                    default:
                        //MyPrintString("TalentHealingSelf - Successful Exit");
                        ClearAllActions();
                        ActionUseTalentOnObject(tUse,OBJECT_SELF);//1.72: no filter to allow use in polymorph
                        return TRUE;
                    break;
                    }
                }
                tUse = GetCreatureTalentRandom(TALENT_CATEGORY_BENEFICIAL_HEALING_POTION);
            }
        }
        else//we are undead, now be smart and use harming talents instead
        {
            if(bForce && bkTalentFilterSpell(759,OBJECT_SELF))//will reserves fullheals for later
            {
                //MyPrintString("TalentHealingSelf - undead - Successful Exit");
                return TRUE;
            }

            int nTalent;
            talent tUse = GetCreatureTalentRandom(TALENT_CATEGORY_HARMFUL_TOUCH);
            while(GetIsTalentValid(tUse) && nTalent++ < 10)
            {
                if(GetTypeFromTalent(tUse) == TALENT_TYPE_SPELL)
                {
                    switch(GetIdFromTalent(tUse))
                    {
                    case SPELL_HARM:
                        if(!bForce) break;//will reserves fullheals for later
                    case SPELL_INFLICT_CRITICAL_WOUNDS:
                    case SPELL_INFLICT_SERIOUS_WOUNDS:
                    case SPELL_INFLICT_MODERATE_WOUNDS:
                    case SPELL_INFLICT_LIGHT_WOUNDS:
                    case SPELL_INFLICT_MINOR_WOUNDS:
                        //MyPrintString("TalentHealingSelf - undead - Successful Exit");
                        if(bkTalentFilter(tUse,OBJECT_SELF))
                            return TRUE;
                    break;
                    }
                }
                tUse = GetCreatureTalentRandom(TALENT_CATEGORY_HARMFUL_TOUCH);
            }
            tUse = GetCreatureTalentBest(TALENT_CATEGORY_HARMFUL_TOUCH,0);
            while(GetIsTalentValid(tUse) && nTalent++ < 20)
            {
                if(GetTypeFromTalent(tUse) == TALENT_TYPE_SPELL)
                {
                    switch(GetIdFromTalent(tUse))
                    {
                    case SPELL_HARM:
                        if(!bForce) break;//will reserves fullheals for later
                    case SPELL_INFLICT_CRITICAL_WOUNDS:
                    case SPELL_CIRCLE_OF_DOOM:
                    case SPELL_INFLICT_SERIOUS_WOUNDS:
                    case SPELL_INFLICT_MODERATE_WOUNDS:
                    case SPELL_INFLICT_LIGHT_WOUNDS:
                    case SPELL_INFLICT_MINOR_WOUNDS:
                        //MyPrintString("TalentHealingSelf - undead - Successful Exit");
                        ClearAllActions();
                        ActionUseTalentOnObject(tUse, OBJECT_SELF);
                    return TRUE;
                    }
                }
                else if(GetTypeFromTalent(tUse) == TALENT_TYPE_FEAT)
                {
                    switch(GetIdFromTalent(tUse))
                    {
                    case FEAT_INFLICT_CRITICAL_WOUNDS:
                    case FEAT_INFLICT_SERIOUS_WOUNDS:
                        //MyPrintString("TalentHealingSelf - undead - Successful Exit");
                        ClearAllActions();
                        ActionUseTalentOnObject(tUse, OBJECT_SELF);
                    return TRUE;
                    }
                }
                tUse = GetCreatureTalentBest(TALENT_CATEGORY_HARMFUL_TOUCH,0);
            }
        }
    }
    //MyPrintString("TalentHealingSelf Failed Exit");
    return FALSE;
}

// HEAL ALL ALLIES
// BK: Added an optional parameter for object.
int TalentHeal(int nForce = FALSE, object oTarget = OBJECT_SELF)
{
    //MyPrintString("TalentHeal Enter");

    int nHP = GetCurrentHitPoints(oTarget)*100/GetMaxHitPoints(oTarget);

    if(nHP < 50 || (nForce && nHP < 100))//1.71: cancel force heal when there is nothing to heal
    {
        int bForce = nForce || nHP < 30;
        //1.72: high ai creatures will be able to use greater restoration
        if(bForce && GetAILevel() >= AI_LEVEL_HIGH && bkTalentFilterSpell(SPELL_GREATER_RESTORATION,oTarget))
        {
            return TRUE;
        }
        if(GetRacialType(oTarget) != RACIAL_TYPE_UNDEAD)
        {
            talent tUse = GetCreatureTalentBest(TALENT_CATEGORY_BENEFICIAL_HEALING_TOUCH, 20-(nHP/10+1)*2);
            if(GetIsTalentValid(tUse))
            {
                //MyPrintString("Talent\ Successful Exit");
                if(bkTalentFilter(tUse,oTarget))
                    return TRUE;
            }
            if(bForce)
            {
                tUse = GetCreatureTalentRandom(TALENT_CATEGORY_BENEFICIAL_HEALING_TOUCH);
                if(GetIsTalentValid(tUse))
                {
                    //MyPrintString("Talent\ Successful Exit");
                    if(bkTalentFilter(tUse,oTarget))
                        return TRUE;
                }
            }
        }
        else//target is undead, now be smart and use harming talents instead
        {
            if(bForce && bkTalentFilterSpell(759,oTarget))//will reserves fullheals for later
            {
                //MyPrintString("TalentHealingSelf - undead - Successful Exit");
                return TRUE;
            }

            int nTalent;
            talent tUse = GetCreatureTalentRandom(TALENT_CATEGORY_HARMFUL_TOUCH);
            while(GetIsTalentValid(tUse) && nTalent++ < 10)
            {
                if(GetTypeFromTalent(tUse) == TALENT_TYPE_SPELL)
                {
                    switch(GetIdFromTalent(tUse))
                    {
                    case SPELL_HARM:
                        if(!bForce) break;//will reserves fullheals for later
                    case SPELL_INFLICT_CRITICAL_WOUNDS:
                    case SPELL_INFLICT_SERIOUS_WOUNDS:
                    case SPELL_INFLICT_MODERATE_WOUNDS:
                    case SPELL_INFLICT_LIGHT_WOUNDS:
                    case SPELL_INFLICT_MINOR_WOUNDS:
                        //MyPrintString("TalentHealingSelf - undead - Successful Exit");
                        if(bkTalentFilter(tUse,oTarget))
                            return TRUE;
                    break;
                    }
                }
                tUse = GetCreatureTalentRandom(TALENT_CATEGORY_HARMFUL_TOUCH);
            }
            tUse = GetCreatureTalentBest(TALENT_CATEGORY_HARMFUL_TOUCH,0);
            while(GetIsTalentValid(tUse) && nTalent++ < 20)
            {
                if(GetTypeFromTalent(tUse) == TALENT_TYPE_SPELL)
                {
                    switch(GetIdFromTalent(tUse))
                    {
                    case SPELL_HARM:
                        if(!bForce) break;//will reserves fullheals for later
                    case SPELL_INFLICT_CRITICAL_WOUNDS:
                    case SPELL_CIRCLE_OF_DOOM:
                    case SPELL_INFLICT_SERIOUS_WOUNDS:
                    case SPELL_INFLICT_MODERATE_WOUNDS:
                    case SPELL_INFLICT_LIGHT_WOUNDS:
                    case SPELL_INFLICT_MINOR_WOUNDS:
                        //MyPrintString("TalentHealingSelf - undead - Successful Exit");
                        ClearAllActions();
                        ActionUseTalentOnObject(tUse, oTarget);
                    return TRUE;
                    }
                }
                else if(GetTypeFromTalent(tUse) == TALENT_TYPE_FEAT)
                {
                    switch(GetIdFromTalent(tUse))
                    {
                    case FEAT_INFLICT_CRITICAL_WOUNDS:
                    case FEAT_INFLICT_SERIOUS_WOUNDS:
                    case FEAT_INFLICT_MODERATE_WOUNDS:
                    case FEAT_INFLICT_LIGHT_WOUNDS:
                        //MyPrintString("TalentHealingSelf - undead - Successful Exit");
                        ClearAllActions();
                        ActionUseTalentOnObject(tUse, oTarget);
                    return TRUE;
                    }
                }
                tUse = GetCreatureTalentBest(TALENT_CATEGORY_HARMFUL_TOUCH,0);
            }
        }
    }
    // * change target
    // * find nearest friend to heal.
    object newTarget = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_FRIEND, OBJECT_SELF, 1, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN, CREATURE_TYPE_IS_ALIVE, TRUE);
    int nCurrent, nBase, i = 1;//1.72: fix, looked for 1st twice
    while(GetIsObjectValid(newTarget))
    {
        if(newTarget != oTarget)
        {
            nHP = GetCurrentHitPoints(newTarget)*100/GetMaxHitPoints(newTarget);
            if(nHP < 50 || (nForce && nHP < 100))//1.71: cancel force heal when there is nothing to heal
            {
                //1.72: high ai creatures will be able to use greater restoration
                if(nForce && GetAILevel() >= AI_LEVEL_HIGH && bkTalentFilterSpell(SPELL_GREATER_RESTORATION,newTarget))
                {
                    return TRUE;
                }
                talent tUse;
                if(GetRacialType(newTarget) != RACIAL_TYPE_UNDEAD)
                {
                    //1.72: high AI non undead creatures can use aoe healing talents
                    if(GetAILevel() >= AI_LEVEL_HIGH && GetRacialType(OBJECT_SELF) != RACIAL_TYPE_UNDEAD)
                    {
                        tUse = GetCreatureTalentBest(TALENT_CATEGORY_BENEFICIAL_HEALING_AREAEFFECT,20-(nHP/10+1)*2);
                        if(GetIsTalentValid(tUse))
                        {
                            //MyPrintString("Talent\ Successful Exit");
                            if(bkTalentFilter(tUse,newTarget))
                                return TRUE;
                        }
                        else if(nForce)
                        {
                            tUse = GetCreatureTalentRandom(TALENT_CATEGORY_BENEFICIAL_HEALING_AREAEFFECT);
                            if(GetIsTalentValid(tUse))
                            {
                                //MyPrintString("Talent\ Successful Exit");
                                if(bkTalentFilter(tUse,newTarget))
                                    return TRUE;
                            }
                        }
                    }
                    tUse = GetCreatureTalentBest(TALENT_CATEGORY_BENEFICIAL_HEALING_TOUCH,20-(nHP/10+1)*2);
                    if(GetIsTalentValid(tUse))
                    {
                        //MyPrintString("Talent\ Successful Exit");
                        if(bkTalentFilter(tUse,newTarget))
                            return TRUE;
                    }
                    else if(nForce)
                    {
                        tUse = GetCreatureTalentRandom(TALENT_CATEGORY_BENEFICIAL_HEALING_TOUCH);
                        if(GetIsTalentValid(tUse))
                        {
                            //MyPrintString("Talent\ Successful Exit");
                            if(bkTalentFilter(tUse,newTarget))
                                return TRUE;
                        }
                    }
                }
                else//1.72: enable to heal ally undeads with harming spells
                {
                    int nTalent;
                    //1.72: high AI undead creatures can use aoe harming talents
                    if(GetAILevel() >= AI_LEVEL_HIGH && GetRacialType(OBJECT_SELF) == RACIAL_TYPE_UNDEAD)
                    {
                        tUse = GetCreatureTalentRandom(TALENT_CATEGORY_HARMFUL_AREAEFFECT_DISCRIMINANT);
                        while(GetIsTalentValid(tUse) && nTalent++ < 10)
                        {
                            if(GetTypeFromTalent(tUse) == TALENT_TYPE_SPELL)
                            {
                                switch(GetIdFromTalent(tUse))
                                {
                                case SPELL_NEGATIVE_ENERGY_BURST:
                                case SPELL_CIRCLE_OF_DOOM:
                                    //MyPrintString("TalentHealingSelf - undead - Successful Exit");
                                    if(bkTalentFilter(tUse,newTarget))
                                        return TRUE;
                                break;
                                }
                            }
                            tUse = GetCreatureTalentRandom(TALENT_CATEGORY_HARMFUL_AREAEFFECT_DISCRIMINANT);
                        }
                        nTalent = 0;
                    }
                    tUse = GetCreatureTalentRandom(TALENT_CATEGORY_HARMFUL_TOUCH);
                    while(GetIsTalentValid(tUse) && nTalent++ < 10)
                    {
                        if(GetTypeFromTalent(tUse) == TALENT_TYPE_SPELL)
                        {
                            switch(GetIdFromTalent(tUse))
                            {
                            case SPELL_HARM:
                                if(!nForce) break;//will reserves fullheals for other targets
                            case SPELL_INFLICT_CRITICAL_WOUNDS:
                            case SPELL_INFLICT_SERIOUS_WOUNDS:
                            case SPELL_INFLICT_MODERATE_WOUNDS:
                            case SPELL_INFLICT_LIGHT_WOUNDS:
                            case SPELL_INFLICT_MINOR_WOUNDS:
                                //MyPrintString("TalentHealingSelf - undead - Successful Exit");
                                if(bkTalentFilter(tUse,newTarget))
                                    return TRUE;
                            break;
                            }
                        }
                        tUse = GetCreatureTalentRandom(TALENT_CATEGORY_HARMFUL_TOUCH);
                    }
                }
            }
        }
        newTarget = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_FRIEND, OBJECT_SELF, ++i, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN, CREATURE_TYPE_IS_ALIVE, TRUE);
    }

    //MyPrintString("TalentHeal Failed Exit");
    return FALSE;
}

// MELEE ATTACK OTHERS
/*
    ISSUE 1: Talent Melee Attack should set the Last Spell Used to 0 so that melee casters can use
    a single special ability.
*/
int WhirlwindGetNumberOfMeleeAttackers(float fDist=5.0)
{
    object oOne = GetNearestEnemy(OBJECT_SELF, 1);

    if (GetIsObjectValid(oOne))
    {
        object oTwo = GetNearestEnemy(OBJECT_SELF, 2);
        if (GetDistanceToObject(oOne) <= fDist && GetIsObjectValid(oTwo))
        {
            if (GetDistanceToObject(oTwo) <= fDist)
            {
                // * DO NOT WHIRLWIND if any of the targets are "large" or bigger
                // * it seldom works against such large opponents.
                // * Though its okay to use Improved Whirlwind against these targets
                // * October 13 - Brent
                if (GetHasFeat(FEAT_IMPROVED_WHIRLWIND))
                {
                    return TRUE;
                }
                else if (GetCreatureSize(oOne) < CREATURE_SIZE_LARGE && GetCreatureSize(oTwo) < CREATURE_SIZE_LARGE)
                {
                    return TRUE;
                }
                return FALSE;
            }
        }
    }
    return FALSE;
}


// * Returns true if the creature's variable
// * set on it rolled against a d100
// * says it is okay to whirlwind.
// * Added this because it got silly to see creatures
// * constantly whirlwinded
int GetOKToWhirl(object oCreature)
{
    int nWhirl = GetLocalInt(oCreature, "X2_WHIRLPERCENT");

    if (!nWhirl || nWhirl > 99)
    {
        return TRUE; // 0 (unset) or 100 is 100%
    }
    return Random(100) < nWhirl;
}


int TalentMeleeAttack(object oIntruder = OBJECT_INVALID)
{
    //MyPrintString("TalentMeleeAttack Enter, Intruder: " + ObjectToString(oIntruder));
    object oTarget = oIntruder;
    object oArea = GetArea(OBJECT_SELF);
    // not clear to me why we check this here...
    if(!GetIsObjectValid(oTarget) || GetArea(oTarget) != oArea || GetAssociateState(NW_ASC_MODE_DYING, oTarget) /* || GetPlotFlag(OBJECT_SELF) == TRUE)*/)
    {                                                                                                           // not clear to me why we check this here...
        oTarget = GetAttemptedAttackTarget();
        //MyPrintString("Attempted Attack Target: " + ObjectToString(oTarget));
        if(!GetIsObjectValid(oTarget) || GetIsDead(oTarget) || (!GetObjectSeen(oTarget) && !GetObjectHeard(oTarget)) || GetArea(oTarget) != oArea || GetPlotFlag(OBJECT_SELF))
        {                                                                                                                                           //hmm why it checks plot flag?
            oTarget = GetLastHostileActor();
            //MyPrintString("Last Attacker: " + ObjectToString(oTarget));
            if(!GetIsObjectValid(oTarget) || GetIsDead(oTarget) || GetArea(oTarget) != oArea || GetPlotFlag(OBJECT_SELF))
            {                                                                                   //here too
                oTarget = GetNearestPerceivedEnemy();
                //MyPrintString("Get Nearest Perceived: "                              + ObjectToString(oTarget));
                if(!GetIsObjectValid(oTarget))
                {
                    //MyPrintString("TALENT MELEE ATTACK FAILURE EXIT"                                  + " - NO TARGET FOUND");
                    return FALSE;
                }
            }
        }
    }
    //MyPrintString("Selected Target: " + ObjectToString(oTarget));

    // If the difference between the attacker's AC and our
    // attack capabilities is greater than 10, we just use
    // a straightforward attack; otherwise, we try our best
    // melee talent.
    int nDiff = GetAC(oTarget) - GetHitDice(OBJECT_SELF);

    //fAttack = (IntToFloat(nAttack) * 0.75) + IntToFloat(GetAbilityModifier(ABILITY_STRENGTH));

    //fAttack = IntToFloat(nAttack) + GetAbilityModifier(ABILITY_STRENGTH);

    //MyPrintString("nDiff = " + IntToString(nDiff));

    // * only the playable races have whirlwind attack
    int bPlayableRace = GetIsPlayableRacialType(OBJECT_SELF) || GetTag(OBJECT_SELF) == "x2_hen_valen";

    int bNumberofAttackers = WhirlwindGetNumberOfMeleeAttackers(WHIRL_DISTANCE);
    if (GetHasFeat(FEAT_WHIRLWIND_ATTACK) &&  bPlayableRace &&  bNumberofAttackers && GetOKToWhirl(OBJECT_SELF))
    {   // * Attempt to Use Whirlwind Attack
        ClearActions(CLEAR_X0_I0_TALENT_MeleeAttack1);
        ActionUseFeat(FEAT_WHIRLWIND_ATTACK, OBJECT_SELF);
        return TRUE;
    }
    else if (GetHasFeat(FEAT_EXPERTISE) && nDiff < 12)
    {   // * Try using expertise
        ClearActions(CLEAR_X0_I0_TALENT_MeleeAttack1);
        SetActionMode(OBJECT_SELF, ACTION_MODE_EXPERTISE, TRUE);
        WrapperActionAttack(oTarget);
        return TRUE;
    }
    else if (GetHasFeat(FEAT_IMPROVED_EXPERTISE) && nDiff < 15)
    {   // * Try using expertise
        ClearActions(CLEAR_X0_I0_TALENT_MeleeAttack1);
        SetActionMode(OBJECT_SELF, ACTION_MODE_IMPROVED_EXPERTISE, TRUE);
        WrapperActionAttack(oTarget);
        return TRUE;
    }

    //1.72: 10% to use taunt skill if challenging high ac target is withing 3.5m
    if(nDiff >= 15 && !GetLocalInt(OBJECT_SELF,"TauntUsed") && GetSkillRank(SKILL_TAUNT,OBJECT_SELF,TRUE) > 0 && GetDistanceToObject(oTarget) <= 3.5 && GetHitDice(oTarget) > GetHitDice(OBJECT_SELF)-2 && GetAbilityScore(oTarget,ABILITY_INTELLIGENCE) > 3)
    {
        //make sure the taunt will have a 10% chance per round not per AI call as those can be extremely frequent
        SetLocalInt(OBJECT_SELF,"TauntUsed",1);
        DelayCommand(6.0,SetLocalInt(OBJECT_SELF,"TauntUsed",0));
        //only use it if there is chance to success
        if(d10() == 1 && GetSkillRank(SKILL_TAUNT)+5+d4(2) > GetSkillRank(SKILL_CONCENTRATION,oTarget))
        {
            ClearActions(CLEAR_X0_I0_TALENT_MeleeAttack1);
            ActionUseSkill(SKILL_TAUNT, oTarget);
            return TRUE;
        }
    }

    talent tUse = GetCreatureTalent(TALENT_CATEGORY_HARMFUL_MELEE, GetCRMax());

    switch(GetIdFromTalent(tUse))
    {
    case FEAT_SMITE_EVIL:
    case FEAT_SMITE_GOOD:
    case FEAT_STUNNING_FIST:
        nDiff = 0;//1.71: these three talents should be used no matter of target's AC
    break;
    }
    if(nDiff < 10)
    {
        ClearActions(CLEAR_X0_I0_TALENT_MeleeAttack1);
        //MyPrintString("Melee Talent Valid = "+ IntToString(GetIsTalentValid(tUse)));
        //MyPrintString("Feat ID = " + IntToString(GetIdFromTalent(tUse)));

        if(GetIsTalentValid(tUse) && VerifyDisarm(tUse, oTarget) && VerifyCombatMeleeTalent(tUse, oTarget))
        {
            // * this function will call the BK function
            EquipAppropriateWeapons(oTarget);
            //MyPrintString("TalentMeleeAttack: Talent Use Successful");
            // February 6 2003: Did not have a clear all actions before it
            ActionUseTalentOnObject(tUse, oTarget);
            return TRUE;
        }
        else
        {
            //MyPrintString("TalentMeleeAttack Successful Exit");
            WrapperActionAttack(oTarget);
            return TRUE;
        }
    }
    else
    {
        //MyPrintString("TalentMeleeAttack Successful Exit");
        ClearActions(CLEAR_X0_I0_TALENT_MeleeAttack2);
        // * this function will call the BK function
        //EquipAppropriateWeapons(oTarget); //1.71: this does wrapperactionattack already
        WrapperActionAttack(oTarget);
        return TRUE;
    }

    //MyPrintString("TALENT MELEE ATTACK FAILURE EXIT - THIS IS VERY BAD");
    return FALSE;
}

// SNEAK ATTACK OTHERS
int TalentSneakAttack()
{
     //MyPrintString("TalentSneakAttack Enter");
     if(GetHasFeat(FEAT_SNEAK_ATTACK) || (GetHasFeat(FEAT_PRESTIGE_DEATH_ATTACK_1) && GetLevelByClass(CLASS_TYPE_ASSASSIN)) || (GetHasFeat(FEAT_BLACKGUARD_SNEAK_ATTACK_1D6) && GetLevelByClass(CLASS_TYPE_BLACKGUARD)))
     {//1.71: death attack and BG's sneak also qualify, but only if the creature has class with this feature!
         int th = 2;
         object oFriend = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_FRIEND, OBJECT_SELF, 1, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN, CREATURE_TYPE_IS_ALIVE, TRUE);
         while(GetIsObjectValid(oFriend))
         {
             object oTarget = GetLastHostileActor(oFriend);                                                           //1.72: do not attack friends and only attack seen targets
             if(GetIsObjectValid(oTarget) && !GetIsDead(oTarget) && !GetAssociateState(NW_ASC_MODE_DYING, oTarget) && !GetIsFriend(oTarget) && GetObjectSeen(oTarget))
             {                                      //1.71: high ai will not try to sneak immunes
                 if(GetAILevel() < AI_LEVEL_HIGH || (!GetIsImmune(oTarget,IMMUNITY_TYPE_SNEAK_ATTACK,OBJECT_SELF) && !GetIsImmune(oTarget,IMMUNITY_TYPE_CRITICAL_HIT,OBJECT_SELF)))
                 {
                     //MyPrintString("TalentSneakAttack Successful Exit");
                     TalentMeleeAttack(oTarget);
                     return TRUE;
                 }
             }
             //1.72: support for bigger parties
             oFriend = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_FRIEND, OBJECT_SELF, th++, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN, CREATURE_TYPE_IS_ALIVE, TRUE);
         }
     }
     //MyPrintString("TalentSneakAttack Failed Exit");
     return FALSE;
}

// FLEE COMBAT AND HOSTILES
int TalentFlee(object oIntruder = OBJECT_INVALID)
{
    //MyPrintString("TalentFlee Enter");
    object oTarget = oIntruder;
    if(!GetIsObjectValid(oIntruder))
    {
        oTarget = GetLastHostileActor();
        if(!GetIsObjectValid(oTarget) || GetIsDead(oTarget))
        {
            oTarget = GetNearestSeenEnemy();
            //float fDist = GetDistanceBetween(OBJECT_SELF, oTarget);
            if(!GetIsObjectValid(oTarget))
            {
                //MyPrintString("TalentFlee Failed Exit");
                return FALSE;
            }
        }
    }
    //MyPrintString("TalentFlee Successful Exit");
    ClearActions(CLEAR_X0_I0_TALENT_TalentFlee);
    //Look at this to remove the delay
    ActionMoveAwayFromObject(oTarget, TRUE, 10.0);
    DelayCommand(4.0, ClearActions(CLEAR_X0_I0_TALENT_TalentFlee2));
    return TRUE;
}

// TURN UNDEAD
int TalentUseTurning()
{
    //MyPrintString("TalentUseTurning Enter");
    if(GetHasFeat(FEAT_TURN_UNDEAD))
    {
        object oUndead = GetNearestPerceivedEnemy();
        int nPaladinLevel = GetLevelByClass(CLASS_TYPE_PALADIN)-2;
        int nBlackguardLevel = GetLevelByClass(CLASS_TYPE_BLACKGUARD)-2;
        int nTurnLevel = GetLevelByClass(CLASS_TYPE_CLERIC);

        if(nPaladinLevel > 0 && nBlackguardLevel > 0)//has both pally and BG, so add highest
        {
            nTurnLevel+= nPaladinLevel > nBlackguardLevel ? nPaladinLevel : nBlackguardLevel;
        }
        else if(nPaladinLevel+nBlackguardLevel > 0)//has either pally or bg
        {
            nTurnLevel+= nPaladinLevel > 0 ? nPaladinLevel : nBlackguardLevel;
        }

        if(GetHasEffect(EFFECT_TYPE_TURNED, oUndead) || nTurnLevel <= GetHitDice(oUndead))
        {//1.70: not HD but turning level check
            return FALSE;
        }
        int nCount = GetRacialTypeCount(RACIAL_TYPE_UNDEAD);

        if(GetHasFeat(FEAT_AIR_DOMAIN_POWER) || GetHasFeat(FEAT_EARTH_DOMAIN_POWER) || GetHasFeat(FEAT_FIRE_DOMAIN_POWER) || GetHasFeat(FEAT_WATER_DOMAIN_POWER))
            nCount += GetRacialTypeCount(RACIAL_TYPE_ELEMENTAL);
                                               //1.70: animal companion does not qualify for turning vermins anymore
        if(GetHasFeat(FEAT_PLANT_DOMAIN_POWER) /*|| GetHasFeat(FEAT_ANIMAL_COMPANION)*/)
            nCount += GetRacialTypeCount(RACIAL_TYPE_VERMIN);

        if(GetHasFeat(FEAT_GOOD_DOMAIN_POWER) || GetHasFeat(FEAT_EVIL_DOMAIN_POWER) || GetHasFeat(854))
            nCount += GetRacialTypeCount(RACIAL_TYPE_OUTSIDER);                      // planar turning

        if(GetHasFeat(FEAT_DESTRUCTION_DOMAIN_POWER))
            nCount += GetRacialTypeCount(RACIAL_TYPE_CONSTRUCT);

        if(nCount > 0)
        {
            //MyPrintString("TalentUseTurning Successful Exit");
            ClearActions(CLEAR_X0_I0_TALENT_UseTurning);
            //ActionCastSpellAtObject(SPELLABILITY_TURN_UNDEAD, OBJECT_SELF);
            ActionUseFeat(FEAT_TURN_UNDEAD, OBJECT_SELF);
            return TRUE;
        }
    }
    //MyPrintString("TalentUseTurning Failed Exit");
    return FALSE;
}

// ACTIVATE AURAS
int TalentPersistentAbilities()
{
    //MyPrintString("TalentPersistentAbilities Enter");
    talent tUse = GetCreatureTalent(TALENT_CATEGORY_PERSISTENT_AREA_OF_EFFECT, GetCRMax());
    if(GetIsTalentValid(tUse) && (GetTypeFromTalent(tUse) == TALENT_TYPE_SPELL && !GetHasSpellEffect(GetIdFromTalent(tUse))) ||
    (GetTypeFromTalent(tUse) == TALENT_TYPE_FEAT && !GetHasFeatEffect(GetIdFromTalent(tUse))))
    {
        ClearAllActions();
        if(GetTypeFromTalent(tUse) == TALENT_TYPE_SPELL && (GetGameDifficulty() == GAME_DIFFICULTY_DIFFICULT || GetAILevel() >= AI_LEVEL_HIGH))
        {
            ActionCastSpellAtObject(GetIdFromTalent(tUse),OBJECT_SELF,METAMAGIC_ANY,FALSE,0,PROJECTILE_PATH_TYPE_DEFAULT,TRUE);
            //MyPrintString("TalentPersistentAbilities Successful Exit");
            return TRUE;
        }
        else
        {
            ActionUseTalentOnObject(tUse, OBJECT_SELF);
            //MyPrintString("TalentPersistentAbilities Successful Exit");
            return TRUE;
        }
    }
    //MyPrintString("TalentPersistentAbilities Failed Exit");
    return FALSE;
}

// FAST BUFF SELF
// * Dec 19 2002: Added the instant parameter so this could be used for 'legal' spellcasting as well
int TalentAdvancedBuff(float fDistance, int bInstant = TRUE)
{
    //MyPrintString("TalentAdvancedBuff Enter");
    //object oPC = GetNearestCreature(CREATURE_TYPE_PLAYER_CHAR, PLAYER_CHAR_IS_PC, OBJECT_SELF, 1, CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY);
    //if(GetIsObjectValid(oPC))
    //{
        //if(GetDistanceToObject(oPC) <= fDistance)
        //{
            //if(!GetIsFighting(OBJECT_SELF))
            //{
                //ClearActions(CLEAR_X0_I0_TALENT_AdvancedBuff);
                ClearAllActions(TRUE);

                // General Protections and misc buffs
                BuffIfNotBuffed(SPELL_NEGATIVE_ENERGY_PROTECTION, bInstant);
                BuffIfNotBuffed(SPELL_DEATH_WARD, bInstant);
                BuffIfNotBuffed(SPELL_DARKVISION, bInstant);
                BuffIfNotBuffed(SPELL_DEATH_WARD, bInstant);
                BuffIfNotBuffed(SPELL_TRUE_SEEING, bInstant);
                BuffIfNotBuffed(SPELL_FREEDOM_OF_MOVEMENT, bInstant);
                BuffIfNotBuffed(SPELL_PROTECTION_FROM_SPELLS, bInstant);
                BuffIfNotBuffed(SPELL_SPELL_RESISTANCE, bInstant);
                BuffIfNotBuffed(SPELL_RESISTANCE, bInstant);
                BuffIfNotBuffed(SPELL_VIRTUE, bInstant);
                BuffIfNotBuffed(SPELL_CLAIRAUDIENCE_AND_CLAIRVOYANCE, bInstant);

                // Cleric buffs
                BuffIfNotBuffed(SPELL_BLESS, bInstant);
                BuffIfNotBuffed(SPELL_PRAYER, bInstant);
                BuffIfNotBuffed(SPELL_AID, bInstant);
                BuffIfNotBuffed(SPELL_DIVINE_POWER, bInstant);
                BuffIfNotBuffed(SPELL_DIVINE_FAVOR, bInstant);

                // Ranger/Druid buffs
                BuffIfNotBuffed(SPELL_CAMOFLAGE, bInstant);
                BuffIfNotBuffed(SPELL_MASS_CAMOFLAGE, bInstant);
                BuffIfNotBuffed(SPELL_ONE_WITH_THE_LAND, bInstant);

                // Weapon Buffs
                BuffIfNotBuffed(SPELL_DARKFIRE, bInstant);
                BuffIfNotBuffed(SPELL_MAGIC_VESTMENT, bInstant);
                BuffIfNotBuffed(SPELL_MAGIC_WEAPON, bInstant);
                BuffIfNotBuffed(SPELL_GREATER_MAGIC_WEAPON, bInstant);
                BuffIfNotBuffed(SPELL_FLAME_WEAPON, bInstant);
                BuffIfNotBuffed(SPELL_KEEN_EDGE, bInstant);
                BuffIfNotBuffed(SPELL_BLADE_THIRST, bInstant);
                BuffIfNotBuffed(SPELL_BLACKSTAFF, bInstant);
                BuffIfNotBuffed(SPELL_BLESS_WEAPON, bInstant);
                BuffIfNotBuffed(SPELL_DEAFENING_CLANG, bInstant);
                BuffIfNotBuffed(SPELL_HOLY_SWORD, bInstant);

                // Armor buffs
                BuffIfNotBuffed(SPELL_MAGE_ARMOR, bInstant);
                BuffIfNotBuffed(SPELL_SHIELD, bInstant);
                BuffIfNotBuffed(SPELL_SHIELD_OF_FAITH, bInstant);
                BuffIfNotBuffed(SPELL_ENTROPIC_SHIELD, bInstant);
                BuffIfNotBuffed(SPELL_BARKSKIN, bInstant);

                // Stat buffs
                BuffIfNotBuffed(SPELL_AURA_OF_VITALITY, bInstant);
                BuffIfNotBuffed(SPELL_BULLS_STRENGTH, bInstant);
                BuffIfNotBuffed(SPELL_OWLS_WISDOM, bInstant);
                BuffIfNotBuffed(SPELL_OWLS_INSIGHT, bInstant);
                BuffIfNotBuffed(SPELL_FOXS_CUNNING, bInstant);
                BuffIfNotBuffed(SPELL_ENDURANCE, bInstant);
                BuffIfNotBuffed(SPELL_CATS_GRACE, bInstant);


                // Alignment Protections
                int nAlignment = GetAlignmentGoodEvil(OBJECT_SELF);
                if (nAlignment == ALIGNMENT_EVIL)
                {
                    BuffIfNotBuffed(SPELL_PROTECTION_FROM_GOOD, bInstant);
                    BuffIfNotBuffed(SPELL_MAGIC_CIRCLE_AGAINST_GOOD, bInstant);
                    BuffIfNotBuffed(SPELL_UNHOLY_AURA, bInstant);
                }
                else if (nAlignment == ALIGNMENT_GOOD || nAlignment == ALIGNMENT_NEUTRAL)
                {
                    BuffIfNotBuffed(SPELL_PROTECTION_FROM_EVIL, bInstant);
                    BuffIfNotBuffed(SPELL_MAGIC_CIRCLE_AGAINST_EVIL, bInstant);
                    BuffIfNotBuffed(SPELL_HOLY_AURA, bInstant);
                }


                if(GetRacialType(OBJECT_SELF) == RACIAL_TYPE_UNDEAD && GetHasSpell(SPELL_STONE_BONES) && !GetHasSpellEffect(SPELL_STONE_BONES))
                {
                    ActionCastSpellAtObject(SPELL_STONE_BONES, OBJECT_SELF, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, bInstant);
                }

                //Evasion Protections
                if(GetHasSpell(SPELL_IMPROVED_INVISIBILITY) && !GetHasSpellEffect(SPELL_IMPROVED_INVISIBILITY))
                {
                    ActionCastSpellAtObject(SPELL_IMPROVED_INVISIBILITY, OBJECT_SELF, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, bInstant);
                }
                else if(GetHasSpell(SPELL_DISPLACEMENT)&& !GetHasSpellEffect(SPELL_DISPLACEMENT))
                {
                    ActionCastSpellAtObject(SPELL_DISPLACEMENT, OBJECT_SELF, METAMAGIC_ANY, 0, FALSE, PROJECTILE_PATH_TYPE_DEFAULT, bInstant);
                }

                //Regeneration Protections
                if(GetHasSpell(SPELL_REGENERATE) && !GetHasSpellEffect(SPELL_REGENERATE))
                {
                    ActionCastSpellAtObject(SPELL_REGENERATE, OBJECT_SELF, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, bInstant);
                }
                else if(GetHasSpell(SPELL_MONSTROUS_REGENERATION)&& !GetHasSpellEffect(SPELL_MONSTROUS_REGENERATION))
                {
                    ActionCastSpellAtObject(SPELL_MONSTROUS_REGENERATION, OBJECT_SELF, METAMAGIC_ANY, 0, FALSE, PROJECTILE_PATH_TYPE_DEFAULT, bInstant);
                }

                //Combat Protections
                if(GetHasSpell(SPELL_PREMONITION) && !GetHasSpellEffect(SPELL_PREMONITION))
                {
                    ActionCastSpellAtObject(SPELL_PREMONITION, OBJECT_SELF, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, bInstant);
                }
                else if(GetHasSpell(SPELL_GREATER_STONESKIN)&& !GetHasSpellEffect(SPELL_GREATER_STONESKIN))
                {
                    ActionCastSpellAtObject(SPELL_GREATER_STONESKIN, OBJECT_SELF, METAMAGIC_ANY, 0, FALSE, PROJECTILE_PATH_TYPE_DEFAULT, bInstant);
                }
                else if(GetHasSpell(SPELL_STONESKIN)&& !GetHasSpellEffect(SPELL_STONESKIN))
                {
                    ActionCastSpellAtObject(SPELL_STONESKIN, OBJECT_SELF, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, bInstant);
                }
                //Visage Protections
                if(GetHasSpell(SPELL_SHADOW_SHIELD)&& !GetHasSpellEffect(SPELL_SHADOW_SHIELD))
                {
                    ActionCastSpellAtObject(SPELL_SHADOW_SHIELD, OBJECT_SELF, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, bInstant);
                }
                else if(GetHasSpell(SPELL_ETHEREAL_VISAGE)&& !GetHasSpellEffect(SPELL_ETHEREAL_VISAGE))
                {
                    ActionCastSpellAtObject(SPELL_ETHEREAL_VISAGE, OBJECT_SELF, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, bInstant);
                }
                else if(GetHasSpell(SPELL_GHOSTLY_VISAGE)&& !GetHasSpellEffect(SPELL_GHOSTLY_VISAGE))
                {
                    ActionCastSpellAtObject(SPELL_GHOSTLY_VISAGE, OBJECT_SELF, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, bInstant);
                }
                //Mantle Protections
                if(GetHasSpell(SPELL_GREATER_SPELL_MANTLE)&& !GetHasSpellEffect(SPELL_GREATER_SPELL_MANTLE))
                {
                    ActionCastSpellAtObject(SPELL_GREATER_SPELL_MANTLE, OBJECT_SELF, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, bInstant);
                }
                else if(GetHasSpell(SPELL_SPELL_MANTLE)&& !GetHasSpellEffect(SPELL_SPELL_MANTLE))
                {
                    ActionCastSpellAtObject(SPELL_SPELL_MANTLE, OBJECT_SELF, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, bInstant);
                }
                else if(GetHasSpell(SPELL_LESSER_SPELL_BREACH)&& !GetHasSpellEffect(SPELL_LESSER_SPELL_BREACH))
                {
                    ActionCastSpellAtObject(SPELL_LESSER_SPELL_BREACH, OBJECT_SELF, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, bInstant);
                }
                // Globes
                if(GetHasSpell(SPELL_GLOBE_OF_INVULNERABILITY)&& !GetHasSpellEffect(SPELL_GLOBE_OF_INVULNERABILITY))
                {
                    ActionCastSpellAtObject(SPELL_GLOBE_OF_INVULNERABILITY, OBJECT_SELF, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, bInstant);
                }
                else if(GetHasSpell(SPELL_MINOR_GLOBE_OF_INVULNERABILITY)&& !GetHasSpellEffect(SPELL_MINOR_GLOBE_OF_INVULNERABILITY))
                {
                    ActionCastSpellAtObject(SPELL_MINOR_GLOBE_OF_INVULNERABILITY, OBJECT_SELF, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, bInstant);
                }

                //Misc Protections
                if(GetHasSpell(SPELL_ELEMENTAL_SHIELD)&& !GetHasSpellEffect(SPELL_ELEMENTAL_SHIELD))
                {
                    ActionCastSpellAtObject(SPELL_ELEMENTAL_SHIELD, OBJECT_SELF, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, bInstant);
                }
                else if (GetHasSpell(SPELL_MESTILS_ACID_SHEATH)&& !GetHasSpellEffect(SPELL_MESTILS_ACID_SHEATH))
                {
                    ActionCastSpellAtObject(SPELL_MESTILS_ACID_SHEATH, OBJECT_SELF, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, bInstant);
                }
                else if (GetHasSpell(SPELL_DEATH_ARMOR)&& !GetHasSpellEffect(SPELL_DEATH_ARMOR))
                {
                    ActionCastSpellAtObject(SPELL_DEATH_ARMOR, OBJECT_SELF, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, bInstant);
                }

                //Elemental Protections
                if(GetHasSpell(SPELL_ENERGY_BUFFER)&& !GetHasSpellEffect(SPELL_ENERGY_BUFFER))
                {
                    ActionCastSpellAtObject(SPELL_ENERGY_BUFFER, OBJECT_SELF, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, bInstant);
                }
                else if(GetHasSpell(SPELL_PROTECTION_FROM_ELEMENTS)&& !GetHasSpellEffect(SPELL_PROTECTION_FROM_ELEMENTS))
                {
                    ActionCastSpellAtObject(SPELL_PROTECTION_FROM_ELEMENTS, OBJECT_SELF, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, bInstant);
                }
                else if(GetHasSpell(SPELL_RESIST_ELEMENTS)&& !GetHasSpellEffect(SPELL_RESIST_ELEMENTS))
                {
                    ActionCastSpellAtObject(SPELL_RESIST_ELEMENTS, OBJECT_SELF, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, bInstant);
                }
                else if(GetHasSpell(SPELL_ENDURE_ELEMENTS)&& !GetHasSpellEffect(SPELL_ENDURE_ELEMENTS))
                {
                    ActionCastSpellAtObject(SPELL_ENDURE_ELEMENTS, OBJECT_SELF, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, bInstant);
                }

                //Mental Protections
                if(GetHasSpell(SPELL_MIND_BLANK)&& !GetHasSpellEffect(SPELL_MIND_BLANK))
                {
                    ActionCastSpellAtObject(SPELL_MIND_BLANK, OBJECT_SELF, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, bInstant);
                }
                else if(GetHasSpell(SPELL_LESSER_MIND_BLANK)&& !GetHasSpellEffect(SPELL_LESSER_MIND_BLANK))
                {
                    ActionCastSpellAtObject(SPELL_LESSER_MIND_BLANK, OBJECT_SELF, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, bInstant);
                }
                else if(GetHasSpell(SPELL_CLARITY)&& !GetHasSpellEffect(SPELL_CLARITY))
                {
                    ActionCastSpellAtObject(SPELL_CLARITY, OBJECT_SELF, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, bInstant);
                }

                //Summon Ally
                if(GetHasSpell(SPELL_BLACK_BLADE_OF_DISASTER))
                {
                    ActionCastSpellAtLocation(SPELL_BLACK_BLADE_OF_DISASTER, GetLocation(OBJECT_SELF), METAMAGIC_ANY, FALSE, PROJECTILE_PATH_TYPE_DEFAULT, bInstant);
                }
                else if(GetHasSpell(SPELL_SUMMON_CREATURE_IX))
                {
                    ActionCastSpellAtLocation(SPELL_SUMMON_CREATURE_IX, GetLocation(OBJECT_SELF), METAMAGIC_ANY, FALSE, PROJECTILE_PATH_TYPE_DEFAULT, bInstant);
                }
                else if(GetHasSpell(SPELLABILITY_PM_SUMMON_GREATER_UNDEAD))
                {
                    ActionCastSpellAtLocation(SPELLABILITY_PM_SUMMON_GREATER_UNDEAD, GetLocation(OBJECT_SELF), METAMAGIC_ANY, FALSE, PROJECTILE_PATH_TYPE_DEFAULT, bInstant);
                }
                else if(GetHasSpell(SPELL_SUMMON_CREATURE_VIII))
                {
                    ActionCastSpellAtLocation(SPELL_SUMMON_CREATURE_VIII, GetLocation(OBJECT_SELF), METAMAGIC_ANY, FALSE, PROJECTILE_PATH_TYPE_DEFAULT, bInstant);
                }
                else if(GetHasSpell(SPELL_SUMMON_CREATURE_VII))
                {
                    ActionCastSpellAtLocation(SPELL_SUMMON_CREATURE_VII, GetLocation(OBJECT_SELF), METAMAGIC_ANY, FALSE, PROJECTILE_PATH_TYPE_DEFAULT, bInstant);
                }
                else if(GetHasSpell(SPELL_SUMMON_CREATURE_VI))
                {
                    ActionCastSpellAtLocation(SPELL_SUMMON_CREATURE_VI, GetLocation(OBJECT_SELF), METAMAGIC_ANY, FALSE, PROJECTILE_PATH_TYPE_DEFAULT, bInstant);
                }
                else if(GetHasSpell(SPELL_CREATE_UNDEAD))
                {
                    ActionCastSpellAtLocation(SPELL_CREATE_UNDEAD, GetLocation(OBJECT_SELF), METAMAGIC_ANY, FALSE, PROJECTILE_PATH_TYPE_DEFAULT, bInstant);
                }
                else if(GetHasSpell(SPELL_PLANAR_ALLY))
                {
                    ActionCastSpellAtLocation(SPELL_PLANAR_ALLY, GetLocation(OBJECT_SELF), METAMAGIC_ANY, FALSE, PROJECTILE_PATH_TYPE_DEFAULT, bInstant);
                }
                else if(GetHasSpell(SPELL_SUMMON_CREATURE_V))
                {
                    ActionCastSpellAtLocation(SPELL_SUMMON_CREATURE_V, GetLocation(OBJECT_SELF), METAMAGIC_ANY, FALSE, PROJECTILE_PATH_TYPE_DEFAULT, bInstant);
                }
                else if(GetHasSpell(SPELL_SUMMON_CREATURE_IV))
                {
                    ActionCastSpellAtLocation(SPELL_SUMMON_CREATURE_IV, GetLocation(OBJECT_SELF), METAMAGIC_ANY, FALSE, PROJECTILE_PATH_TYPE_DEFAULT, bInstant);
                }
                else if(GetHasSpell(SPELL_ANIMATE_DEAD))
                {
                    ActionCastSpellAtLocation(SPELL_ANIMATE_DEAD, GetLocation(OBJECT_SELF), METAMAGIC_ANY, FALSE, PROJECTILE_PATH_TYPE_DEFAULT, bInstant);
                }
                else if(GetHasSpell(SPELL_SUMMON_CREATURE_III))
                {
                    ActionCastSpellAtLocation(SPELL_SUMMON_CREATURE_III, GetLocation(OBJECT_SELF), METAMAGIC_ANY, FALSE, PROJECTILE_PATH_TYPE_DEFAULT, bInstant);
                }
                else if(GetHasSpell(SPELL_SUMMON_CREATURE_II))
                {
                    ActionCastSpellAtLocation(SPELL_SUMMON_CREATURE_II, GetLocation(OBJECT_SELF), METAMAGIC_ANY, FALSE, PROJECTILE_PATH_TYPE_DEFAULT, bInstant);
                }
                else if(GetHasSpell(SPELL_SUMMON_CREATURE_I))
                {
                    ActionCastSpellAtLocation(SPELL_SUMMON_CREATURE_I, GetLocation(OBJECT_SELF), METAMAGIC_ANY, FALSE, PROJECTILE_PATH_TYPE_DEFAULT, bInstant);
                }

                //MyPrintString("TalentAdvancedBuff Successful Exit");
                return TRUE;
            //}
        //}
    //}
    //MyPrintString("TalentAdvancedBuff Failed Exit");
    //return FALSE;
}

// USE POTIONS
int TalentBuffSelf()
{
    //MyPrintString("TalentBuffSelf Enter");
    int nCRMax = GetCRMax();
    talent tUse = GetCreatureTalent(TALENT_CATEGORY_BENEFICIAL_PROTECTION_POTION, nCRMax);
    if(!GetIsTalentValid(tUse))
    {
        tUse = GetCreatureTalent(TALENT_CATEGORY_BENEFICIAL_ENHANCEMENT_POTION, nCRMax);
        if(!GetIsTalentValid(tUse))
            return FALSE;
    }
    if(GetTypeFromTalent(tUse) == TALENT_TYPE_SPELL && !GetHasSpellEffect(GetIdFromTalent(tUse)))
    {
        //MyPrintString("TalentBuffSelf Successful Exit");
        if(bkTalentFilterTest(TALENT_TYPE_SPELL,GetIdFromTalent(tUse),OBJECT_SELF))
        {
            ActionUseTalentOnObject(tUse,OBJECT_SELF);//1.72: special filter that doesn't check polymorph as potions can be used in polymorph
            return TRUE;
        }
    }
    //MyPrintString("TalentBuffSelf Failed Exit");
    return FALSE;
}

// USE SPELLS TO DEFEAT INVISIBLE CREATURES
int TalentSeeInvisible()
{
    //MyPrintString("TalentSeeInvisible Enter");
    int nSpell = -1;
    if(!GetHasSpellEffect(SPELL_TRUE_SEEING) && !GetHasFeat(FEAT_BLINDSIGHT_60_FEET) && !GetItemHasItemProperty(GetItemInSlot(INVENTORY_SLOT_CARMOUR,OBJECT_SELF),ITEM_PROPERTY_TRUE_SEEING))
    {//1.71: only cast this if not already benefiting from true seeing or blindsight ability
        if(GetHasSpell(SPELL_TRUE_SEEING))
        {
            nSpell = SPELL_TRUE_SEEING;
        }
        else if(GetHasSpell(SPELL_SEE_INVISIBILITY) && !GetHasSpellEffect(SPELL_SEE_INVISIBILITY))
        {
            nSpell = SPELL_SEE_INVISIBILITY;
        }
        if(GetHasSpell(SPELL_INVISIBILITY_PURGE) && !GetHasSpellEffect(SPELL_INVISIBILITY_PURGE))
        {
            nSpell = SPELL_INVISIBILITY_PURGE;
        }
        else if(GetHasSpell(SPELL_CLAIRAUDIENCE_AND_CLAIRVOYANCE) && !GetHasSpellEffect(SPELL_CLAIRAUDIENCE_AND_CLAIRVOYANCE))
        {
            nSpell = SPELL_CLAIRAUDIENCE_AND_CLAIRVOYANCE;
        }
        else if(GetHasSpell(SPELL_AMPLIFY) && !GetHasSpellEffect(SPELL_AMPLIFY))
        {//1.71: amplify might be to some use as well
            nSpell = SPELL_AMPLIFY;
        }
        else if(GetHasSpell(SPELL_DARKVISION) && !GetHasEffect(EFFECT_TYPE_ULTRAVISION) && GetHasEffect(EFFECT_TYPE_DARKNESS))
        {//1.72: use darkvision in darkness
            nSpell = SPELL_DARKVISION;
        }
        else//1.72: no spells, look for a talent then
        {
            int nTalent;
            talent tUse = GetCreatureTalentBest(TALENT_CATEGORY_BENEFICIAL_CONDITIONAL_SINGLE,-1,OBJECT_SELF);
            while(GetIsTalentValid(tUse) && nTalent++ < 10)
            {
                if(GetTypeFromTalent(tUse) == TALENT_TYPE_SPELL && !GetHasSpellEffect(GetIdFromTalent(tUse)))
                {
                    switch(GetIdFromTalent(tUse))
                    {
                    case SPELL_DARKVISION:
                        if(!GetHasEffect(EFFECT_TYPE_DARKNESS))
                            break;
                    case SPELL_TRUE_SEEING:
                    case SPELL_SEE_INVISIBILITY:
                    case SPELL_CLAIRAUDIENCE_AND_CLAIRVOYANCE:
                        if(bkTalentFilter(tUse,OBJECT_SELF))
                            return TRUE;
                        break;
                    }
                }
                tUse = GetCreatureTalentBest(TALENT_CATEGORY_BENEFICIAL_CONDITIONAL_SINGLE,-1,OBJECT_SELF);
            }
            tUse = GetCreatureTalentBest(TALENT_CATEGORY_BENEFICIAL_CONDITIONAL_SINGLE,0,OBJECT_SELF);
            while(GetIsTalentValid(tUse) && nTalent++ < 20)
            {
                if(GetTypeFromTalent(tUse) == TALENT_TYPE_SPELL && !GetHasSpellEffect(GetIdFromTalent(tUse)))
                {
                    switch(GetIdFromTalent(tUse))
                    {
                    case SPELL_DARKVISION:
                        if(!GetHasEffect(EFFECT_TYPE_DARKNESS))
                            break;
                    case SPELL_TRUE_SEEING:
                    case SPELL_SEE_INVISIBILITY:
                    case SPELL_CLAIRAUDIENCE_AND_CLAIRVOYANCE:
                        if(bkTalentFilter(tUse,OBJECT_SELF))
                            return TRUE;
                        break;
                    }
                }
                tUse = GetCreatureTalentBest(TALENT_CATEGORY_BENEFICIAL_CONDITIONAL_SINGLE,0,OBJECT_SELF);
            }
            tUse = GetCreatureTalentRandom(TALENT_CATEGORY_BENEFICIAL_CONDITIONAL_POTION,OBJECT_SELF);
            while(GetIsTalentValid(tUse) && nTalent++ < 30)
            {
                if(GetTypeFromTalent(tUse) == TALENT_TYPE_SPELL && !GetHasSpellEffect(GetIdFromTalent(tUse)))
                {
                    switch(GetIdFromTalent(tUse))
                    {
                    case SPELL_DARKVISION:
                        if(!GetHasEffect(EFFECT_TYPE_DARKNESS))
                            break;
                    case SPELL_TRUE_SEEING:
                    case SPELL_SEE_INVISIBILITY:
                    case SPELL_CLAIRAUDIENCE_AND_CLAIRVOYANCE:
                        if(bkTalentFilter(tUse,OBJECT_SELF))
                            return TRUE;
                        break;
                    }
                }
                tUse = GetCreatureTalentRandom(TALENT_CATEGORY_BENEFICIAL_CONDITIONAL_POTION,OBJECT_SELF);
            }
        }
    }
    else if(GetHasSpell(SPELL_INVISIBILITY_PURGE) && !GetHasSpellEffect(SPELL_INVISIBILITY_PURGE))
    {
        nSpell = SPELL_INVISIBILITY_PURGE;
    }
    if(nSpell != -1)
    {
        //MyPrintString("TalentSeeInvisible Successful Exit");
        if(bkTalentFilterSpell(nSpell,OBJECT_SELF))
            return TRUE;
    }
    //MyPrintString("TalentSeeInvisible Failed Exit");
    return FALSE;
}

// Utility function for TalentCureCondition
// Checks to see if the creature has the given condition in the
// given condition value.
// To use, you must first calculate the nCurrentConditions value
// with GetCurrentNegativeConditions.
// The value of nCondition can be any of the COND_* constants
// declared in x0_i0_talent.
int GetHasNegativeCondition(int nCondition, int nCurrentConditions)
{
    return (nCurrentConditions & nCondition);
}

// Utility function for TalentCureCondition
// Returns an integer with bitwise flags set that represent the
// current negative conditions on the creature.
// To be used with GetHasNegativeCondition.
int GetCurrentNegativeConditions(object oCreature)
{
    int nSum;
    effect eEffect = GetFirstEffect(oCreature);
    while(GetIsEffectValid(eEffect)) {
        switch (GetEffectType(eEffect)) {
        case EFFECT_TYPE_DISEASE:           nSum|= COND_DISEASE; break;
        case EFFECT_TYPE_POISON:            nSum|= COND_POISON; break;
        case EFFECT_TYPE_CURSE:             nSum|= COND_CURSE; break;
        case EFFECT_TYPE_NEGATIVELEVEL:     nSum|= COND_DRAINED; break;
        case EFFECT_TYPE_ABILITY_DECREASE:  nSum|= COND_ABILITY; break;
        case EFFECT_TYPE_BLINDNESS:
        case EFFECT_TYPE_DEAF:              nSum|= COND_BLINDDEAF; break;
        //1.72: additional conditional effects
        case EFFECT_TYPE_FRIGHTENED:        nSum|= COND_FEAR;
        case EFFECT_TYPE_CONFUSED:
        case EFFECT_TYPE_CHARMED:
        case EFFECT_TYPE_DAZED:
        case EFFECT_TYPE_DOMINATED:
        case EFFECT_TYPE_SLEEP:
        case EFFECT_TYPE_STUNNED:           nSum|= COND_MINDAFFECTING; break;
        case EFFECT_TYPE_PARALYZE:          if(!GetModuleSwitchValue("72_DISABLE_PARALYZE_MIND_SPELL_IMMUNITY")) nSum|= COND_MINDAFFECTING;
        case EFFECT_TYPE_SLOW:
        case EFFECT_TYPE_ENTANGLE:          nSum|= COND_IMPAIREDMOBILITY; break;
        case EFFECT_TYPE_PETRIFY:           nSum|= COND_PETRIFY; break;
        }
        eEffect = GetNextEffect(oCreature);
    }
    return nSum;
}

// CURE DISEASE, POISON ETC
int TalentCureCondition()
{
    //MyPrintString("TalentCureCondition Enter");
    int nSum, LR,R,GR, nSpell;
    location lTarget = GetLocation(OBJECT_SELF);

    object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_HUGE, lTarget);
    while(GetIsObjectValid(oTarget))
    {
        if(GetIsFriend(oTarget)) {
            nSpell = 0;
            nSum = GetCurrentNegativeConditions(oTarget);
            if (nSum) {
                // friend has negative effects -- try and heal them
                //1.72: cure petrifz with highest priority
                if(GetHasNegativeCondition(COND_PETRIFY, nSum))
                {
                    if(bkTalentFilterSpell(SPELL_STONE_TO_FLESH,oTarget))
                        return TRUE;
                }
                // These effects will be healed in reverse order if
                // we have the spells for them and don't have
                // restoration.
                if (GetHasNegativeCondition(COND_POISON, nSum)) {
                    R++;
                    if (GetHasSpell(SPELL_NEUTRALIZE_POISON))
                        nSpell = SPELL_NEUTRALIZE_POISON;
                }
                if (GetHasNegativeCondition(COND_DISEASE, nSum)) {
                    R++;
                    if (GetHasSpell(SPELL_REMOVE_DISEASE))
                        nSpell = SPELL_REMOVE_DISEASE;
                }
                if (GetHasNegativeCondition(COND_CURSE, nSum)) {
                    GR++;
                    if (GetHasSpell(SPELL_REMOVE_CURSE))
                        nSpell = SPELL_REMOVE_CURSE;
                }
                if (GetHasNegativeCondition(COND_BLINDDEAF, nSum)) {
                    R++;
                    if (GetHasSpell(SPELL_REMOVE_BLINDNESS_AND_DEAFNESS))
                        nSpell = SPELL_REMOVE_BLINDNESS_AND_DEAFNESS;
                }

                // For the conditions that can only be cured by
                // restoration, we add 2
                if (GetHasNegativeCondition(COND_DRAINED, nSum)) {
                    R+=2;
                }
                if (GetHasNegativeCondition(COND_ABILITY, nSum)) {
                    LR+=2;
                }
                //1.72: cure fear
                if(GetHasNegativeCondition(COND_FEAR, nSum))
                {
                    GR++;
                    if (GetHasSpell(SPELL_REMOVE_FEAR))
                        nSpell = SPELL_REMOVE_FEAR;
                }
                //1.72: cure mind-affecting effects
                if(GetHasNegativeCondition(COND_MINDAFFECTING, nSum))
                {
                    GR++;
                    if (GetHasSpell(SPELL_CLARITY))
                        nSpell = SPELL_CLARITY;
                    else if (GetHasSpell(SPELL_LESSER_MIND_BLANK))
                        nSpell = SPELL_LESSER_MIND_BLANK;
                    else if (GetHasSpell(SPELL_MIND_BLANK))
                        nSpell = SPELL_MIND_BLANK;
                }
                // If we have more than one condition or a condition
                // that can only be cured by restoration, try one of
                // those spells first if we have them.
                if (((!nSpell && LR > 0) || LR > 1) && GetHasSpell(SPELL_LESSER_RESTORATION))
                {
                   nSpell = SPELL_LESSER_RESTORATION;
                }
                if ((!nSpell && (R > 0 || LR > 0)) || R > 1)
                {
                   if(GetHasSpell(SPELL_RESTORATION))
                       nSpell = SPELL_RESTORATION;
                   else if(oTarget != OBJECT_SELF && GetHasSpell(568))
                       nSpell = 568;//restoration - others
                }
                if (((!nSpell && (GR > 0 || R > 0 || LR > 2)) || GR > 0) && GetHasSpell(SPELL_GREATER_RESTORATION))
                {
                    nSpell = SPELL_GREATER_RESTORATION;
                }
                //1.72: cure slow/entangle/paralysis, lowest priority
                if(!nSpell && GetHasNegativeCondition(COND_IMPAIREDMOBILITY, nSum) && GetHasSpell(SPELL_FREEDOM_OF_MOVEMENT))
                {
                    nSpell = SPELL_FREEDOM_OF_MOVEMENT;
                }

                if(nSpell != 0)
                {
                    //MyPrintString("TalentCureCondition Successful Exit");
                    if(bkTalentFilterSpell(nSpell,oTarget))
                        return TRUE;
                }
            }
        }
        oTarget = GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_HUGE, lTarget);
    }
    //MyPrintString("TalentCureCondition Failed Exit");
    return FALSE;
}

// DRAGON COMBAT
// * February 2003: Cut the melee interaction (BK)
int TalentDragonCombat(object oIntruder = OBJECT_INVALID)
{
    //MyPrintString("TalentDragonCombat Enter");
    object oTarget = oIntruder;
    if(!GetIsObjectValid(oTarget))
    {
        oTarget = GetAttemptedAttackTarget();
        if(!GetIsObjectValid(oTarget) || GetIsDead(oTarget))
        {
            oTarget = GetLastHostileActor();
            if(!GetIsObjectValid(oTarget) || GetIsDead(oTarget))
            {
                oTarget = GetNearestPerceivedEnemy();
                if(!GetIsObjectValid(oTarget))
                {
                    return FALSE;
                }
            }
        }
    }
    int nCnt = GetLocalInt(OBJECT_SELF, "NW_GENERIC_DRAGONS_BREATH");
    talent tUse = GetCreatureTalent(TALENT_CATEGORY_DRAGONS_BREATH, GetCRMax());
    //SpeakString(IntToString(nCnt));
    if(GetIsTalentValid(tUse) && nCnt >= 2)
    {
        //MyPrintString("TalentDragonCombat Successful Exit");
        if(bkTalentFilter(tUse, oTarget))
        {
            SetLocalInt(OBJECT_SELF, "NW_GENERIC_DRAGONS_BREATH", 0);
            return TRUE;
        }
    }
    // * breath weapons only happen every 3 rounds
    SetLocalInt(OBJECT_SELF, "NW_GENERIC_DRAGONS_BREATH", ++nCnt);

    //MyPrintString("TalentDragonCombat Failed Exit");
    //SetLocalInt(OBJECT_SELF, "NW_GENERIC_DRAGONS_BREATH", nCnt);
    return FALSE;
}

// BARD SONG
// * July 15 2003: Improving so its more likely
// * to work with non creature wizard designed creatures
// * GZ: Capped bardsong at level 20 so we don't overflow into
//       other feats
int TalentBardSong()
{
    //MyPrintString("TalentBardSong Enter");                                  //1.71: fix for silence/deaf issue that led into endless bard song loop or being stuck
    if(GetLevelByClass(CLASS_TYPE_BARD) > 0 && GetHasFeat(FEAT_BARD_SONGS) && !GetHasEffect(EFFECT_TYPE_SILENCE) && !GetHasEffect(EFFECT_TYPE_DEAF))
    {
        if(!GetHasSpellEffect(411))
        {
            //MyPrintString("TalentBardSong Successful Exit");
            ClearActions(CLEAR_X0_I0_TALENT_BardSong);
            ActionUseFeat(FEAT_BARD_SONGS, OBJECT_SELF);
            return TRUE;
        }
        else if(GetHasFeat(FEAT_CURSE_SONG))//1.71: added support for curse song
        {
            if(GetHasSpellEffect(644))
            {
                effect e = GetFirstEffect(OBJECT_SELF);
                while(GetIsEffectValid(e))
                {
                    if(GetEffectSpellId(e) == 644 && GetEffectCreator(e) == OBJECT_SELF)
                    {
                        return FALSE;
                    }
                    e = GetNextEffect(OBJECT_SELF);
                }
            }
            object oEnemy = GetNearestEnemy();
            if(oEnemy != OBJECT_INVALID && GetDistanceToObject(oEnemy) <= 10.0)
            {
                //MyPrintString("TalentBardSong Successful Exit");
                ClearActions(CLEAR_X0_I0_TALENT_BardSong);
                ActionUseFeat(FEAT_CURSE_SONG, OBJECT_SELF);
                return TRUE;
            }
        }
    }
    //MyPrintString("TalentBardSong Failed Exit");
    return FALSE;
}

//**********************************
//**********************************
//**********************************
// VERSION 2.0 TALENTS
//**********************************
//**********************************
//**********************************

// ADVANCED PROTECT SELF Talent 2.0
// This will use the class specific defensive spells first and
// leave the rest for the normal defensive AI
int TalentAdvancedProtectSelf()
{
    //MyPrintString("TalentAdvancedProtectSelf Enter");
    struct sEnemies sCount = DetermineEnemies();
    int bValid, nCnt, nCR = GetCRMax();
    string sClass = GetMostDangerousClass(sCount);
    talent tUse = StartProtectionLoop();
    for(nCnt; GetIsTalentValid(tUse) && nCnt < 10; nCnt++)
    {
        //MyPrintString("TalentAdvancedProtectSelf Search Self");
        tUse = GetCreatureTalent(TALENT_CATEGORY_BENEFICIAL_PROTECTION_SELF, nCR);
        if(GetIsTalentValid(tUse) && GetMatchCompatibility(tUse, sClass, NW_TALENT_PROTECT))
        {
            bValid = TRUE;
            break;
        }
        else
        {
            //MyPrintString(" TalentAdvancedProtectSelfSearch Single");
            tUse = GetCreatureTalent(TALENT_CATEGORY_BENEFICIAL_PROTECTION_SINGLE, nCR);
            if(GetIsTalentValid(tUse) && GetMatchCompatibility(tUse, sClass, NW_TALENT_PROTECT))
            {
                bValid = TRUE;
                break;
            }
            else
            {
                //MyPrintString("TalentAdvancedProtectSelf Search Area");
                tUse = GetCreatureTalent(TALENT_CATEGORY_BENEFICIAL_PROTECTION_AREAEFFECT, nCR);
                if(GetIsTalentValid(tUse) && GetMatchCompatibility(tUse, sClass, NW_TALENT_PROTECT))
                {
                    bValid = TRUE;
                    break;
                }
            }
        }
    }

    if(bValid)
    {
        switch(GetTypeFromTalent(tUse))
        {
            case TALENT_TYPE_SPELL:
            if(GetHasSpellEffect(GetIdFromTalent(tUse)))
            {
                return FALSE;
            }
            break;
            case TALENT_TYPE_FEAT:
            if(GetHasFeatEffect(GetIdFromTalent(tUse)))
            {
                return FALSE;
            }
            break;
        }
        //MyPrintString("TalentAdvancedProtectSelf Successful Exit");
        if(bkTalentFilter(tUse, OBJECT_SELF))
            return TRUE;
    }
    //MyPrintString("TalentAdvancedProtectSelf Failed Exit");
    return FALSE;
}

// Cast a spell mantle or globe of invulnerability protection on
// yourself.
int TalentSelfProtectionMantleOrGlobe()//1.72: rewrited to avoid issues with missing action cancel and to handle defensive casting and polymorph cast
{
    //Mantle Protections
    if (GetHasSpell(SPELL_GREATER_SPELL_MANTLE) && !GetHasSpellEffect(SPELL_GREATER_SPELL_MANTLE))
    {
        if(bkTalentFilterSpell(SPELL_GREATER_SPELL_MANTLE,OBJECT_SELF))
            return TRUE;
    }
    if (GetHasSpell(SPELL_SPELL_MANTLE) && !GetHasSpellEffect(SPELL_SPELL_MANTLE))
    {
        if(bkTalentFilterSpell(SPELL_SPELL_MANTLE,OBJECT_SELF))
            return TRUE;
    }
    if (GetHasSpell(SPELL_GLOBE_OF_INVULNERABILITY) && !GetHasSpellEffect(SPELL_GLOBE_OF_INVULNERABILITY))
    {
        if(bkTalentFilterSpell(SPELL_GLOBE_OF_INVULNERABILITY,OBJECT_SELF))
            return TRUE;
    }
    if (GetHasSpell(SPELL_MINOR_GLOBE_OF_INVULNERABILITY) && !GetHasSpellEffect(SPELL_MINOR_GLOBE_OF_INVULNERABILITY))
    {
        if(bkTalentFilterSpell(SPELL_MINOR_GLOBE_OF_INVULNERABILITY,OBJECT_SELF))
            return TRUE;
    }
    return FALSE;
}

// This function simply attempts to get the best protective
// talent that the caller has, the protective talents as
// follows:
// TALENT_CATEGORY_BENEFICIAL_PROTECTION_SELF
// TALENT_CATEGORY_BENEFICIAL_PROTECTION_SINGLE
// TALENT_CATEGORY_BENEFICIAL_PROTECTION_AREAEFFECT
talent StartProtectionLoop()
{
    int nCRMax = GetCRMax();
    talent tUse = GetCreatureTalent(TALENT_CATEGORY_BENEFICIAL_PROTECTION_SELF, nCRMax);
    if(GetIsTalentValid(tUse))
        return tUse;

    tUse = GetCreatureTalent(TALENT_CATEGORY_BENEFICIAL_PROTECTION_SINGLE, nCRMax);
    if(GetIsTalentValid(tUse))
        return tUse;

    tUse = GetCreatureTalent(TALENT_CATEGORY_BENEFICIAL_PROTECTION_AREAEFFECT, nCRMax);
    return tUse;
}
