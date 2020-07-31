/*
#include "inc_loot"


void main()
{

    object oPC = GetFirstPC();

    int i;
    for (i = 0; i < 100; i++)
    {
        GenerateTierItem(3, OBJECT_SELF, "Potions");
    }

    SendMessageToPC(oPC, "T1: "+IntToString(GetLocalInt(GetModule(), "T1")));
    SendMessageToPC(oPC, "T2: "+IntToString(GetLocalInt(GetModule(), "T2")));
    SendMessageToPC(oPC, "T3: "+IntToString(GetLocalInt(GetModule(), "T3")));
    SendMessageToPC(oPC, "T4: "+IntToString(GetLocalInt(GetModule(), "T4")));
    SendMessageToPC(oPC, "T5: "+IntToString(GetLocalInt(GetModule(), "T5")));

    SendMessageToPC(oPC, "Scrolls: "+IntToString(GetLocalInt(GetModule(), "Scrolls")));
    SendMessageToPC(oPC, "Potions: "+IntToString(GetLocalInt(GetModule(), "Scrolls")));
    SendMessageToPC(oPC, "Gold: "+IntToString(GetLocalInt(GetModule(), "Gold")));
    SendMessageToPC(oPC, "Misc: "+IntToString(GetLocalInt(GetModule(), "Misc")));
    SendMessageToPC(oPC, "Armor: "+IntToString(GetLocalInt(GetModule(), "Armor")));
    SendMessageToPC(oPC, "Melee: "+IntToString(GetLocalInt(GetModule(), "Melee")));
    SendMessageToPC(oPC, "Range: "+IntToString(GetLocalInt(GetModule(), "Range")));
    SendMessageToPC(oPC, "Apparel: "+IntToString(GetLocalInt(GetModule(), "Apparel")));


}
*/
/*
void main()
{
    object oArea = GetArea(OBJECT_SELF);

    int iRows = GetAreaSize(AREA_WIDTH, oArea);
    int iColumns = GetAreaSize(AREA_HEIGHT, oArea);

    int iXAxis;
    int iYAxis;

// use this to get the center of a tile
    float fMultiplier = 5.0;

    for (iXAxis = 0; iXAxis < iRows; iXAxis++)
    {
        float fXAxis = fMultiplier+(IntToFloat(iXAxis)*fMultiplier*2.0);
        for (iYAxis = 0; iYAxis < iColumns; iYAxis++)
        {
            float fYAxis = fMultiplier+(IntToFloat(iYAxis)*fMultiplier*2.0);
            vector vTile = Vector(fXAxis, fYAxis, 0.0);

            location lTile = Location(oArea, vTile, 0.0);

            object oValidator = CreateObject(OBJECT_TYPE_CREATURE, "_area_validator", lTile);
            if (GetLocation(oValidator) != lTile) DestroyObject(oValidator);
        }
    }
}
*/
/*
#include "inc_trap"
void main()
{
    SetLocalInt(GetArea(OBJECT_SELF), "trapped", 1);
    GenerateTrapsOnArea(GetArea(OBJECT_SELF));
}

*/

/*
void main()
{
   object oArea = GetFirstArea();
   string sAreaResRef;
   location lBaseLocation = Location(GetObjectByTag("_BASE"), Vector(1.0, 1.0, 1.0), 0.0);
   object oAreaRefresher;

// Loop through all objects in the module.

   while (GetIsObjectValid(oArea))
   {
       sAreaResRef = GetResRef(oArea);
// Skip the system areas or copied areas.
       if (GetStringLeft(sAreaResRef, 1) == "_")
       {
           oArea = GetNextArea();
           continue;
       }

// create an area refresher if this is an instanced area.
// this object will occasionally check when an area needs to be destroyed
// and then re-create the area
       if (GetLocalInt(oArea, "instance") == 1)
       {
           object oAreaRefresher = CreateObject(OBJECT_TYPE_CREATURE, "_area_refresher", lBaseLocation, FALSE, sAreaResRef+"+_counter");
           SetLocalString(oAreaRefresher, "resref", sAreaResRef);
           SetName(oAreaRefresher, sAreaResRef);
       }

       ExecuteScript("area_init", oArea);

       oArea = GetNextArea();
   }
}
*/

/*
#include "nwnx_object"
#include "nwnx_creature"

void main() {
    object oLocation = GetObjectByTag("_test_wp");
    object oArea = GetArea(oLocation);
    vector vVector = GetPosition(oLocation);

    int iDamage = GetItemStackSize(GetFirstItemInInventory(OBJECT_SELF));

    object oTester;
    int i;

    for (i = 1;i <= 45;i++)
    {
        DestroyObject(GetObjectByTag("destroy"+IntToString(i)));
    }

    for (i = 1;i <= 40;i++)
    {
        oTester = CreateObject(OBJECT_TYPE_CREATURE, "nw_convict", Location(oArea, Vector(vVector.x+(IntToFloat(i))/2.0, vVector.y, vVector.z), 0.0));

        SetTag(oTester, "destroy"+IntToString(i));
        NWNX_Object_SetCurrentHitPoints(oTester, 1);
        NWNX_Object_SetMaxHitPoints(oTester, i);
        NWNX_Creature_SetCorpseDecayTime(oTester, 10000000000000000);
        SetName(oTester, "Current HP: "+IntToString(GetCurrentHitPoints(oTester))+" Max HP: "+IntToString(GetMaxHitPoints(oTester))+" Damage: "+IntToString(iDamage));
        DelayCommand(1.0, ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(iDamage), oTester));
    }
}
*/

#include "inc_horse"

void main()
{
    GiveGoldToCreature(GetFirstPC(), 10000);
}
