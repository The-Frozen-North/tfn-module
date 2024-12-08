//::///////////////////////////////////////////////
//::
//::////////////////////////////////////////////////////
//:: Some snippets By: Kato. Name: k_inc_xp_system
//:: Created On: December 2010
//::////////////////////////////////////////////////////

#include "inc_debug"
#include "inc_sql"
#include "x3_inc_string"
#include "inc_nui_config"

// I think this is the easiest way around the cyclical include
// Update the XP bar NUI for oPC.
void UpdateXPBarUI(object oPC);

#include "inc_restxp"

// The amount of bonus or penalty XP modified by level.
const float QUEST_XP_LEVEL_ADJUSTMENT_MODIFIER = 0.1;

// how much XP you should earn at the equivalent level
const float BASE_XP = 10.0;

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
// 12 wisdom = 2 "wis score" = 2% xp bonus
const float WISDOM_BONUS = 0.01;

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

// PARTY_SIZE_BASE_MOD / PARTY_SIZE_BASE_MOD - 1.0 + party size = 75% xp with a party size of 2 and a base mod of 3
// with a base mod of 5 and a party of two, the xp percentage is 83%
const float PARTY_SIZE_BASE_MOD = 5.0; // increase to decrease XP penalty

// how much XP is awarded through stealth
const float STEALTH_XP_PERCENTAGE = 0.5;

// how much XP is awarded through pickpocketing or animal empathy
const float SKILL_XP_PERCENTAGE = 0.25;

// note: the sum of both of the numbers must NOT be above 1.0, or it may result in negative XP!!

// **** SYSTEM SETTINGS END - YOU SHOULD NOT MODIFY ANYTHING BELOW THIS! *******************************************




// ************ DECLARATIONS ****************************

// * The main function of the include, it distributes
// * xp to party members in a loop.
void GiveXP(object oKiller);


// Gives nXpAmount to oPC, wisdom adjusted
void GiveXPToPC(object oPC, float fXpAmount, int bQuest = FALSE, string sSource = "");

// Gives nXp amount to oPC, wisdom adjusted
// with bonuses/penalties related to the target level
void GiveQuestXPToPC(object oPC, int nTier, int nLevel, int bBluff = FALSE);

// Create or destroy the XP bar NUI for oPC.
void ShowOrHideXPBarUI(object oPC);



// ------------------ INTERNAL FUNCTIONS ----------------

// Courtesy of Sherincall (clippy) from discord
int Round(float f) { return FloatToInt(f +  (f > 0.0 ? 0.5 : -0.5) ); }


// removes trailing zeros, supports up to two places
string RemoveTrailingZeros(string sString);
string RemoveTrailingZeros(string sString)
{
    if (sString == "") return "";

    int nSize = GetStringLength(sString);

    string sLast = GetStringRight(sString, 3);

// there is probably a better way to do this function intelligently
    if (sLast == ".00")
    {
        return GetStringLeft(sString, nSize - 3);
    }
    else if (sLast == ".90" ||
             sLast == ".80" ||
             sLast == ".70" ||
             sLast == ".60" ||
             sLast == ".50" ||
             sLast == ".40" ||
             sLast == ".30" ||
             sLast == ".20" ||
             sLast == ".10")
    {
        return GetStringLeft(sString, nSize - 1);
    }

// just return the string it was given, no change
    return sString;
}

// truncates to two decimal points
float Truncate(float fFloat);
float Truncate(float fFloat)
{
    return StringToFloat(FloatToString(fFloat, 3, 2));
}

