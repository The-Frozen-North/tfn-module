#include "util_i_csvlists"
#include "nwnx_creature"

/*
Maker1: the seer tells you there is an island
Maker2: you have talked to Ferron only
Maker3: you have talked to Aghaaz only
Maker4: you have talked to both
Maker10: you have killed Ferron but not talked to Aghaaz
Maker16: you have killed Ferron after Aghaaz asked you to
Maker19: you have returned Ferron's head to Aghaaz and been promised golems (return to Seer)
Maker20: you have killed Aghaaz but not talked to Ferron
Maker21: you have killed Aghaaz but not talked to Ferron, and found the power source
Maker26: you have killed Aghaaz after Ferron asked you to get the power source
Maker27: you have killed Aghaaz after Ferron asked you and found the power source
Maker29: you have killed Aghaaz and brought it back to Ferron and returned the power source (return to Seer)
Maker50 [complete]: For killing Ferron, Aghaaz has promised golems to aid against Valsharess and you told Seer about it
Maker51 [complete]: For returning the power source, Ferron promised golems to aid against Valsharess and you told Seer about it
*/

string GetRandomFerronGolem()
{
    int nRoll = d100();
    if (nRoll <= 20)
    {
        return "fleshgolemmaker3";
    }
    else if (nRoll <= 60)
    {
        return "bronzegolem";
    }
    return "silvergolem";
}

string GetRandomAghaazGolem()
{
    int nRoll = d100();
    if (nRoll <= 80)
    {
        return "fleshgolemmaker3";
    }
    else if (nRoll <= 90)
    {
        return "bronzegolem";
    }
    return "silvergolem";
}

void DestroyOldCreature(object oWP)
{
    object oOld = GetLocalObject(oWP, "spawned_creature");
    DestroyObject(oOld);
}

void MakeFactionGolem(object oWP, string sResRef, int nFaction, string sAttackScript, string sDialog)
{
    object oOld = GetLocalObject(oWP, "spawned_creature");
    DestroyObject(oOld);
    object oNew = CreateObject(OBJECT_TYPE_CREATURE, sResRef, GetLocation(oWP));
    SetLocalInt(oNew, "no_wander", 1);
    SetLocalObject(oWP, "spawned_creature", oNew);
    NWNX_Creature_SetFaction(oNew, nFaction);
    SetLocalString(oNew, "attack_script", sAttackScript);
    SetLocalString(oNew, "conversation_override", sDialog);
    // These are supposed to be smart.
    // 6+ is also needed for them to respond to calls to attack, which turns out to be quite important
    // with the faction changing stuff
    if (NWNX_Creature_GetRawAbilityScore(oNew, ABILITY_INTELLIGENCE) < 10)
    {
        NWNX_Creature_SetRawAbilityScore(oNew, ABILITY_INTELLIGENCE, 10);
    }
}

void MakeDoorGuard(object oWP, string sResRef, int nFaction, string sAttackScript, string sDialog)
{
    object oOld = GetLocalObject(oWP, "spawned_creature");
    DestroyObject(oOld);
    object oNew = CreateObject(OBJECT_TYPE_CREATURE, sResRef, GetLocation(oWP));
    SetLocalInt(oNew, "no_wander", 1);
    SetLocalObject(oWP, "spawned_creature", oNew);
    NWNX_Creature_SetFaction(oNew, nFaction);
    SetLocalString(oNew, "attack_script", sAttackScript);
    SetLocalString(oNew, "conversation_override", sDialog);
    SetName(oNew, GetName(oNew) + " Guardian");
    if (NWNX_Creature_GetRawAbilityScore(oNew, ABILITY_INTELLIGENCE) < 10)
    {
        NWNX_Creature_SetRawAbilityScore(oNew, ABILITY_INTELLIGENCE, 10);
    }
}

