//::///////////////////////////////////////////////
//::
//::////////////////////////////////////////////////////
//:: Some snippets By: Kato. Name: k_inc_xp_system
//:: Created On: December 2010
//::////////////////////////////////////////////////////

#include "inc_debug"
#include "inc_sql"

// The amount of bonus or penalty XP modified by level.
const float QUEST_XP_LEVEL_ADJUSTMENT_MODIFIER = 0.1;

const float BASE_XP = 4.0;

// The XP tiers for quests.
const float QUEST_XP_T1 = 50.0;
const float QUEST_XP_T2 = 100.0;
const float QUEST_XP_T3 = 200.0;
const float QUEST_XP_T4 = 400.0;

// The maximum XP limit for a single kill
const float XP_MAX = 20.0;

// The amount of XP rewarded per target level for quests
const float XP_BONUS_PER_LEVEL = 0.1;

// The maximum XP limit for a boss
const float XP_MAX_BOSS = 50.0;

// The % CR XP awarded to party when a trap or summon is the killer.
const float XP_NOPC = 1.00;

// XP percentage bonus/penalty based on wisdom score
// 12 wisdom - 2 wis score = 4% xp bonus
const float WISDOM_BONUS = 0.02;

// Races with at least one level in their favored class OR humans/half-elves who are triple class
// get a bonus to XP. 1.2 is equal to a 20% bonus.
const float FAVORED_BONUS = 1.2;

// Human/Half elves who are dual classed have this bonus.
// 1.1 is equal to a 10% bonus.
const float DUAL_CLASS_BONUS = 1.1;

// Set this value to 1 in order to display debug infos.
// Very useful during setup
const int K_DEBUG_TEXT = 0;

// The maximum party level gap. If the gap is greater/equal, no CR xp.
// Only the members within distance are included in gap
const int PARTY_GAP_MAX = 4;

// 4 / (2 + party size*1) = 60% xp with pc size of 2 and 0 henchman
const float PARTY_SIZE_BASE_MOD = 2.0;
const float PARTY_SIZE = 1.0;


// **** SYSTEM SETTINGS END - YOU SHOULD NOT MODIFY ANYTHING BELOW THIS! *******************************************




// ************ DECLARATIONS ****************************

// * The main function of the include, it distributes
// * xp to party members in a loop.
void GiveXP(object oKiller);


// Gives nXpAmount to oPC, wisdom adjusted
void GiveXPToPC(object oPC, float fXpAmount, int bQuest = FALSE);

// Gives nXp amount to oPC, wisdom adjusted
// with bonuses/penalties related to the target level
void GiveQuestXPToPC(object oPC, int nTier, int nLevel, int bBluff = FALSE);

// This function returns the level based on XP
int GetLevelFromXP(int nXP);

// ------------------ INTERNAL FUNCTIONS ----------------

// Courtesy of Sherincall (clippy) from discord
int Round(float f) { return FloatToInt(f +  (f > 0.0 ? 0.5 : -0.5) ); }

float Truncate(float fFloat)
{
    return StringToFloat(FloatToString(fFloat, 3, 2));
}

int GetLevelFromXP(int nXP)
{
   return FloatToInt(0.5 + sqrt(0.25 + (IntToFloat(nXP) / 500 )));
}