void GiveXPToPC(object oPC, float fXpAmount, int bQuest = FALSE, string sSource = "")
{
// Dead PCs do not get any XP, unless it came from a quest
   if (!bQuest && GetIsDead(oPC)) return;

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
   string sWisdomFeedback = NeatFloatToString(100.0*fWisdom);

// calculate total bonus
   float fModifier = fFavoredModifier + fWisdom;

// cap
   if (fModifier > 1.5) fModifier = 1.5;

// for favored racial class with non humans/half-elves
   if (sFavoredBonus == "" && fFavoredModifier == FAVORED_BONUS) sFavoredBonus = ", Favored class: 20%";

   float fRestedProportion = bQuest ? RESTEDXP_QUEST_INCREASE : RESTEDXP_KILL_INCREASE;
   float fPreRestAdjusted = fModifier * fXpAmount;
   float fAdjustedXpAmount = GetRestModifiedExperience(fPreRestAdjusted, oPC, fRestedProportion);
   string sRestedBonus = "";
   if (fAdjustedXpAmount > fPreRestAdjusted)
   {
      sRestedBonus = " (+" + NeatFloatToString(fAdjustedXpAmount - fPreRestAdjusted) + " Rested Bonus)";
   }

   if (bQuest)
   {
      int nTotal = FloatToInt(fAdjustedXpAmount - fXpAmount);

      string sBonus = "Bonus";
      if (nTotal < 0) sBonus = "Penalty";

      FloatingTextStringOnCreature("*XP "+sBonus+": "+IntToString(nTotal)+" (Wisdom: "+sWisdomFeedback+"%"+sFavoredBonus+")*", oPC, FALSE);
   }

   SendDebugMessage("fAdjustedXP without truncation: "+FloatToString(fAdjustedXpAmount));

// truncate
   //fAdjustedXpAmount = IntToFloat(FloatToInt(fAdjustedXpAmount*10.0))/10.0;
   fAdjustedXpAmount = Truncate(fAdjustedXpAmount);

   string sSourceFeedback = "";
   if (sSource != "")
   {
        sSourceFeedback = " from "+sSource;
   }

   SendMessageToPC(oPC, "Experience Points Gained"+sSourceFeedback+":  "+RemoveTrailingZeros(FloatToString(fAdjustedXpAmount, 3, 2)) + sRestedBonus);


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

   UpdateXPBarUI(oPC);
}

void GiveQuestXPToPC(object oPC, int nTier, int nLevel, int bBluff = FALSE)
{
   if (nTier == 0 || nLevel == 0) return;

   float fXP = 0.0;
   float fMod = 1.0;
   int nPCLevel = GetLevelFromXP(GetXP(oPC));
   int nAdjust = nLevel - nPCLevel;
   float fAdjust = IntToFloat(nAdjust) * QUEST_XP_LEVEL_ADJUSTMENT_MODIFIER;

// being over level reduces XP more significantly, by double
// i.e. if you are level 5 and complete a lvl 4 quest, you get 20% less XP
   if (fAdjust < 0.0) fAdjust = fAdjust * 2.0;

   fMod = fMod + fAdjust;

// capped at 20% xp
   if (fMod < 0.2) fMod = 0.2;
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
    int bBoss = GetLocalInt(oCreature, "boss");
    int bSemiBoss = GetLocalInt(oCreature, "semiboss");
    int bRare = GetLocalInt(oCreature, "rare");
    float fMultiplier = 1.0;
    if (bBoss == 1)
    {
        fMultiplier *= 3.0;
    }
    else if (bSemiBoss == 1 || bRare == 1)
    {
        fMultiplier *= 2.0;
    }
// If the CR is 0.0, then assume this is not a kill and do not do any XP related thingies.
   float fCR = GetChallengeRating(oCreature);

// if tagged no xp just return 0 early
   if (GetLocalInt(oCreature, "no_xp") == 1) return 0.0;

   if (fAverageLevel < 1.0) fAverageLevel = 1.0; //failsafe if party average level was 0 or less

   float fXP = BASE_XP;

   if (fCR > fAverageLevel)
   {
        fXP = fmin(100.0, BASE_XP * pow(2.0, (fCR - fAverageLevel)/5.0));
   }
   else if (fCR < fAverageLevel)
   {
        fXP = fmin(100.0, BASE_XP * pow(2.0, (fCR - fAverageLevel)/2.0));
   }

   // apply any boss multipliers, etc
   fXP = fXP * fMultiplier;

// award more XP if the enemy is a caster or can summon pets
   if (GetLevelByClass(CLASS_TYPE_DRUID, oCreature) >= 1 || GetLevelByClass(CLASS_TYPE_SORCERER, oCreature) > 1 || GetLevelByClass(CLASS_TYPE_WIZARD, oCreature) >= 1 || GetLevelByClass(CLASS_TYPE_CLERIC, oCreature) > 1 || GetLevelByClass(CLASS_TYPE_RANGER, oCreature) >= 6 )
        fXP = fXP * 1.25;

   // Cap the xp.
   if (fXP > XP_MAX) fXP = XP_MAX;

   if (fXP > 0.0)
   {
// ambushes only give 1/3 xp
       if (bAmbush) fXP = fXP/3.0;

       float fTotalSize = IntToFloat(iTotalSize);
       if (fTotalSize < 1.0) fTotalSize = 1.0; //failsafe if party total size was 0 or less

       float fPartyMod = PARTY_SIZE_BASE_MOD/(PARTY_SIZE_BASE_MOD-1.0+fTotalSize);

       if (fPartyMod > 1.0) fPartyMod = 1.0; //failsafe if party mod is greater than 1

       //SendDebugMessage("Party XP mod: "+FloatToString(fPartyMod));
       //SendDebugMessage("fXP penalty mod: "+FloatToString(fXPPenaltyMod));
       //SendDebugMessage("fCR: "+FloatToString(fCR));
       //SendDebugMessage("fXP: "+FloatToString(fXP));

       fXP = fXP * fPartyMod;
   }

   if (fXP == 0.0) return 0.0;

   if (fXP < 0.01) return 0.01;

   //SendDebugMessage("fXP (modified by average level and party): "+FloatToString(fXP));
   return fXP;
}
//------------------------------  END INTERNAL FUNCTIONS  -----------------------------------



