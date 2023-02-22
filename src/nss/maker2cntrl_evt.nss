#include "nw_inc_nui"
#include "inc_sqlite_time"
#include "nwnx_object"
#include "nwnx_creature"

// Distances between the point we start drawing and the edges of the parent
const float DIGIT_PADDING_X = 25.0;
const float DIGIT_PADDING_Y = 25.0;

// The width of the whole parent, the paddings are subtracted from each side
// to give the final draw area
const float DIGIT_WIDTH = 150.0;
const float DIGIT_HEIGHT = 200.0;

// If the parent is DIGIT_WIDTH wide
// The leftmost pixel to draw is DIGIT_PADDING_X
// The rightmost pixel to draw is DIGIT_WIDTH - DIGIT_PADDING_X

void UpdateDigit(object oPC, int nToken, string sSide);

void main()
{
    object oPC = NuiGetEventPlayer();
    string sEvent = NuiGetEventType();
    int nToken = NuiGetEventWindow();
    string sElement = NuiGetEventElement();
    
    // This is also called by ExecuteScript when the window is opened
    // which passes the things via script param instead
    // this means the number drawing code can be contained to this one file
    string sInit = GetScriptParam("init");
    if (sInit != "")
    {
        oPC = StringToObject(GetScriptParam("pc"));
        nToken = StringToInt(GetScriptParam("token"));
        UpdateDigit(oPC, nToken, "left");
        UpdateDigit(oPC, nToken, "right");
        return;
    }
    
    object oArea = GetObjectByTag("ud_maker2");
    object oControl = GetObjectByTag("q4b_action_lever");
    if (GetArea(oPC) != oArea || GetDistanceBetween(oPC, oControl) > 7.0)
    {
        SendMessageToPC(oPC, "You are too far away to use the machine.");
        NuiDestroy(oPC, nToken);
        return;
    }
    
    
    if (sElement == "firstplus" && sEvent == "click")
    {
        int nDigit = GetLocalInt(oArea, "digit_left");
        nDigit++;
        nDigit = nDigit % 10;
        SetLocalInt(oArea, "digit_left", nDigit);
        UpdateDigit(oPC, nToken, "left");
    }
    else if (sElement == "firstminus" && sEvent == "click")
    {
        int nDigit = GetLocalInt(oArea, "digit_left");
        nDigit--;
        if (nDigit < 0) { nDigit = 9; }
        SetLocalInt(oArea, "digit_left", nDigit);
        UpdateDigit(oPC, nToken, "left");
    }
    else if (sElement == "secondplus" && sEvent == "click")
    {
        int nDigit = GetLocalInt(oArea, "digit_right");
        nDigit++;
        nDigit = nDigit % 10;
        SetLocalInt(oArea, "digit_right", nDigit);
        UpdateDigit(oPC, nToken, "right");
    }
    else if (sElement == "secondminus" && sEvent == "click")
    {
        int nDigit = GetLocalInt(oArea, "digit_right");
        nDigit--;
        if (nDigit < 0) { nDigit = 9; }
        SetLocalInt(oArea, "digit_right", nDigit);
        UpdateDigit(oPC, nToken, "right");
    }
    else if (sElement == "action" && sEvent == "click")
    {
        // Does the input match the id of anything?
        int nEnteredID = GetLocalInt(oArea, "digit_left") * 10 + GetLocalInt(oArea, "digit_right");
        int nScavID = GetLocalInt(oArea, "scavenger_id");
        int nGuardID = GetLocalInt(oArea, "guardian_id");
        
        object oRightBeamSource = GetObjectByTag("maker2_controlR");
        object oLeftBeamSource = GetObjectByTag("maker2_controlL");
        
        object oGolemTarget = OBJECT_INVALID;        
        if (nEnteredID == nScavID)
        {
            oGolemTarget = GetLocalObject(oArea, "scavenger");
        }
        if (nEnteredID == nGuardID)
        {
            oGolemTarget = GetObjectByTag("maker2_guardian");
        }
        
        // if a golem is bound, either destroy or release it
        object oBound = GetLocalObject(oControl, "golem_bound");
        if (GetIsObjectValid(oBound) && !GetIsDead(oBound))
        {
            // No matter what, remove all beam effects from golem
            effect eTest = GetFirstEffect(oBound);
            while (GetIsEffectValid(eTest))
            {
                if (GetEffectType(eTest) == EFFECT_TYPE_BEAM)
                {
                    DelayCommand(0.0, RemoveEffect(oBound, eTest));
                }
                else if (GetEffectType(eTest) == EFFECT_TYPE_CUTSCENE_PARALYZE)
                {
                    DelayCommand(0.0, RemoveEffect(oBound, eTest));
                }
                else if (GetEffectType(eTest) == EFFECT_TYPE_CUTSCENEIMMOBILIZE)
                {
                    DelayCommand(0.0, RemoveEffect(oBound, eTest));
                }
                eTest = GetNextEffect(oBound);
            }
            
            if (oGolemTarget == oBound)
            {
                // Destruction time.
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectBeam(VFX_BEAM_LIGHTNING, oLeftBeamSource, BODY_NODE_CHEST), oGolemTarget, 6.0);
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectBeam(VFX_BEAM_LIGHTNING, oRightBeamSource, BODY_NODE_CHEST), oGolemTarget, 6.0);
                SetPlotFlag(oGolemTarget, FALSE);
                AssignCommand(oGolemTarget, SetCommandable(TRUE));
                AssignCommand(oGolemTarget, ActionPlayAnimation(ANIMATION_LOOPING_SPASM, 1.0, 6.0));
                AssignCommand(oGolemTarget, SetCommandable(FALSE));
                ChangeToStandardFaction(oBound, STANDARD_FACTION_HOSTILE);
                ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_LIGHTNING_S), oGolemTarget);
                ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectCutsceneParalyze(), oGolemTarget);
                ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectCutsceneImmobilize(), oGolemTarget);
                ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectMissChance(100), oGolemTarget);
                DeleteLocalInt(oGolemTarget, "defeated_webhook");
                DeleteLocalInt(oGolemTarget, "no_elem_death");
                DelayCommand(3.0, AssignCommand(oPC, ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(GetCurrentHitPoints(oGolemTarget) + d6(3), DAMAGE_TYPE_ELECTRICAL), oGolemTarget)));
                DelayCommand(3.0, ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_ELECTRIC_EXPLOSION, FALSE, 0.3), oGolemTarget));
                NuiDestroy(oPC, nToken);
                return;
            }
            else
            {
                // Release it
                ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_UNSUMMON), GetLocation(oBound));
                ChangeToStandardFaction(oBound, STANDARD_FACTION_HOSTILE);
                location lSpawn = GetLocalLocation(oBound, "spawn");
                AssignCommand(oGolemTarget, SetCommandable(TRUE));
                AssignCommand(oBound, JumpToLocation(lSpawn));
                ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_SUMMON_MONSTER_3), lSpawn);
                DeleteLocalObject(oControl, "golem_bound");
                NuiDestroy(oPC, nToken);
                return;
            }
        }
        
        if (GetIsObjectValid(oGolemTarget) && !GetIsDead(oGolemTarget))
        {
            // Teleport the golem in
            object oWP = GetWaypointByTag("q4b_wp_golem_summon");
            AssignCommand(oGolemTarget, SetCommandable(TRUE));
            AssignCommand(oGolemTarget, ClearAllActions());
            vector vJump = NWNX_Creature_ComputeSafeLocation(oGolemTarget, GetPosition(oWP));
            location lJump = Location(GetArea(oWP), vJump, GetFacing(oWP));
            AssignCommand(oGolemTarget, JumpToLocation(lJump));
            ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_UNSUMMON), GetLocation(oGolemTarget));
            ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_SUMMON_MONSTER_3), GetLocation(oWP));
            ChangeToStandardFaction(oGolemTarget, STANDARD_FACTION_MERCHANT);
            ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectCutsceneParalyze(), oGolemTarget);
            ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectCutsceneImmobilize(), oGolemTarget);
            ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(VFX_BEAM_DISINTEGRATE, oLeftBeamSource, BODY_NODE_CHEST), oGolemTarget);
            ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(VFX_BEAM_DISINTEGRATE, oRightBeamSource, BODY_NODE_CHEST), oGolemTarget);
            SetLocalObject(oControl, "golem_bound", oGolemTarget);
            return;
        }
        
        
        // If there was nothing bound and nothing was teleported, damage the player
        
        if (GetIsDead(oGolemTarget) || !GetIsObjectValid(oGolemTarget))
        {
            // Shock the PC who put in the wrong ID
            int nLastDamage = GetLocalInt(oControl, "last_damage");
            int nLastDamageTime = GetLocalInt(oControl, "last_damage_time");
            int nNow = SQLite_GetTimeStamp();
            // Accumulated damage decays by 1 periodically
            int nDiff = (nNow - nLastDamageTime)/3;
            nLastDamage -= nDiff;
            // Do 30% more damage each time
            nLastDamage += (nLastDamage*3)/10;
            if (nLastDamage < 20)
            {
                nLastDamage = 20;
            }
            SetLocalInt(oControl, "last_damage", nLastDamage);
            SetLocalInt(oControl, "last_damage_time", nNow);
            int nRealDamage = nLastDamage + d6(3);
            AssignCommand(oControl, ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(nRealDamage, DAMAGE_TYPE_ELECTRICAL), oPC));
            SendMessageToPC(oPC, "Pushing the button makes the machinery react violently.");
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectBeam(VFX_BEAM_LIGHTNING, oLeftBeamSource, BODY_NODE_CHEST), oPC, 3.0);
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectBeam(VFX_BEAM_LIGHTNING, oRightBeamSource, BODY_NODE_CHEST), oPC, 3.0);
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_LIGHTNING_S), oPC);
            NuiDestroy(oPC, nToken);
            return;
        }
        
    }
    
}


