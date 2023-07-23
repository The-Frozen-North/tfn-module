#include "inc_general"

const int BASE_AREA_TRAP_CHANCE = 10;
const int BASE_DOOR_TRAP_CHANCE = 20;
const int BASE_TREASURE_TRAP_CHANCE = 40;

// Chance of this trap type spawning
const int TRAP_ACID_WEIGHT = 10;
const int TRAP_ACID_SPLASH_WEIGHT = 10;
const int TRAP_ELECTRICAL_WEIGHT = 1;
const int TRAP_FIRE_WEIGHT = 8;
const int TRAP_FROST_WEIGHT = 15;
const int TRAP_GAS_WEIGHT = 10;
const int TRAP_HOLY_WEIGHT = 3;
const int TRAP_NEGATIVE_WEIGHT = 3;
const int TRAP_SONIC_WEIGHT = 8;
const int TRAP_SPIKE_WEIGHT = 30;
const int TRAP_TANGLE_WEIGHT = 6;

const float TRAP_VFX_SIZE_MINOR = 0.8;
const float TRAP_VFX_SIZE_AVERAGE = 1.0;
const float TRAP_VFX_SIZE_STRONG = 1.2;
const float TRAP_VFX_SIZE_DEADLY = 1.4;
const float TRAP_VFX_SIZE_EPIC = 1.6;

// Determine a random trap based on CR.
int DetermineTrap(int iCR = 0);

// Generate a trap on a placeable or door.
void GenerateTrapOnObject(object oObject = OBJECT_SELF);

int DetermineTrap(int iCR = 0)
{
   int nTrapType;

// Add all the weights
   int nCombinedWeight = 0;

   int nAcidWeight = TRAP_ACID_WEIGHT;
   int nAcidSplashWeight = TRAP_ACID_SPLASH_WEIGHT;
   int nElectricalWeight = TRAP_ELECTRICAL_WEIGHT;
   int nFireWeight = TRAP_FIRE_WEIGHT;
   int nFrostWeight = TRAP_FROST_WEIGHT;
   int nGasWeight = TRAP_GAS_WEIGHT;
   int nHolyWeight = TRAP_HOLY_WEIGHT;
   int nNegativeWeight = TRAP_NEGATIVE_WEIGHT;
   int nSonicWeight = TRAP_SONIC_WEIGHT;
   int nSpikeWeight = TRAP_SPIKE_WEIGHT;
   int nTangleWeight = TRAP_TANGLE_WEIGHT;

// If any of these happen to be less than 0, make it 0

   if (nAcidWeight < 0) nAcidWeight = 0;
   if (nAcidSplashWeight < 0) nAcidSplashWeight = 0;
   if (nElectricalWeight < 0) nElectricalWeight = 0;
   if (nFireWeight < 0) nFireWeight = 0;
   if (nFrostWeight < 0) nFrostWeight = 0;
   if (nGasWeight < 0) nGasWeight = 0;
   if (nHolyWeight < 0) nHolyWeight = 0;
   if (nNegativeWeight < 0) nNegativeWeight = 0;
   if (nSonicWeight < 0) nSonicWeight = 0;
   if (nSpikeWeight < 0) nSpikeWeight = 0;
   if (nTangleWeight < 0) nTangleWeight = 0;

   nCombinedWeight = nAcidWeight + nAcidSplashWeight + nElectricalWeight + nFireWeight + nFrostWeight + nGasWeight + nHolyWeight + nSonicWeight + nSpikeWeight + nTangleWeight;

   int nTrapRoll = Random(nCombinedWeight)+1;
   // some traps are much more deadly than normal ones, mainly electrical and fire ones.
   // as a result, these traps get pushed up to a higher tier
   int iCRBonus = 0;
   while (TRUE)
   {

       nTrapRoll = nTrapRoll - nAcidWeight;
       if (nTrapRoll <= 0)
       {
            nTrapType = TRAP_BASE_TYPE_MINOR_ACID;
            iCRBonus = 1;
            break;
       }

       nTrapRoll = nTrapRoll - nAcidSplashWeight;
       if (nTrapRoll <= 0)
       {
            nTrapType = TRAP_BASE_TYPE_MINOR_ACID_SPLASH;
            break;
       }

       nTrapRoll = nTrapRoll - nElectricalWeight;
       if (nTrapRoll <= 0)
       {
            nTrapType = TRAP_BASE_TYPE_MINOR_ELECTRICAL;
            iCRBonus = 4;
            break;
       }

       nTrapRoll = nTrapRoll - nFireWeight;
       if (nTrapRoll <= 0)
       {
            nTrapType = TRAP_BASE_TYPE_MINOR_FIRE;
            iCRBonus = 3;
            break;
       }

       nTrapRoll = nTrapRoll - nFrostWeight;
       if (nTrapRoll <= 0)
       {
            nTrapType = TRAP_BASE_TYPE_MINOR_FROST;
            break;
       }

       nTrapRoll = nTrapRoll - nSonicWeight;
       if (nTrapRoll <= 0)
       {
            nTrapType = TRAP_BASE_TYPE_MINOR_SONIC;
            break;
       }

       nTrapRoll = nTrapRoll - nGasWeight;
       if (nTrapRoll <= 0)
       {
            nTrapType = TRAP_BASE_TYPE_MINOR_GAS;
            break;
       }

       nTrapRoll = nTrapRoll - nHolyWeight;
       if (nTrapRoll <= 0)
       {
            nTrapType = TRAP_BASE_TYPE_MINOR_HOLY;
            break;
       }

       nTrapRoll = nTrapRoll - nNegativeWeight;
       if (nTrapRoll <= 0)
       {
            nTrapType = TRAP_BASE_TYPE_MINOR_NEGATIVE;
            break;
       }

       nTrapRoll = nTrapRoll - nSonicWeight;
       if (nTrapRoll <= 0)
       {
            nTrapType = TRAP_BASE_TYPE_MINOR_SONIC;
            break;
       }

       nTrapRoll = nTrapRoll - nSpikeWeight;
       if (nTrapRoll <= 0)
       {
            nTrapType = TRAP_BASE_TYPE_MINOR_SPIKE;
            break;
       }

       nTrapRoll = nTrapRoll - nTangleWeight;
       if (nTrapRoll <= 0)
       {
            nTrapType = TRAP_BASE_TYPE_MINOR_TANGLE;
            break;
       }

   }

    int nTrapTier;

// subtract it with the CR bonus
// for electrical/fire traps, this may bump them to a lower trap tier
// i.e. you need to be in a level 19 CR area to get the possibility of the most dangerous electrical trap
    if (iCR-iCRBonus >= 15)
    {
        nTrapTier = Random(3) + 1;
    }
    else if (iCR-iCRBonus >= 12)
    {
        nTrapTier = Random(3);
    }
    else if (iCR-iCRBonus >= 9)
    {
        nTrapTier = Random(2);
    }
    else if (iCR-iCRBonus >= 5)
    {
        nTrapTier = Random(1);
    }
    else if (iCR-iCRBonus >= 0)
    {
        nTrapTier = 0;
    }
// if it is a negative value, it means that a high CR bonus trap (fire or electrical) was chosen
// with a low CR area. in cases like this fallback to the weakest spike trap
    else
    {
        return TRAP_BASE_TYPE_MINOR_SPIKE;
    }

    nTrapType = nTrapType + nTrapTier;

    return nTrapType;
}