// ********************************  DEFINITIONS  ******************************************



void XPBar(object oPC)
{
    string sKey = GetPCPublicCDKey(oPC, TRUE);
    int nSetting = GetCampaignInt(sKey, "option_pc_xpbar");
    if (nSetting < 1)
    {
        return;
    }

    string sWindow = "pc_xpbar";
    json jLabels = JsonArray();
    jLabels = JsonArrayInsert(jLabels, JsonString("Horizontal"));
    jLabels = JsonArrayInsert(jLabels, JsonString("Vertical"));
    json jValues = JsonArray();
    jValues = JsonArrayInsert(jValues, JsonInt(0));
    jValues = JsonArrayInsert(jValues, JsonInt(1));
    // Config first.
    AddInterfaceConfigOptionFineMovement(sWindow, 200, 200, 400, 20);
    AddInterfaceConfigOptionDropdown(sWindow, "orientation", "Orientation", "Whether the bar should be horizontal (fills left to right) or vertical (fills bottom to top).", jLabels, jValues, 0);
    AddInterfaceConfigOptionColorPick(sWindow, "backgroundcolor", "Background Color", "The color of the background, or \"empty\" parts of the bar.", NuiColor(0, 0, 0, 255));
    AddInterfaceConfigOptionColorPick(sWindow, "progresscolor", "Progress Color", "The color of the gained XP progress, or \"filled\" parts of the bar.", NuiColor(75, 220, 120, 255));
    AddInterfaceConfigOptionColorPick(sWindow, "restedcolor", "Rested XP Color", "The color of the your Rested XP potential.", NuiColor(0, 50, 0, 255));
    AddInterfaceConfigOptionColorPick(sWindow, "edgecolor", "Edge Color", "The color of the edges of the bar.", NuiColor(0, 0, 0, 255));
    AddInterfaceConfigOptionTextEntry(sWindow, "numgraduations", "Num Graduations", "The number of graduation marks along the bar.", "9");
    AddInterfaceConfigOptionColorPick(sWindow, "graduationcolor", "Graduation Color", "The color of the graduation marks along the bar.", NuiColor(20, 20, 20, 255));
    AddInterfaceConfigOptionCheckBox(sWindow, "textvisible", "Progress Text", "Whether to show progress percent on the middle of the bar.", 1);
    AddInterfaceConfigOptionColorPick(sWindow, "textcolor", "Progress Text Color", "Color of the progress text on the bar.", NuiColor(100, 100, 100, 255));

    json jBackgroundColor = GetNuiConfigBind(sWindow, "backgroundcolor");
    json jFilledColor = GetNuiConfigBind(sWindow, "progresscolor");
    json jRestedColor = GetNuiConfigBind(sWindow, "restedcolor");
    json jEdgeColor = GetNuiConfigBind(sWindow, "edgecolor");
    json jGraduationColor = GetNuiConfigBind(sWindow, "graduationcolor");
    json jTextVisible = GetNuiConfigBind(sWindow, "textvisible");
    json jTextColor = GetNuiConfigBind(sWindow, "textcolor");

    // The bar itself is a few components, drawn on top of each other.

    // 1) Background.
    // 2) Filled
    // 3) Rested
    // 4) Graduation
    // 5) Edge

    // We do graduation before edge so everything except the "teeth" can be squished by the edge
    // If edge was afterwards it would have to be a long series of drawlists, which binds can't really change
    // Making it one big drawlist and then covering it up later gets around that

    json jBackgroundDrawListCoords = NuiBind("background_coords");
    //json jBackgroundDrawList = NuiDrawListPolyLine(JsonBool(1), jBackgroundColor, JsonBool(1), JsonFloat(1.0), jBackgroundDrawListCoords);
    json jBackgroundDrawList = NuiDrawListPolyLine(JsonBool(1), jBackgroundColor, JsonBool(1), JsonFloat(1.0), jBackgroundDrawListCoords);

    json jFilledDrawListCoords = NuiBind("filled_coords");
    json jFilledDrawList = NuiDrawListPolyLine(JsonBool(1), jFilledColor, JsonBool(1), JsonFloat(1.0), jFilledDrawListCoords);

    json jRestedDrawListCoords = NuiBind("rested_coords");
    json jRestedDrawList = NuiDrawListPolyLine(JsonBool(1), jRestedColor, JsonBool(1), JsonFloat(1.0), jRestedDrawListCoords);

    json jGraduationDrawListCoords = NuiBind("graduation_coords");
    json jGraduationDrawList = NuiDrawListPolyLine(JsonBool(1), jGraduationColor, JsonBool(0), JsonFloat(1.0), jGraduationDrawListCoords);

    json jEdgeDrawListCoords = NuiBind("edge_coords");
    json jEdgeDrawList = NuiDrawListPolyLine(JsonBool(1), jEdgeColor, JsonBool(0), JsonFloat(1.0), jEdgeDrawListCoords);

    json jTextPos = NuiBind("text_pos");
    json jTextContent = NuiBind("text_content");
    json jTextDrawList = NuiDrawListText(jTextVisible, jTextColor, jTextPos, jTextContent);

    json jDrawListArray = JsonArray();
    jDrawListArray = JsonArrayInsert(jDrawListArray, jBackgroundDrawList);
    jDrawListArray = JsonArrayInsert(jDrawListArray, jFilledDrawList);
    jDrawListArray = JsonArrayInsert(jDrawListArray, jRestedDrawList);
    jDrawListArray = JsonArrayInsert(jDrawListArray, jGraduationDrawList);
    jDrawListArray = JsonArrayInsert(jDrawListArray, jEdgeDrawList);



    jDrawListArray = JsonArrayInsert(jDrawListArray, jTextDrawList);

    float fWinSizeX = 400.0;
    float fWinSizeY = 40.0;

    float fMidX = IntToFloat(GetPlayerDeviceProperty(oPC, PLAYER_DEVICE_PROPERTY_GUI_WIDTH)/2) - (fWinSizeX/2);
    float fMidY = IntToFloat(GetPlayerDeviceProperty(oPC, PLAYER_DEVICE_PROPERTY_GUI_HEIGHT))*0.8 - (fWinSizeY/2);

    json jGeometry = GetPersistentWindowGeometryBind(oPC, sWindow, NuiRect(fMidX, fMidY, fWinSizeX, fWinSizeY));

    json jLabel = NuiLabel(JsonString(""), JsonInt(NUI_HALIGN_CENTER), JsonInt(NUI_VALIGN_MIDDLE));
    jLabel = NuiDrawList(jLabel, JsonBool(0), jDrawListArray);

    json jLayout = JsonArray();
    jLayout = JsonArrayInsert(jLayout, jLabel);

    json jRoot = NuiRow(jLayout);

    json jNui = EditableNuiWindow(sWindow, "XP Bar", jRoot, "", jGeometry, 0, 0, 0, JsonBool(1), JsonBool(0));
    //json jNui = NuiWindow(jRoot, JsonBool(FALSE), jGeometry, JsonBool(0), JsonBool(0), JsonBool(0), JsonBool(0), JsonBool(0));

    int nToken = NuiCreate(oPC, jNui, sWindow);
    // This thing wants to be much too small for this crude stuff
    SetIsInterfaceConfigurable(oPC, nToken, 0, 0);
    LoadNuiConfigBinds(oPC, nToken);


    // The event script can calculate all the drawlist coordinates...
    SetScriptParam("init", "init");
    SetScriptParam("pc", ObjectToString(oPC));
    SetScriptParam("token", IntToString(nToken));
    SetScriptParam("updatebar", "1");
    ExecuteScript("pc_xpbar_evt", OBJECT_SELF);
}