void GiveXPToPC(object oPC, float fXpAmount, int bQuest = FALSE)
{
// Dead PCs do not get any XP
   if (GetIsDead(oPC)) return;

   string sFavoredBonus = "";

// Calculate favored bonus
   float fFavoredModifier = 1.0;
   int nRace = GetRacialType(oPC);

   if (GetLocalInt(oPC, "BASE_RACE_SET") == 1)
       nRace = GetLocalInt(oPC, "BASE_RACE");

   switch (nRace)
   {
        case RACIAL_TYPE_DWARF:
            if (GetLevelByClass(CLASS_TYPE_FIGHTER, oPC) > 0) fFavoredModifier = FAVORED_BONUS;
            break;
        case RACIAL_TYPE_ELF:
        case RACIAL_TYPE_GNOME:
            if (GetLevelByClass(CLASS_TYPE_WIZARD, oPC) > 0) fFavoredModifier = FAVORED_BONUS;
            break;
        case RACIAL_TYPE_HALFLING:
            if (GetLevelByClass(CLASS_TYPE_ROGUE, oPC) > 0) fFavoredModifier = FAVORED_BONUS;
            break;
        case RACIAL_TYPE_HALFORC:
            if (GetLevelByClass(CLASS_TYPE_BARBARIAN, oPC) > 0) fFavoredModifier = FAVORED_BONUS;
            break;
        case RACIAL_TYPE_HUMAN:
        case RACIAL_TYPE_HALFELF:
            if (GetLevelByPosition(3, oPC) > 0)
            {
                fFavoredModifier = FAVORED_BONUS;
                sFavoredBonus = ", Triple-class: 20%";
            }
            else if (GetLevelByPosition(2, oPC) > 0)
            {
                fFavoredModifier = DUAL_CLASS_BONUS;
                sFavoredBonus = ", Dual-class: 10%";
            }
            break;
   }

// Calculate wisdom bonus
   int nWisdomMod = GetAbilityScore(oPC, ABILITY_WISDOM) - 10;
   float fWisdom = IntToFloat(nWisdomMod) * WISDOM_BONUS;

// calculate total bonus
   float fModifier = fFavoredModifier + fWisdom;

// cap
   if (fModifier > 1.5) fModifier = 1.5;

// for favored racial class with non humans/half-elves
   if (sFavoredBonus == "" && fFavoredModifier == FAVORED_BONUS) sFavoredBonus = ", Favored class: 20%";

   float fAdjustedXpAmount = fModifier * fXpAmount;

   if (bQuest)
   {
      int nTotal = FloatToInt(fAdjustedXpAmount - fXpAmount);

      string sBonus = "Bonus";
      if (nTotal < 0) sBonus = "Penalty";

      FloatingTextStringOnCreature("*XP "+sBonus+": "+IntToString(nTotal)+" (Wisdom: "+IntToString(nWisdomMod)+"%"+sFavoredBonus+")*", oPC, FALSE);
   }

   SendDebugMessage("fAdjustedXP without truncation: "+FloatToString(fAdjustedXpAmount));

// truncate
   //fAdjustedXpAmount = IntToFloat(FloatToInt(fAdjustedXpAmount*10.0))/10.0;
   fAdjustedXpAmount = Truncate(fAdjustedXpAmount);

   SendMessageToPC(oPC, "Experience Points Gained:  "+FloatToString(fAdjustedXpAmount, 3, 2));

   int iStoredRemainderXP = SQLocalsPlayer_GetInt(oPC, "xp_remainder");
   SendDebugMessage("Stored remainder XP: "+IntToString(iStoredRemainderXP));

// should never be higher than 90
   if (iStoredRemainderXP > 99)
        iStoredRemainderXP = 99;

// vice versa
   if (iStoredRemainderXP < 0)
        iStoredRemainderXP = 0;

   if (iStoredRemainderXP > 0)
       fAdjustedXpAmount = fAdjustedXpAmount + Truncate(IntToFloat(iStoredRemainderXP)/100.0);

   SendDebugMessage("fAdjustedXP after adding stored remainder: "+FloatToString(fAdjustedXpAmount, 3, 2));

   int iWhole = FloatToInt(Truncate(fAdjustedXpAmount));

   int iRemainder = FloatToInt(Truncate(((fAdjustedXpAmount - IntToFloat(iWhole))*100.0)));

   SendDebugMessage("Remainder XP to store: "+IntToString(iRemainder));

   SQLocalsPlayer_SetInt(oPC, "xp_remainder", iRemainder);



   if (iWhole > 0)
       SetXP(oPC, GetXP(oPC) + iWhole);
}

void GiveQuestXPToPC(object oPC, int nTier, int nLevel, int bBluff = FALSE)
{
   if (nTier == 0 || nLevel == 0) return;

   float fXP = 0.0;
   float fMod = 1.0;
   int nPCLevel = GetLevelFromXP(GetXP(oPC));
   int nAdjust = nLevel - nPCLevel;
   float fAdjust = IntToFloat(nAdjust) * QUEST_XP_LEVEL_ADJUSTMENT_MODIFIER;

   fMod = fMod + fAdjust;

// capped at 25% xp
   if (fMod < 0.25) fMod = 0.25;
// capped at 150% xp
   if (fMod > 1.5) fMod = 1.5;


   SendDebugMessage("Target quest XP level: "+IntToString(nLevel));
   SendDebugMessage("Quest XP percentage modifier : "+FloatToString(fMod));


   switch (nTier)
   {
      case 1: fXP = QUEST_XP_T1; break;
      case 2: fXP = QUEST_XP_T2; break;
      case 3: fXP = QUEST_XP_T3; break;
      case 4: fXP = QUEST_XP_T4; break;
   }

   SendDebugMessage("Quest base XP: "+FloatToString(fXP));

   if (nLevel > 0)
   {
       fXP = fXP + (fXP * (IntToFloat(nLevel)*XP_BONUS_PER_LEVEL));
   }

   fXP = fXP * fMod;

   if (bBluff) fXP = fXP * 0.5;

   SendDebugMessage("Quest XP level adjusted: "+FloatToString(fXP));

   GiveXPToPC(oPC, fXP, TRUE);
}