void TrapLogic(object oTrap)
{
   SetTrapDetectable(oTrap, TRUE);
   SetTrapDisarmable(oTrap, TRUE);
   SetTrapActive(oTrap, TRUE);

   SetLocalInt(oTrap, "trap_dc", GetTrapDisarmDC(oTrap));

// Only non-deadly traps are recoverable
   if (GetStringLeft(GetName(oTrap), 6) != "Deadly") SetTrapRecoverable(oTrap, TRUE);
}

void GenerateTrapOnObject(object oObject = OBJECT_SELF)
{
   if (GetLocalInt(oObject, "trapped") != 1) return;

   int nTrapChance;
   int iCR = GetLocalInt(oObject, "area_cr");

   switch (GetObjectType(oObject))
   {
       case OBJECT_TYPE_DOOR: nTrapChance = BASE_DOOR_TRAP_CHANCE + iCR; break;
       case OBJECT_TYPE_PLACEABLE: nTrapChance = BASE_TREASURE_TRAP_CHANCE + iCR*2; break;
   }

   if (d100() <= nTrapChance)
   {
       CreateTrapOnObject(DetermineTrap(iCR), oObject, STANDARD_FACTION_HOSTILE, "on_trap_disarm");
       TrapLogic(oObject);
   }
}

// Tag a player that has triggered a trap. There is a bug where we cannot detect the last damager/killer for players, so check for a local
void SetTrapTriggeredOnCreature(object oCreature, string sTrapName = "trap");
void SetTrapTriggeredOnCreature(object oCreature, string sTrapName = "trap")
{
     SetLocalString(oCreature, "trap_triggered", sTrapName);

     IncrementStat(oCreature, "traps_triggered");

     AssignCommand(oCreature, DelayCommand(0.2, DeleteLocalString(oCreature, "trap_triggered")));
}

//void main(){}