void ShowOrHideXPBarUI(object oPC)
{
    int nNewValue = GetCampaignInt(GetPCPublicCDKey(oPC, TRUE), "option_pc_xpbar");
    // We might need to hide it
    if (nNewValue == 0)
    {
        NuiDestroy(oPC, NuiFindWindow(oPC, "pc_xpbar"));
    }
    // We might need to show it
    else if (nNewValue == 1)
    {
        XPBar(oPC);
    }
}

void UpdateXPBarUI(object oPC)
{
    int nToken = NuiFindWindow(oPC, "pc_xpbar");
    if (nToken != 0)
    {
        SetScriptParam("pc", ObjectToString(oPC));
        SetScriptParam("token", IntToString(nToken));
        SetScriptParam("updatebar", "1");
        ExecuteScript("pc_xpbar_evt", OBJECT_SELF);
    }
}

void GiveDialogueSkillXP(object oPC, int nDC, int nSkill)
{
// OBJECT_SELF is probably going to be NPC speaker in most circumstances
    string sIdentifier = "dlg_"+IntToString(nSkill)+"_xp_"+GetName(oPC) + GetPCPublicCDKey(oPC);

    // this cannot be awarded again until reset
    if (GetLocalInt(OBJECT_SELF, sIdentifier) == 1) return;


    SetLocalInt(OBJECT_SELF, sIdentifier, 1);
    DelayCommand(1800.0, DeleteLocalInt(OBJECT_SELF, sIdentifier)); // reset in 30 minutes

    float fXP = IntToFloat(nDC) / 2.5;

    if (fXP > 16.0) fXP = 16.0;
    if (fXP < 3.0) fXP = 3.0;

    string sSkill;
    switch (nSkill)
    {
        case SKILL_PERSUADE: sSkill = "Persuasion"; break;
        case SKILL_BLUFF: sSkill = "Bluffing"; break;
        case SKILL_INTIMIDATE: sSkill = "Intimidation"; break;
    }

    GiveXPToPC(oPC, fXP, FALSE, sSkill);
}

void GiveUnlockXP(object oPC, int nDC)
{
    float fXP = IntToFloat(nDC) / 3.0;

// cap
    if (fXP > 14.0) fXP = 14.0;

    GiveXPToPC(oPC, fXP, FALSE, "Unlocking");
}
//void main(){}
