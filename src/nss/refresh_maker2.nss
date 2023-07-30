#include "inc_trap"
#include "inc_loot"
#include "inc_ctoken"
#include "nwnx_creature"
#include "nwnx_object"
#include "nwnx_visibility"

void TrapAtWaypoint(object oTest)
{
    int nTrap = DetermineTrap(20);
    //object oTrap = CreateTrapAtLocation(nTrap, GetLocation(oTest), 2.5, "", STANDARD_FACTION_HOSTILE, "on_trap_disarm");
    object oTrap = CreateTrapAtLocation(nTrap, GetLocation(oTest), 5.0, "", STANDARD_FACTION_HOSTILE, "on_trap_disarm");
    SetLocalInt(oTrap, "octagon_trap", 1);
}

void MakeDuergarCorpse(object oTest, string sResRef)
{
    // if someone spams refresh twice in succession, this will be delayed twice and spawn a duplicate corpse
    // if that happened, destroy the old one again
    object oDeadDuergar = GetLocalObject(oTest, "corpse");
    AssignCommand(oDeadDuergar, SetIsDestroyable(TRUE, FALSE, FALSE));
    DestroyObject(oDeadDuergar);
    
    object oDuergar = CreateObject(OBJECT_TYPE_CREATURE, sResRef, GetLocation(oTest));
    ExecuteScript("ai_onspawn", oDuergar);
    SetLocalInt(oDuergar, "no_credit", 1);
    AssignCommand(oDuergar, SetIsDestroyable(FALSE, FALSE, FALSE));
    NWNX_Creature_SetCorpseDecayTime(oDuergar, 32000);
    DelayCommand(0.0, ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(GetMaxHitPoints(oDuergar)), oDuergar)) ;
    SetLocalObject(oTest, "corpse", oDuergar);
}

void MakeGroundItem(object oTest)
{
    object oChestItem = SelectTierItem(12, 12, "Melee", 0, OBJECT_INVALID, d100() < 5 ? FALSE : TRUE);
    location lLoc = GetLocation(oTest);
    lLoc = Location(GetAreaFromLocation(lLoc), GetPositionFromLocation(lLoc), IntToFloat(Random(360)));
    object oFloorItem = CopyTierItemToObjectOrLocation(oChestItem, OBJECT_INVALID, GetLocation(oTest));
    SetLocalObject(oTest, "ground_weapon", oFloorItem);
}