void UpdateDigit(object oPC, int nToken, string sSide)
{
    // sSide is one of "left", "right"
    object oArea = GetObjectByTag("ud_maker2");
    int nDigit = GetLocalInt(oArea, "digit_" + sSide);
    json jCoords = JsonArray();
    
    float fLeft = DIGIT_PADDING_X;
    float fRight = DIGIT_WIDTH - DIGIT_PADDING_X;
    float fTop = DIGIT_PADDING_Y;
    float fBottom = DIGIT_HEIGHT - DIGIT_PADDING_Y;
    
    float fMidX = DIGIT_WIDTH/2.0;
    float fMidY = DIGIT_HEIGHT/2.0;
    
    if (nDigit == 0)
    {
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fLeft));
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fTop));
        
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fRight));
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fTop));
        
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fRight));
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fBottom));
        
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fLeft));
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fBottom));
        
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fLeft));
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fTop));
    }
    else if (nDigit == 1)
    {
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fMidX));
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fTop));
        
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fMidX));
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fBottom));
    }
    else if (nDigit == 2)
    {
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fLeft));
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fTop));
        
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fRight));
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fTop));
        
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fRight));
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fMidY));
        
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fLeft));
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fMidY));
        
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fLeft));
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fBottom));
        
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fRight));
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fBottom));
    }
    else if (nDigit == 3)
    {
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fLeft));
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fTop));
        
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fRight));
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fTop));
        
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fRight));
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fMidY));
        
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fLeft));
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fMidY));
        
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fRight));
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fMidY));
        
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fRight));
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fBottom));
        
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fLeft));
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fBottom));
    }
    else if (nDigit == 4)
    {
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fLeft));
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fTop));
        
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fLeft));
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fMidY));
        
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fRight));
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fMidY));
        
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fRight));
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fTop));
        
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fRight));
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fBottom));
    }
    else if (nDigit == 5)
    {
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fRight));
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fTop));
        
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fLeft));
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fTop));
        
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fLeft));
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fMidY));
        
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fRight));
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fMidY));
        
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fRight));
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fBottom));
        
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fLeft));
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fBottom));
    }
    else if (nDigit == 6)
    {
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fRight));
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fTop));
        
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fLeft));
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fTop));
        
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fLeft));
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fBottom));
        
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fRight));
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fBottom));
        
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fRight));
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fMidY));
        
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fLeft));
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fMidY));
    }
    else if (nDigit == 7)
    {
        
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fLeft));
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fTop));
        
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fRight));
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fTop));
        
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fLeft));
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fBottom));
        
    }
    else if (nDigit == 8)
    {
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fLeft));
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fTop));
        
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fRight));
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fTop));
        
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fRight));
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fBottom));
        
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fLeft));
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fBottom));
        
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fLeft));
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fTop));
        
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fLeft));
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fMidY));
        
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fRight));
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fMidY));
    }
    else if (nDigit == 9)
    {
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fLeft));
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fBottom));
        
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fRight));
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fBottom));
        
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fRight));
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fTop));
        
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fLeft));
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fTop));
        
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fLeft));
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fMidY));
        
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fRight));
        jCoords = JsonArrayInsert(jCoords, JsonFloat(fMidY));
    }
    
    
    NuiSetBind(oPC, nToken, sSide + "drawlist", jCoords);
}