void MakeGolemCorpse(location lLoc, string sResRef, string sVar)
{
    object oDeadDuergar = GetLocalObject(OBJECT_SELF, "corpse" + sVar);
    AssignCommand(oDeadDuergar, SetIsDestroyable(TRUE, FALSE, FALSE));
    DestroyObject(oDeadDuergar);
    if (sResRef != "")
    {
        object oDuergar = CreateObject(OBJECT_TYPE_CREATURE, sResRef, lLoc);
        ExecuteScript("ai_onspawn", oDuergar);
        SetLocalInt(oDuergar, "no_credit", 1);
        AssignCommand(oDuergar, SetIsDestroyable(FALSE, FALSE, FALSE));
        NWNX_Creature_SetCorpseDecayTime(oDuergar, 32000);
        DelayCommand(0.0, ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(GetMaxHitPoints(oDuergar)), oDuergar)) ;
        SetLocalObject(OBJECT_SELF, "corpse" + sVar, oDuergar);
    }
}


void main()
{
    DeleteLocalString(OBJECT_SELF, "pcs_entered");
    
    // The "boss" factions are not instantly hostile towards PCs
    
    int nFerronFaction, nAghaazFaction, nFerronBossFaction, nAghaazBossFaction;
    
    if (GetLocalInt(OBJECT_SELF, "ferron_faction") < 1)
    {
        nFerronBossFaction = NWNX_Creature_GetFaction(GetObjectByTag("maker3_ferron"));
        nAghaazBossFaction = NWNX_Creature_GetFaction(GetObjectByTag("maker3_aghaaz"));
        SetLocalInt(OBJECT_SELF, "ferronboss_faction", nFerronBossFaction);
        SetLocalInt(OBJECT_SELF, "aghaazboss_faction", nAghaazBossFaction);
        object oFerronDummy = CreateObject(OBJECT_TYPE_CREATURE, "ferronfacdummy", GetLocation(GetWaypointByTag("maker3_battleground_mid")));
        nFerronFaction = NWNX_Creature_GetFaction(oFerronDummy);
        DestroyObject(oFerronDummy);
        object oAghaazDummy = CreateObject(OBJECT_TYPE_CREATURE, "aghaazfacdummy", GetLocation(GetWaypointByTag("maker3_battleground_mid")));
        nAghaazFaction = NWNX_Creature_GetFaction(oAghaazDummy);
        DestroyObject(oAghaazDummy);
        SetLocalInt(OBJECT_SELF, "ferron_faction", nFerronFaction);
        SetLocalInt(OBJECT_SELF, "aghaaz_faction", nAghaazFaction);
        
        // Gloignar's visual effects
        object oGhost = GetObjectByTag("maker3_ghost");
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectVisualEffect(VFX_DUR_GHOST_SMOKE_2), oGhost);
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectVisualEffect(VFX_DUR_GHOST_TRANSPARENT), oGhost);
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectCutsceneGhost(), oGhost);
    }
    else
    {
        nFerronFaction = GetLocalInt(OBJECT_SELF, "ferron_faction");
        nAghaazFaction = GetLocalInt(OBJECT_SELF, "aghaaz_faction");
        nFerronBossFaction = GetLocalInt(OBJECT_SELF, "ferronboss_faction");
        nAghaazBossFaction = GetLocalInt(OBJECT_SELF, "aghaazboss_faction");
    }
    
    object oAghaaz = GetObjectByTag("maker3_aghaaz");
    object oFerron = GetObjectByTag("maker3_ferron");
    
    SetLocalString(oAghaaz, "attack_script", "attack_m3bossfac");
    SetLocalString(oFerron, "attack_script", "attack_m3bossfac");
        
    int i, j;
    
    object oTest = GetFirstObjectInArea(OBJECT_SELF);
    while (GetIsObjectValid(oTest))
    {
        if (GetObjectType(oTest) == OBJECT_TYPE_WAYPOINT)
        {
            if (GetTag(oTest) == "maker3_battleground_mid")
            {  
                vector vMid = GetPosition(oTest);
                // +y = aghaaz side, -y = ferron side
                for (i=-1; i<=1; i += 2)
                {                    
                    int nNumSpawns = 3 + d3();
                    for (j=0; j<6; j++)
                    {
                        string sVar = IntToString(i) + "_" + IntToString(j);
                        string sResRef = i > 0 ? GetRandomAghaazGolem() : GetRandomFerronGolem();
                        // Spawn nothing instead, but still clear up the old ones
                        location lLoc;
                        if (j >= nNumSpawns)
                        {
                            sResRef = "";
                        }
                        else
                        {
                            vector vPos;
                            vPos.z = 0.0;
                            vPos.x = IntToFloat(Random(1400))/100.0 - 7.0 + vMid.x;
                            vPos.y = (1.0 + IntToFloat(Random(600))/100.0) * IntToFloat(i) + vMid.y;
                            float fFacing = (i > 0 ? 270.0 : 90.0) + IntToFloat(Random(60)) - 30.0;
                            lLoc = Location(OBJECT_SELF, vPos, fFacing);
                        }
                        DelayCommand(6.0, MakeGolemCorpse(lLoc, sResRef, sVar));
                    }
                }
            }
            else if (GetTag(oTest) == "maker3_aghaazguard_clay")
            {
                DestroyOldCreature(oTest);
                DelayCommand(6.0, MakeFactionGolem(oTest, "golem_clay", nAghaazBossFaction, "attack_m3bossfac", "golemaghaaz"));
            }
            else if (GetTag(oTest) == "maker3_aghaazguard_flesh")
            {
                DestroyOldCreature(oTest);
                DelayCommand(6.0, MakeFactionGolem(oTest, "fleshgolemmaker3", nAghaazBossFaction, "attack_m3bossfac", "golemaghaaz"));
            }
            else if (GetTag(oTest) == "maker3_aghaaz_iron")
            {
                DestroyOldCreature(oTest);
                DelayCommand(6.0, MakeFactionGolem(oTest, "irongolem", nAghaazFaction, "attack_fachost", "golemaghaaz"));
            }
            else if (GetTag(oTest) == "maker3_aghaaz_stone")
            {
                DestroyOldCreature(oTest);
                DelayCommand(6.0, MakeFactionGolem(oTest, "golem_stone", nAghaazFaction, "attack_fachost", "golemaghaaz"));
            }
            else if (GetTag(oTest) == "maker3_aghaaz_clay")
            {
                DestroyOldCreature(oTest);
                DelayCommand(6.0, MakeFactionGolem(oTest, "golem_clay", nAghaazFaction, "attack_fachost", "golemaghaaz"));
            }
            else if (GetTag(oTest) == "maker3_aghaaz")
            {
                DestroyOldCreature(oTest);
                DelayCommand(6.0, MakeFactionGolem(oTest, GetRandomAghaazGolem(), nAghaazFaction, "attack_fachost", "golemaghaaz"));
            }
            else if (GetTag(oTest) == "maker3_aghaaz_gateguard")
            {
                DelayCommand(6.0, MakeDoorGuard(oTest, GetRandomAghaazGolem(), nAghaazBossFaction, "attack_m3bossfac", "maker3aghaazdoor"));
            }
            else if (GetTag(oTest) == "maker3_ferron")
            {
                DestroyOldCreature(oTest);
                DelayCommand(6.0, MakeFactionGolem(oTest, GetRandomFerronGolem(), nFerronFaction, "attack_fachost", "golemferron"));
            }
            else if (GetTag(oTest) == "maker3_ferronguard")
            {
                DestroyOldCreature(oTest);
                DelayCommand(6.0, MakeFactionGolem(oTest, GetRandomFerronGolem(), nFerronBossFaction, "attack_m3bossfac", "golemferron"));
            }
            
        }
        oTest = GetNextObjectInArea(OBJECT_SELF);
    }
}