void main()
{
    // Patrolling golems!
    int i;
    int nScavengerPos = Random(5) + 1;
    for (i=1; i<=5; i++)
    {
        object oGolem = GetLocalObject(OBJECT_SELF, "patrolling_" + IntToString(i));
        SetPlotFlag(oGolem, FALSE);
        DestroyObject(oGolem);
        string sResRef;
        if (i == nScavengerPos)
        {
            sResRef = "maker2_scav";
        }
        else
        {
            int nRoll = d100();
            if (nRoll < 80)
            {
                // Iron golem
                sResRef = "irongolem";
            }
            else if (nRoll < 90)
            {
                // Stone golem
                sResRef = "golem_stone_reg";
            }
            else
            {
                // Clay golem
                sResRef = "golem_clay_reg";
            }
        }
        string sWP = "WP_q4b_scavenger_";
        sWP = sWP + (i < 4 ? "0" : "") + IntToString(i*3);
        object oWP = GetWaypointByTag(sWP);
        oGolem = CreateObject(OBJECT_TYPE_CREATURE, sResRef, GetLocation(oWP));
        SetLocalObject(OBJECT_SELF, "patrolling_" + IntToString(i), oGolem);
        if (i == nScavengerPos)
        {
            SetLocalObject(OBJECT_SELF, "scavenger", oGolem);
            SetPlotFlag(oGolem, TRUE);
        }
        SetLocalInt(oGolem, "patrolwaypoint", i*3);
        SetLocalInt(oGolem, "patrolgolem", 1);
        SetLocalInt(oGolem, "no_wander", 1);
        // These stop elemental deaths happening which will mess with the corpse
        // and make it unraisable
        SetLocalInt(oGolem, "no_elem_death", 1);
        SetLocalInt(oGolem, "gibbed", 1);
        // Make sure they can be resurrected for a while
        NWNX_Creature_SetCorpseDecayTime(oGolem, 600);
    }
    object oWPOctagon = GetWaypointByTag("maker2_trap_mid");
    location lOctagon = GetLocation(oWPOctagon);
    // Upgrade the four trap chests to boss level
    object oTest = GetFirstObjectInShape(SHAPE_SPHERE, 10.0, lOctagon, FALSE, OBJECT_TYPE_PLACEABLE);
    while (GetIsObjectValid(oTest))
    {
        if (GetLocalString(oTest, "treasure") == "high")
        {
            if (d100() < 5)
            {
                SetLocalInt(oTest, "boss", 1);
            }
        }
        oTest = GetNextObjectInShape(SHAPE_SPHERE, 10.0, lOctagon, FALSE, OBJECT_TYPE_PLACEABLE);
    }
    // Delete/respawn eight traps around the four big treasures
    // Also, keep count of how many lever spawns there are
    int nLeverSpawns = 0;
    oTest = GetFirstObjectInShape(SHAPE_SPHERE, 25.0, lOctagon, FALSE, OBJECT_TYPE_TRIGGER | OBJECT_TYPE_WAYPOINT);
    while (GetIsObjectValid(oTest))
    {
        if (GetObjectType(oTest) == OBJECT_TYPE_TRIGGER && GetLocalInt(oTest, "octagon_trap"))
        {
            DestroyObject(oTest);
        }
        else if (GetObjectType(oTest) == OBJECT_TYPE_WAYPOINT && GetTag(oTest) == "maker2_trap")
        {
            // Doing this in the loop causes TMI
            //DelayCommand(6.0, TrapAtWaypoint(oTest));
            DelayCommand(6.0, TrapAtWaypoint(oWPOctagon));
        }
        else if (GetObjectType(oTest) == OBJECT_TYPE_WAYPOINT && GetTag(oTest) == "maker2_traplever")
        {
            nLeverSpawns++;
        }
        oTest = GetNextObjectInShape(SHAPE_SPHERE, 25.0, lOctagon, FALSE, OBJECT_TYPE_TRIGGER | OBJECT_TYPE_WAYPOINT);
    }
    // Spawn a lever at one of them
    DestroyObject(GetLocalObject(OBJECT_SELF, "hidden_lever"));
    int nLeverSpawnIndex = Random(nLeverSpawns);
    oTest = GetFirstObjectInShape(SHAPE_SPHERE, 25.0, lOctagon, FALSE, OBJECT_TYPE_WAYPOINT);
    while (GetIsObjectValid(oTest))
    {
        if (GetTag(oTest) == "maker2_traplever")
        {
            nLeverSpawnIndex--;
            if (nLeverSpawnIndex < 0)
            {
                object oLever = CreateObject(OBJECT_TYPE_PLACEABLE, "hidden_lever", GetLocation(oTest));
                SetLocalObject(OBJECT_SELF, "hidden_lever", oLever);
                SetLocalInt(oLever, "dc", 27);
                SetEventScript(oLever, EVENT_SCRIPT_PLACEABLE_ON_USED, "maker2_leverpull");
                NWNX_Visibility_SetVisibilityOverride(OBJECT_INVALID, oLever, NWNX_VISIBILITY_HIDDEN);
                break;
            }
        }
        oTest = GetNextObjectInShape(SHAPE_SPHERE, 25.0, lOctagon, FALSE, OBJECT_TYPE_WAYPOINT);
    }

    // Look over all waypoints.
    // Replace dead duergar and spawn random weapons
    oTest = GetFirstObjectInArea(OBJECT_SELF);
    while (GetIsObjectValid(oTest))
    {
        if (GetObjectType(oTest) == OBJECT_TYPE_WAYPOINT)
        {
            string sTag = GetTag(oTest);
            if (sTag == "dead_duegar")
            {
                object oDeadDuergar = GetLocalObject(oTest, "corpse");
                AssignCommand(oDeadDuergar, SetIsDestroyable(TRUE, FALSE, FALSE));
                DestroyObject(oDeadDuergar);
                string sResRef;
                int nRoll = d100();
                if (nRoll < 45)
                {
                    sResRef = "duergar_warrior";
                }
                else if (nRoll < 90)
                {
                    sResRef = "duergar_skirmish";
                }
                else
                {
                    sResRef = "duergar_wizard";
                }
                DelayCommand(0.1, MakeDuergarCorpse(oTest, sResRef));
                
            }
            else if (sTag == "maker_spawn_rand_weapon")
            {
                object oOldItem = GetLocalObject(oTest, "ground_weapon");
                // Don't remove items that are in an inventory!
                // apparently player to player barters are also invalid possessor, so check the area too
                if (!GetIsObjectValid(GetItemPossessor(oOldItem)) && GetAreaFromLocation(GetLocation(oOldItem)) == OBJECT_SELF)
                {
                    DestroyObject(oOldItem);
                }
            }
        }
        oTest = GetNextObjectInArea(OBJECT_SELF);
    }
    
    // Active bookcases are done in clean_maker2 now
    
    // Randomise the ten arcane words onto the numbers
    json jWords = JsonArray();
    jWords = JsonArrayInsert(jWords, JsonString("Omon"));
    jWords = JsonArrayInsert(jWords, JsonString("Arthas"));
    jWords = JsonArrayInsert(jWords, JsonString("Kinthas"));
    jWords = JsonArrayInsert(jWords, JsonString("Ivon"));
    jWords = JsonArrayInsert(jWords, JsonString("Thesti"));
    jWords = JsonArrayInsert(jWords, JsonString("Sinth"));
    jWords = JsonArrayInsert(jWords, JsonString("Kali"));
    jWords = JsonArrayInsert(jWords, JsonString("Laz"));
    jWords = JsonArrayInsert(jWords, JsonString("Urvil"));
    jWords = JsonArrayInsert(jWords, JsonString("Zand"));
    jWords = JsonArrayTransform(jWords, JSON_ARRAY_SHUFFLE);
    string sExtraDescription = "\n\n";
    for (i=0; i<=9; i++)
    {
        string sWord = JsonGetString(JsonArrayGet(jWords, i));
        SetLocalString(OBJECT_SELF, "word_" + IntToString(i), sWord);
        sExtraDescription += sWord + " = " + IntToString(i) + "\n";        
    }
    // Update the translation note
    object oNote = GetObjectByTag("maker2_solution_note");
    SetDescription(oNote, "");
    SetDescription(oNote, GetDescription(oNote) + sExtraDescription);
    
    // Pick two (different) IDs for the two notable golems
    int nScavengerID = Random(100);
    int nGuardianID;
    do
    {
        nGuardianID = Random(100);
    }
    while (nGuardianID == nScavengerID);
        
    SetLocalInt(OBJECT_SELF, "scavenger_id", nScavengerID);
    SetLocalInt(OBJECT_SELF, "guardian_id", nGuardianID);
    
    // Randomise the initial numbers on the console
    SetLocalInt(OBJECT_SELF, "digit_left", Random(10));
    SetLocalInt(OBJECT_SELF, "digit_right", Random(10));
    
    // Reset console damage buildup
    SetLocalInt(GetObjectByTag("q4b_action_lever"), "last_damage", 20);
    
    
}
