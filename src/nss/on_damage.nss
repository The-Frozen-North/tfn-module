#include "nwnx_damage"
#include "util_i_math"
#include "inc_general"

void main()
{
    object oVictim = OBJECT_SELF;
    struct NWNX_Damage_DamageEventData sDamage = NWNX_Damage_GetDamageEventData();
    if (GetIsPC(oVictim) || GetIsPC(sDamage.oDamager))
    {
        int nPhys = max(0, sDamage.iBase) + max(0, sDamage.iBludgeoning) + max(0, sDamage.iSlash) + max(0, sDamage.iPierce);
        int nMagic = max(0, sDamage.iMagical);
        int nAcid = max(0, sDamage.iAcid);
        int nCold = max(0, sDamage.iCold);
        int nDivine = max(0, sDamage.iDivine);
        int nElectrical = max(0, sDamage.iElectrical);
        int nFire = max(0, sDamage.iFire);
        int nNegative = max(0, sDamage.iNegative);
        int nPositive = max(0, sDamage.iPositive);
        int nSonic = max(0, sDamage.iSonic);
        int nTotal = nPhys + nMagic + nAcid + nCold + nDivine + nElectrical + nFire + nNegative + nPositive + nSonic;
        if (GetIsPC(oVictim))
        {
            if (nTotal > 0) { IncrementPlayerStatistic(oVictim, "damage_taken", nTotal); }
            if (nPhys > 0) { IncrementPlayerStatistic(oVictim, "physical_damage_taken", nPhys); }
            if (nAcid > 0) { IncrementPlayerStatistic(oVictim, "acid_damage_taken", nAcid); } 
            if (nCold > 0) { IncrementPlayerStatistic(oVictim, "cold_damage_taken", nCold); }
            if (nDivine > 0) { IncrementPlayerStatistic(oVictim, "divine_damage_taken", nDivine); } 
            if (nElectrical > 0) { IncrementPlayerStatistic(oVictim, "electrical_damage_taken", nElectrical); }
            if (nFire > 0) { IncrementPlayerStatistic(oVictim, "fire_damage_taken", nFire); } 
            if (nNegative > 0) { IncrementPlayerStatistic(oVictim, "negative_damage_taken", nNegative); }
            if (nPositive > 0) { IncrementPlayerStatistic(oVictim, "positive_damage_taken", nPositive); }
            if (nSonic > 0) { IncrementPlayerStatistic(oVictim, "sonic_damage_taken", nSonic); }
        }
        if (GetIsPC(sDamage.oDamager))
        {
            if (nTotal > 0) { IncrementPlayerStatistic(sDamage.oDamager, "damage_dealt", nTotal); }
            if (nPhys > 0) { IncrementPlayerStatistic(sDamage.oDamager, "physical_damage_dealt", nPhys); }
            if (nAcid > 0) { IncrementPlayerStatistic(sDamage.oDamager, "acid_damage_dealt", nAcid); }
            if (nCold > 0) { IncrementPlayerStatistic(sDamage.oDamager, "cold_damage_dealt", nCold); }
            if (nDivine > 0) { IncrementPlayerStatistic(sDamage.oDamager, "divine_damage_dealt", nDivine); }
            if (nElectrical > 0) { IncrementPlayerStatistic(sDamage.oDamager, "electrical_damage_dealt", nElectrical); }
            if (nFire > 0) { IncrementPlayerStatistic(sDamage.oDamager, "fire_damage_dealt", nFire); }
            if (nNegative > 0) { IncrementPlayerStatistic(sDamage.oDamager, "negative_damage_dealt", nNegative); }
            if (nPositive > 0) { IncrementPlayerStatistic(sDamage.oDamager, "positive_damage_dealt", nPositive); }
            if (nSonic > 0) { IncrementPlayerStatistic(sDamage.oDamager, "sonic_damage_dealt", nSonic); }
        }
    }
}