// get xp amount by level
int GetXPFromLevel(int nLevel)
{
   int nXP = (((nLevel - 1) * nLevel) /2) * 1000;
   return nXP;
}

float GetPartyXPValue(object oCreature, int bAmbush, float fAverageLevel, int iTotalSize, float fMultiplier = 1.0)
{
// If the CR is 0.0, then assume this is not a kill and do not do any XP related thingies.
   float fCR = GetChallengeRating(OBJECT_SELF);
   float fXP;

// if tagged no xp just return 0 early
   if (GetLocalInt(oCreature, "no_xp") == 1) return 0.0;

   if (fCR <= 0.0) {return 0.0;}
   else if (fCR <= 1.0/8.0) {fXP = BASE_XP + 2.0;}
   else if (fCR <= 1.0/6.0) {fXP = BASE_XP + 3.0;}
   else if (fCR <= 1.0/4.0) {fXP = BASE_XP + 4.0;}
   else if (fCR <= 1.0/3.0) {fXP = BASE_XP + 5.0;}
   else if (fCR <= 1.0/2.0) {fXP = BASE_XP + 6.0;}
   else if (fCR <= 1.0) {fXP = BASE_XP + 12.0;}
   else if (fCR <= 2.0) {fXP = BASE_XP + 20.0;}
   else if (fCR <= 3.0) {fXP = BASE_XP + 28.0;}
   else if (fCR <= 4.0) {fXP = BASE_XP + 36.0;}
   else if (fCR <= 5.0) {fXP = BASE_XP + 44.0;}
   else if (fCR <= 6.0) {fXP = BASE_XP + 52.0;}
   else if (fCR <= 7.0) {fXP = BASE_XP + 60.0;}
   else if (fCR <= 8.0) {fXP = BASE_XP + 66.0;}
   else if (fCR <= 9.0) {fXP = BASE_XP + 72.0;}
   else if (fCR <= 10.0) {fXP = BASE_XP + 80.0;}
   else if (fCR <= 11.0) {fXP = BASE_XP + 88.0;}
   else if (fCR <= 12.0) {fXP = BASE_XP + 96.0;}
   else if (fCR <= 13.0) {fXP = BASE_XP + 104.0;}
   else if (fCR <= 14.0) {fXP = BASE_XP + 112.0;}
   else if (fCR <= 15.0) {fXP = BASE_XP + 120.0;}
   else if (fCR <= 16.0) {fXP = BASE_XP + 128.0;}
   else if (fCR <= 17.0) {fXP = BASE_XP + 136.0;}
   else if (fCR > 17.0) {fXP = BASE_XP + 144.0;}
   else {return 0.0;}

   fXP = fXP * fMultiplier;

   float fXPPenaltyMod = 1.0;

   float fDifference = fAverageLevel - fCR;

   if (fDifference > 0.0) fXPPenaltyMod = fXPPenaltyMod - (fDifference*0.15);

   if (fXPPenaltyMod < 0.1) fXPPenaltyMod = 0.1;

// penalty should never be higher than 1.0 otherwise that's a bonus
   if (fXPPenaltyMod > 1.0) fXPPenaltyMod = 1.0;

   if (fXP > 0.0)
   {
// ambushes only give 1/3 xp
       if (bAmbush) fXP = fXP/3.0;

       if (fAverageLevel < 1.0) fAverageLevel = 1.0; //failsafe if party average level was 0 or less

       float fTotalSize = IntToFloat(iTotalSize);
       if (fTotalSize < 1.0) fTotalSize = 1.0; //failsafe is party total size was 0 or less

       float fPartyMod = PARTY_SIZE_BASE_MOD/(PARTY_SIZE+(fTotalSize*PARTY_SIZE));

       fXP = fXP*fXPPenaltyMod;

       SendDebugMessage("Party XP mod: "+FloatToString(fPartyMod));
       SendDebugMessage("fXP penalty mod: "+FloatToString(fXPPenaltyMod));
       SendDebugMessage("fCR: "+FloatToString(fCR));
       SendDebugMessage("fXP: "+FloatToString(fXP));

       fXP = (fXP / fAverageLevel) * fPartyMod;

    // Cap the xp
       if ((fXP*fXPPenaltyMod) > XP_MAX) fXP = XP_MAX;
   }

   if (fXP == 0.0) return 0.0;

   if (fXP < 0.01) fXP = 0.01;

   SendDebugMessage("fXP (modified by average level and party): "+FloatToString(fXP));
   return fXP;
}
//------------------------------  END INTERNAL FUNCTIONS  -----------------------------------



// ********************************  DEFINITIONS  ******************************************


//void main(){}
