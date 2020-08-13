//::///////////////////////////////////////////////
//:: Weapon Spawn Script for Martial Classes
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Spawns in a magical SPECIFIC weapon suited for that class.
    Will spawn in either a generic or specific, depending on the
    value.

    NOTE: Only works on containers
*/
//:://////////////////////////////////////////////
//:: Created By:   Andrew, Brent
//:: Created On:   February 2002
//:://////////////////////////////////////////////
/*
Patch 1.71

- non-existant resref for rapier changed to create Namarra +1
- not only weapon focus is taken into account, improved critical also matter
- added support for character with multiple weapon focuses - script generate random focused weapon in this case
- barbarians without any weapon feat gets great axe instead of club
- improved weapon selection for multiclassed characters without weapon feats:
 - when previously ranger9/druid1 get druidic weapon now gets longsword like pure ranger etc.
- custom base class without any weapon feat gets dagger instead of nothing
- added support for weapons from expansions/patches (dwarven waraxe, whip, trident)
*/

#include "nw_o2_coninclude"

void CreateBastardSword(object oTarget, object oAdventurer)
{
        string sItem = "";
        int nHD = GetHitDice(oAdventurer);

        if (GetRange(1, nHD))    // * 800
        {
                  int nRandom = Random(1) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wswmbs002"; break;
                   }
        }
        else if (GetRange(2, nHD))   // * 200 - 2500
        {
                  int nRandom = Random(1) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wswmbs002"; break;
                   }
        }
        else if (GetRange(3, nHD))   // * 800 - 10000
        {
                  int nRandom = Random(2) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wswmbs002"; break;
                       case 2: sItem = "nw_wswmbs009"; break;
                   }

        }
        else if (GetRange(4, nHD))   // * 2500 - 16500
        {
                  int nRandom = Random(2) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wswmbs009"; break;
                       case 2: sItem = "nw_wswmbs005"; break;
                   }

        }
        else if (GetRange(5, nHD))   // * 8000 - 25000
        {
                   int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wswmbs005"; break;
                       case 2: sItem = "nw_wswmbs010"; break;
                       case 3: sItem = "nw_wswmbs006"; break;
                   }

        }
        else if (GetRange(6, nHD))   // * 16000 and up
        {
                  int nRandom = Random(5) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wswmbs010"; break;
                       case 2: sItem = "nw_wswmbs006"; break;
                       case 3: sItem = "nw_wswmbs007"; break;
                       case 4: sItem = "nw_wswmbs003"; break;
                       case 5: sItem = "nw_wswmbs004"; break;
                   }
        }
        if (sItem != "")
          dbCreateItemOnObject(sItem, oTarget, 1);
}
void CreateBattleAxe(object oTarget, object oAdventurer)
{

        string sItem = "";
        int nHD = GetHitDice(oAdventurer);

        if (GetRange(1, nHD))    // * 800
        {
                  int nRandom = Random(1) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_waxmbt002"; break;
                  }

        }
        else if (GetRange(2, nHD))   // * 200 - 2500
        {
                  int nRandom = Random(1) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_waxmbt002"; break;
                   }

        }
        else if (GetRange(3, nHD))   // * 800 - 10000
        {
                  int nRandom = Random(2) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_waxmbt002"; break;
                       case 2: sItem = "nw_waxmbt010"; break;
                   }

        }
        else if (GetRange(4, nHD))   // * 2500 - 16500
        {
                  int nRandom = Random(2) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_waxmbt010"; break;
                       case 2: sItem = "nw_waxmbt011"; break;
                   }

        }
        else if (GetRange(5, nHD))   // * 8000 - 25000
        {
                  int nRandom = Random(2) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_waxmbt011"; break;
                       case 2: sItem = "nw_waxmbt006"; break;
                   }

        }
        else if (GetRange(6, nHD))   // * 16000 and up
        {
                   int nRandom = Random(5) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_waxmbt011"; break;
                       case 2: sItem = "nw_waxmbt006"; break;
                       case 3: sItem = "nw_waxmbt003"; break;
                       case 4: sItem = "nw_waxmbt004"; break;
                       case 5: sItem = "nw_waxmbt005"; break;
                   }

        }
        if (sItem != "")
          dbCreateItemOnObject(sItem, oTarget, 1);
}
void CreateClub(object oTarget, object oAdventurer)
{

        string sItem = "";
        int nHD = GetHitDice(oAdventurer);

        if (GetRange(1, nHD))    // * 800
        {
                  int nRandom = Random(1) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wblmcl002"; break;
                   }

        }
        else if (GetRange(2, nHD))   // * 200 - 2500
        {
                    int nRandom = Random(1) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wblmcl002"; break;
                   }

        }
        else if (GetRange(3, nHD))   // * 800 - 10000
        {
                  int nRandom = Random(2) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wblmcl002"; break;
                       case 2: sItem = "nw_wblmcl010"; break;
                   }

        }
        else if (GetRange(4, nHD))   // * 2500 - 16500
        {
                   int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wblmcl010"; break;
                       case 2: sItem = "nw_wblmcl004"; break;
                       case 3: sItem = "nw_wblmcl003"; break;
                   }

        }
        else if (GetRange(5, nHD))   // * 8000 - 25000
        {
                  int nRandom = Random(4) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wblmcl004"; break;
                       case 2: sItem = "nw_wblmcl003"; break;
                       case 3: sItem = "nw_wblmcl011"; break;
                       case 4: sItem = "nw_wblmcl005"; break;
                   }

        }
        else if (GetRange(6, nHD))   // * 16000 and up
        {
                  int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wblmcl011"; break;
                       case 2: sItem = "nw_wblmcl005"; break;
                       case 3: sItem = "nw_wblmcl006"; break;
                   }

        }
        if (sItem != "")
          dbCreateItemOnObject(sItem, oTarget, 1);
}

void CreateDagger(object oTarget, object oAdventurer)
{

        string sItem = "";
        int nHD = GetHitDice(oAdventurer);

        if (GetRange(1, nHD))    // * 800
        {
                  int nRandom = Random(1) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wswmdg002"; break;
                   }

        }
        else if (GetRange(2, nHD))   // * 200 - 2500
        {

                  int nRandom = Random(1) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wswmdg002"; break;
                   }
        }
        else if (GetRange(3, nHD))   // * 800 - 10000
        {
                  int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wswmdg002"; break;
                       case 2: sItem = "nw_wswmdg008"; break;
                       case 3: sItem = "nw_wswmdg006"; break;
                   }

        }
        else if (GetRange(4, nHD))   // * 2500 - 16500
        {
                  int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wswmdg008"; break;
                       case 2: sItem = "nw_wswmdg006"; break;
                       case 3: sItem = "nw_wswmdg009"; break;
                   }

        }
        else if (GetRange(5, nHD))   // * 8000 - 25000
        {
                  int nRandom = Random(2) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wswmdg009"; break;
                       case 2: sItem = "nw_wswmdg004"; break;
                   }

        }
        else if (GetRange(6, nHD))   // * 16000 and up
        {
                  int nRandom = Random(5) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wswmdg009"; break;
                       case 2: sItem = "nw_wswmdg004"; break;
                       case 3: sItem = "nw_wswmdg003"; break;
                       case 4: sItem = "nw_wswmdg007"; break;
                       case 5: sItem = "nw_wswmdg005"; break;
                   }

        }
        if (sItem != "")
          dbCreateItemOnObject(sItem, oTarget, 1);
}
void CreateDart(object oTarget, object oAdventurer)
{

        string sItem = "";
        int nHD = GetHitDice(oAdventurer);

        if (GetRange(1, nHD))    // * 800
        {
                  int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wthmdt002"; break;
                       case 2: sItem = "nw_wthmdt002"; break;
                       case 3: sItem = "nw_wthmdt008"; break;
                   }

        }
        else if (GetRange(2, nHD))   // * 200 - 2500
        {
                  int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wthmdt008"; break;
                       case 2: sItem = "nw_wthmdt009"; break;
                       case 3: sItem = "nw_wthmdt003"; break;
                   }

        }
        else
        {
                  int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wthmdt009"; break;
                       case 2: sItem = "nw_wthmdt003"; break;
                       case 3: sItem = "nw_wthmdt007"; break;
                   }

        }

        if (sItem != "")
          dbCreateItemOnObject(sItem, oTarget, Random(40) + 1);
}
void CreateDireMace(object oTarget, object oAdventurer)
{

        string sItem = "";
        int nHD = GetHitDice(oAdventurer);

        if (GetRange(1, nHD))    // * 800
        {
                  int nRandom = Random(1) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wdbmma002"; break;
                   }

        }
        else if (GetRange(2, nHD))   // * 200 - 2500
        {
                  int nRandom = Random(1) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wdbmma002"; break;
                   }

        }
        else if (GetRange(3, nHD))   // * 800 - 10000
        {
                  int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wdbmma002"; break;
                       case 2: sItem = "nw_wdbmma003"; break;
                       case 3: sItem = "nw_wdbmma010"; break;
                   }

        }
        else if (GetRange(4, nHD))   // * 2500 - 16500
        {
                  int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wdbmma003"; break;
                       case 2: sItem = "nw_wdbmma010"; break;
                       case 3: sItem = "nw_wdbmma005"; break;
                   }

        }
        else if (GetRange(5, nHD))   // * 8000 - 25000
        {
                  int nRandom = Random(4) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wdbmma005"; break;
                       case 2: sItem = "nw_wdbmma011"; break;
                       case 3: sItem = "nw_wdbmma004"; break;
                       case 4: sItem = "nw_wdbmma006"; break;
                   }

        }
        else if (GetRange(6, nHD))   // * 16000 and up
        {
                  int nRandom = Random(4) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wdbmma005"; break;
                       case 2: sItem = "nw_wdbmma011"; break;
                       case 3: sItem = "nw_wdbmma004"; break;
                       case 4: sItem = "nw_wdbmma006"; break;
                   }

        }
        if (sItem != "")
          dbCreateItemOnObject(sItem, oTarget, 1);
}
void CreateDoubleAxe(object oTarget, object oAdventurer)
{

        string sItem = "";
        int nHD = GetHitDice(oAdventurer);

        if (GetRange(1, nHD))    // * 800
        {
                  int nRandom = Random(1) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wdbmax002"; break;
                   }

        }
        else if (GetRange(2, nHD))   // * 200 - 2500
        {
                  int nRandom = Random(1) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wdbmax002"; break;
                   }

        }
        else if (GetRange(3, nHD))   // * 800 - 10000
        {
                  int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wdbmax002"; break;
                       case 2: sItem = "nw_wdbmax010"; break;
                       case 3: sItem = "nw_wdbmax006"; break;
                   }

        }
        else if (GetRange(4, nHD))   // * 2500 - 16500
        {
                  int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wdbmax010"; break;
                       case 2: sItem = "nw_wdbmax006"; break;
                       case 3: sItem = "nw_wdbmax005"; break;
                   }

        }
        else  if (GetRange(5, nHD))
        {
                  int nRandom = Random(4) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wdbmax005"; break;
                       case 2: sItem = "nw_wdbmax011"; break;
                       case 3: sItem = "nw_wdbmax004"; break;
                       case 4: sItem = "nw_wdbmax007"; break;
                   }

        }
        else if (GetRange(6, nHD))   // * 16000 and up
        {
                  int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wdbmax011"; break;
                       case 2: sItem = "nw_wdbmax004"; break;
                       case 3: sItem = "nw_wdbmax007"; break;
                   }

        }
        if (sItem != "")
          dbCreateItemOnObject(sItem, oTarget, 1);
}
void CreateGreatAxe(object oTarget, object oAdventurer)
{

        string sItem = "";
        int nHD = GetHitDice(oAdventurer);

        if (GetRange(1, nHD))    // * 800
        {
                  int nRandom = Random(1) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_waxmgr002"; break;
                   }

        }
        else if (GetRange(2, nHD))   // * 200 - 2500
        {
                  int nRandom = Random(1) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_waxmgr002"; break;
                   }

        }
        else if (GetRange(3, nHD))   // * 800 - 10000
        {
                  int nRandom = Random(2) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_waxmgr002"; break;
                       case 2: sItem = "nw_waxmgr009"; break;
                   }

        }
        else if (GetRange(4, nHD))   // * 2500 - 16500
        {
                  int nRandom = Random(4) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_waxmgr002"; break;
                       case 2: sItem = "nw_waxmgr009"; break;
                       case 3: sItem = "nw_waxmgr003"; break;
                       case 4: sItem = "nw_waxmgr006"; break;
                   }

        }
        else if (GetRange(5, nHD))   // * 8000 - 25000
        {

                  int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_waxmgr003"; break;
                       case 2: sItem = "nw_waxmgr006"; break;
                       case 3: sItem = "nw_waxmgr011"; break;
                   }
        }
        else if (GetRange(6, nHD))   // * 16000 and up
        {
                  int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_waxmgr011"; break;
                       case 2: sItem = "nw_waxmgr005"; break;
                       case 3: sItem = "nw_waxmgr004"; break;
                   }

        }
        if (sItem != "")
          dbCreateItemOnObject(sItem, oTarget, 1);
}
void CreateGreatSword(object oTarget, object oAdventurer)
{

        string sItem = "";
        int nHD = GetHitDice(oAdventurer);

        if (GetRange(1, nHD))    // * 800
        {
                  int nRandom = Random(1) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wswmgs002"; break;
                   }

        }
        else if (GetRange(2, nHD))   // * 200 - 2500
        {
                  int nRandom = Random(1) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wswmgs002"; break;
                   }

        }
        else if (GetRange(3, nHD))   // * 800 - 10000
        {
                  int nRandom = Random(2) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wswmgs002"; break;
                       case 2: sItem = "nw_wswmgs011"; break;
                   }

        }
        else if (GetRange(4, nHD))   // * 2500 - 16500
        {
                  int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wswmgs011"; break;
                       case 2: sItem = "nw_wswmgs006"; break;
                       case 3: sItem = "nw_wswmgs004"; break;
                   }

        }
        else if (GetRange(5, nHD))   // * 8000 - 25000
        {
                  int nRandom = Random(4) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wswmgs006"; break;
                       case 2: sItem = "nw_wswmgs004"; break;
                       case 3: sItem = "nw_wswmgs012"; break;
                       case 4: sItem = "nw_wswmgs005"; break;
                   }

        }
        else if (GetRange(6, nHD))   // * 16000 and up
        {

                  int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wswmgs012"; break;
                       case 2: sItem = "nw_wswmgs005"; break;
                       case 3: sItem = "nw_wswmgs003"; break;
                   }
        }
        if (sItem != "")
          dbCreateItemOnObject(sItem, oTarget, 1);
}
void CreateHalberd(object oTarget, object oAdventurer)
{

        string sItem = "";
        int nHD = GetHitDice(oAdventurer);

        if (GetRange(1, nHD))    // * 800
        {
                  int nRandom = Random(1) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wplmhb002"; break;
                   }

        }
        else if (GetRange(2, nHD))   // * 200 - 2500
        {
                  int nRandom = Random(1) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wplmhb002"; break;
                   }

        }
        else if (GetRange(3, nHD))   // * 800 - 10000
        {
                  int nRandom = Random(2) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wplmhb002"; break;
                       case 2: sItem = "nw_wplmhb010"; break;
                   }

        }
        else if (GetRange(4, nHD))   // * 2500 - 16500
        {
                  int nRandom = Random(2) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wplmhb010"; break;
                       case 2: sItem = "nw_wplmhb004"; break;
                   }

        }
        else if (GetRange(5, nHD))   // * 8000 - 25000
        {
                  int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wplmhb004"; break;
                       case 2: sItem = "nw_wplmhb011"; break;
                       case 3: sItem = "nw_wplmhb003"; break;
                   }

        }
        else if (GetRange(6, nHD))   // * 16000 and up
        {
                  int nRandom = Random(4) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wplmhb011"; break;
                       case 2: sItem = "nw_wplmhb003"; break;
                       case 3: sItem = "nw_wplmhb007"; break;
                       case 4: sItem = "nw_wplmhb006"; break;
                   }

        }
        if (sItem != "")
          dbCreateItemOnObject(sItem, oTarget, 1);
}
void CreateHandAxe(object oTarget, object oAdventurer)
{

        string sItem = "";
        int nHD = GetHitDice(oAdventurer);

        if (GetRange(1, nHD))    // * 800
        {
                  int nRandom = Random(1) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_waxmhn002"; break;
                   }

        }
        else if (GetRange(2, nHD))   // * 200 - 2500
        {
                  int nRandom = Random(1) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_waxmhn002"; break;
                   }

        }
        else if (GetRange(3, nHD))   // * 800 - 10000
        {
                  int nRandom = Random(2) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_waxmhn002"; break;
                       case 2: sItem = "nw_waxmhn010"; break;
                   }

        }
        else if (GetRange(4, nHD))   // * 2500 - 16500
        {
                  int nRandom = Random(2) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_waxmhn010"; break;
                       case 2: sItem = "nw_waxmhn004"; break;
                   }

        }
        else if (GetRange(5, nHD))   // * 8000 - 25000
        {
                  int nRandom = Random(4) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_waxmhn004"; break;
                       case 2: sItem = "nw_waxmhn011"; break;
                       case 3: sItem = "nw_waxmhn003"; break;
                       case 4: sItem = "nw_waxmhn005"; break;
                   }

        }
        else if (GetRange(6, nHD))   // * 16000 and up
        {
                  int nRandom = Random(4) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_waxmhn011"; break;
                       case 2: sItem = "nw_waxmhn003"; break;
                       case 3: sItem = "nw_waxmhn005"; break;
                       case 4: sItem = "nw_waxmhn006"; break;
                   }

        }
        if (sItem != "")
          dbCreateItemOnObject(sItem, oTarget, 1);
}
void CreateHeavyCrossbow(object oTarget, object oAdventurer)
{

        string sItem = "";
        int nHD = GetHitDice(oAdventurer);

        if (GetRange(1, nHD))    // * 800
        {
                  int nRandom = Random(2) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wbwmxh002"; break;
                       case 2: sItem = "nw_wbwmxh002"; break;
                   }

        }
        else if (GetRange(2, nHD))   // * 200 - 2500
        {
                  int nRandom = Random(2) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wbwmxh002"; break;
                       case 2: sItem = "nw_wbwmxh008"; break;
                   }

        }
        else if (GetRange(3, nHD))   // * 800 - 10000
        {
                  int nRandom = Random(4) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wbwmxh002"; break;
                       case 2: sItem = "nw_wbwmxh008"; break;
                       case 3: sItem = "nw_wbwmxh009"; break;
                       case 4: sItem = "nw_wbwmxh005"; break;
                   }

        }
        else if (GetRange(4, nHD))   // * 2500 - 16500
        {
                  int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wbwmxh009"; break;
                       case 2: sItem = "nw_wbwmxh005"; break;
                       case 3: sItem = "nw_wbwmxh003"; break;
                   }

        }
        else if (GetRange(5, nHD))   // * 8000 - 25000
        {
                  int nRandom = Random(2) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wbwmxh003"; break;
                       case 2: sItem = "nw_wbwmxh004"; break;
                   }

        }
        else if (GetRange(6, nHD))   // * 16000 and up
        {
                  int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wbwmxh004"; break;
                       case 2: sItem = "nw_wbwmxh007"; break;
                       case 3: sItem = "nw_wbwmxh006"; break;
                   }

        }
        if (sItem != "")
          dbCreateItemOnObject(sItem, oTarget, 1);
}
void CreateHeavyFlail(object oTarget, object oAdventurer)
{

        string sItem = "";
        int nHD = GetHitDice(oAdventurer);

        if (GetRange(1, nHD))    // * 800
        {
                  int nRandom = Random(1) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wblmfh002"; break;
                   }

        }
        else if (GetRange(2, nHD))   // * 200 - 2500
        {
                  int nRandom = Random(1) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wblmfh002"; break;
                   }

        }
        else if (GetRange(3, nHD))   // * 800 - 10000
        {
                  int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wblmfh002"; break;
                       case 2: sItem = "nw_wblmfh007"; break;
                       case 3: sItem = "nw_wblmfh010"; break;
                   }

        }
        else if (GetRange(4, nHD))   // * 2500 - 16500
        {
                  int nRandom = Random(5) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wblmfh002"; break;
                       case 2: sItem = "nw_wblmfh007"; break;
                       case 3: sItem = "nw_wblmfh010"; break;
                       case 4: sItem = "nw_wblmfh004"; break;
                       case 5: sItem = "nw_wblmfh008"; break;
                   }

        }
        else if (GetRange(5, nHD))   // * 8000 - 25000
        {
                  int nRandom = Random(5) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wblmfh004"; break;
                       case 2: sItem = "nw_wblmfh008"; break;
                       case 3: sItem = "nw_wblmfh011"; break;
                       case 4: sItem = "nw_wblmfh006"; break;
                       case 5: sItem = "nw_wblmfh003"; break;
                   }

        }
        else if (GetRange(6, nHD))   // * 16000 and up
        {
                   int nRandom = Random(4) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wblmfh011"; break;
                       case 2: sItem = "nw_wblmfh006"; break;
                       case 3: sItem = "nw_wblmfh003"; break;
                       case 4: sItem = "nw_wblmfh005"; break;
                   }

        }
        if (sItem != "")
          dbCreateItemOnObject(sItem, oTarget, 1);
}
void CreateKama(object oTarget, object oAdventurer)
{

        string sItem = "";
        int nHD = GetHitDice(oAdventurer);

        if (GetRange(1, nHD))    // * 800
        {
                  int nRandom = Random(1) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wspmka002"; break;
                   }

        }
        else if (GetRange(2, nHD))   // * 200 - 2500
        {
                  int nRandom = Random(1) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wspmka002"; break;
                   }

        }
        else if (GetRange(3, nHD))   // * 800 - 10000
        {
                  int nRandom = Random(5) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wspmka002"; break;
                       case 2: sItem = "nw_wspmka004"; break;
                       case 3: sItem = "nw_wspmka007"; break;
                       case 4: sItem = "nw_wspmka008"; break;
                       case 5: sItem = "nw_wspmka005"; break;
                   }

        }
        else if (GetRange(4, nHD))   // * 2500 - 16500
        {
                  int nRandom = Random(4) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wspmka004"; break;
                       case 2: sItem = "nw_wspmka007"; break;
                       case 3: sItem = "nw_wspmka008"; break;
                       case 4: sItem = "nw_wspmka005"; break;
                   }

        }
        else if (GetRange(5, nHD))   // * 8000 - 25000
        {
                  int nRandom = Random(4) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wspmka005"; break;
                       case 2: sItem = "nw_wspmka009"; break;
                       case 3: sItem = "nw_wspmka006"; break;
                       case 4: sItem = "nw_wspmka003"; break;
                   }

        }
        else if (GetRange(6, nHD))   // * 16000 and up
        {
                  int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wspmka009"; break;
                       case 2: sItem = "nw_wspmka006"; break;
                       case 3: sItem = "nw_wspmka003"; break;
                   }

        }
        if (sItem != "")
          dbCreateItemOnObject(sItem, oTarget, 1);
}
void CreateKatana(object oTarget, object oAdventurer)
{

        string sItem = "";
        int nHD = GetHitDice(oAdventurer);

        if (GetRange(1, nHD))    // * 800
        {
                   int nRandom = Random(1) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wswmka002"; break;
                   }

        }
        else if (GetRange(2, nHD))   // * 200 - 2500
        {
                  int nRandom = Random(1) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wswmka002"; break;
                   }

        }
        else if (GetRange(3, nHD))   // * 800 - 10000
        {
                  int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wswmka002"; break;
                       case 2: sItem = "nw_wswmka005"; break;
                       case 3: sItem = "nw_wswmka010"; break;
                   }

        }
        else if (GetRange(4, nHD))   // * 2500 - 16500
        {
                  int nRandom = Random(2) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wswmka005"; break;
                       case 2: sItem = "nw_wswmka010"; break;
                   }

        }
        else if (GetRange(5, nHD))   // * 8000 - 25000
        {
                  int nRandom = Random(2) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wswmka011"; break;
                       case 2: sItem = "nw_wswmka007"; break;
                   }

        }
        else if (GetRange(6, nHD))   // * 16000 and up
        {
                  int nRandom = Random(4) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wswmka011"; break;
                       case 2: sItem = "nw_wswmka007"; break;
                       case 3: sItem = "nw_wswmka006"; break;
                       case 4: sItem = "nw_wswmka004"; break;
                   }

        }
        if (sItem != "")
          dbCreateItemOnObject(sItem, oTarget, 1);
}
void CreateKukri(object oTarget, object oAdventurer)
{

        string sItem = "";
        int nHD = GetHitDice(oAdventurer);

        if (GetRange(1, nHD))    // * 800
        {
                  int nRandom = Random(1) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wspmku002"; break;
                   }

        }
        else if (GetRange(2, nHD))   // * 200 - 2500
        {
                  int nRandom = Random(1) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wspmku002"; break;
                   }

        }
        else if (GetRange(3, nHD))   // * 800 - 10000
        {
                  int nRandom = Random(4) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wspmku002"; break;
                       case 2: sItem = "nw_wspmku006"; break;
                       case 3: sItem = "nw_wspmku008"; break;
                       case 4: sItem = "nw_wspmku005"; break;
                   }

        }
        else if (GetRange(4, nHD))   // * 2500 - 16500
        {
                  int nRandom = Random(4) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wspmku006"; break;
                       case 2: sItem = "nw_wspmku008"; break;
                       case 3: sItem = "nw_wspmku005"; break;
                       case 4: sItem = "nw_wspmku004"; break;
                   }

        }
        else if (GetRange(5, nHD))   // * 8000 - 25000
        {
                  int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wspmku004"; break;
                       case 2: sItem = "nw_wspmku009"; break;
                       case 3: sItem = "nw_wspmku007"; break;
                   }

        }
        else if (GetRange(6, nHD))   // * 16000 and up
        {
                  int nRandom = Random(2) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wspmku009"; break;
                       case 2: sItem = "nw_wspmku007"; break;
                   }

        }
        if (sItem != "")
          dbCreateItemOnObject(sItem, oTarget, 1);
}
void CreateLightCrossbow(object oTarget, object oAdventurer)
{

        string sItem = "";
        int nHD = GetHitDice(oAdventurer);

        if (GetRange(1, nHD))    // * 800
        {
                  int nRandom = Random(2) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wbwxl001"; break;
                       case 2: sItem = "nw_wbwmxl002"; break;
                   }

        }
        else if (GetRange(2, nHD))   // * 200 - 2500
        {
                  int nRandom = Random(2) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wbwmxl002"; break;
                       case 2: sItem = "nw_wbwmxl008"; break;
                   }

        }
        else if (GetRange(3, nHD))   // * 800 - 10000
        {
                  int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wbwmxl008"; break;
                       case 2: sItem = "nw_wbwmxl009"; break;
                       case 3: sItem = "nw_wbwmxl005"; break;
                   }

        }
        else if (GetRange(4, nHD))   // * 2500 - 16500
        {
                  int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wbwmxl009"; break;
                       case 2: sItem = "nw_wbwmxl005"; break;
                       case 3: sItem = "nw_wbwmxl003"; break;
                   }

        }
        else if (GetRange(5, nHD))   // * 8000 - 25000
        {
                  int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wbwmxl003"; break;
                       case 2: sItem = "nw_wbwmxl004"; break;
                       case 3: sItem = "nw_wbwmxl007"; break;
                   }

        }
        else if (GetRange(6, nHD))   // * 16000 and up
        {
                  int nRandom = Random(4) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wbwmxl003"; break;
                       case 2: sItem = "nw_wbwmxl004"; break;
                       case 3: sItem = "nw_wbwmxl007"; break;
                       case 4: sItem = "nw_wbwmxl006"; break;
                   }

        }
        if (sItem != "")
          dbCreateItemOnObject(sItem, oTarget, 1);
}

void CreateLightFlail(object oTarget, object oAdventurer)
{

        string sItem = "";
        int nHD = GetHitDice(oAdventurer);

        if (GetRange(1, nHD))    // * 800
        {
                  int nRandom = Random(1) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wblmfl002"; break;
                   }

        }
        else if (GetRange(2, nHD))   // * 200 - 2500
        {
                  int nRandom = Random(1) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wblmfl002"; break;
                   }

        }
        else if (GetRange(3, nHD))   // * 800 - 10000
        {
                  int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wblmfl002"; break;
                       case 2: sItem = "nw_wblmfl010"; break;
                       case 3: sItem = "nw_wblmfl004"; break;
                   }

        }
        else if (GetRange(4, nHD))   // * 2500 - 16500
        {
                  int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wblmfl010"; break;
                       case 2: sItem = "nw_wblmfl004"; break;
                       case 3: sItem = "nw_wblmfl005"; break;
                   }

        }
        else if (GetRange(5, nHD))   // * 8000 - 25000
        {
                  int nRandom = Random(4) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wblmfl005"; break;
                       case 2: sItem = "nw_wblmfl011"; break;
                       case 3: sItem = "nw_wblmfl007"; break;
                       case 4: sItem = "nw_wblmfl006"; break;
                   }

        }
        else if (GetRange(6, nHD))   // * 16000 and up
        {
                  int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wblmfl011"; break;
                       case 2: sItem = "nw_wblmfl007"; break;
                       case 3: sItem = "nw_wblmfl006"; break;
                   }

        }
        if (sItem != "")
          dbCreateItemOnObject(sItem, oTarget, 1);
}

void CreateLightHammer(object oTarget, object oAdventurer)
{

        string sItem = "";
        int nHD = GetHitDice(oAdventurer);

        if (GetRange(1, nHD))    // * 800
        {
                  int nRandom = Random(1) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wblmhl002"; break;
                   }

        }
        else if (GetRange(2, nHD))   // * 200 - 2500
        {
                  int nRandom = Random(1) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wblmhl002"; break;
                   }

        }
        else if (GetRange(3, nHD))   // * 800 - 10000
        {
                  int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wblmhl002"; break;
                       case 2: sItem = "nw_wblmhl010"; break;
                       case 3: sItem = "nw_wblmhl004"; break;
                   }

        }
        else if (GetRange(4, nHD))   // * 2500 - 16500
        {
                  int nRandom = Random(2) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wblmhl010"; break;
                       case 2: sItem = "nw_wblmhl004"; break;
                   }

        }
        else if (GetRange(5, nHD))   // * 8000 - 25000
        {
                  int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wblmhl005"; break;
                       case 2: sItem = "nw_wblmhl011"; break;
                       case 3: sItem = "nw_wblmhl006"; break;
                   }

        }
        else if (GetRange(6, nHD))   // * 16000 and up
        {
                  int nRandom = Random(5) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wblmhl005"; break;
                       case 2: sItem = "nw_wblmhl011"; break;
                       case 3: sItem = "nw_wblmhl006"; break;
                       case 4: sItem = "nw_wblmhl009"; break;
                       case 5: sItem = "nw_wblmhl003"; break;
                   }

        }
        if (sItem != "")
          dbCreateItemOnObject(sItem, oTarget, 1);
}
void CreateLightMace(object oTarget, object oAdventurer)
{

        string sItem = "";
        int nHD = GetHitDice(oAdventurer);

        if (GetRange(1, nHD))    // * 800
        {
                  int nRandom = Random(1) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wblmml002"; break;
                   }

        }
        else if (GetRange(2, nHD))   // * 200 - 2500
        {
                  int nRandom = Random(1) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wblmml002"; break;
                   }

        }
        else if (GetRange(3, nHD))   // * 800 - 10000
        {
                  int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wblmml002"; break;
                       case 2: sItem = "nw_wblmml011"; break;
                       case 3: sItem = "nw_wblmml006"; break;
                   }

        }
        else if (GetRange(4, nHD))   // * 2500 - 16500
        {
                  int nRandom = Random(2) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wblmml011"; break;
                       case 2: sItem = "nw_wblmml006"; break;
                   }

        }
        else if (GetRange(5, nHD))   // * 8000 - 25000
        {
                  int nRandom = Random(4) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wblmml012"; break;
                       case 2: sItem = "nw_wblmml004"; break;
                       case 3: sItem = "nw_wblmml005"; break;
                       case 4: sItem = "nw_wblmml007"; break;
                   }

        }
        else if (GetRange(6, nHD))   // * 16000 and up
        {
                  int nRandom = Random(5) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wblmml012"; break;
                       case 2: sItem = "nw_wblmml004"; break;
                       case 3: sItem = "nw_wblmml005"; break;
                       case 4: sItem = "nw_wblmml007"; break;
                       case 5: sItem = "nw_wblmml008"; break;
                   }

        }
        if (sItem != "")
          dbCreateItemOnObject(sItem, oTarget, 1);
}
void CreateLongSword(object oTarget, object oAdventurer)
{

        string sItem = "";
        int nHD = GetHitDice(oAdventurer);

        if (GetRange(1, nHD))    // * 800
        {
                  int nRandom = Random(1) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wswmls002"; break;
                   }

        }
        else if (GetRange(2, nHD))   // * 200 - 2500
        {
                  int nRandom = Random(1) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wswmls002"; break;
                   }

        }
        else if (GetRange(3, nHD))   // * 800 - 10000
        {
                  int nRandom = Random(2) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wswmls002"; break;
                       case 2: sItem = "nw_wswmls010"; break;
                   }

        }
        else if (GetRange(4, nHD))   // * 2500 - 16500
        {
                  int nRandom = Random(2) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wswmls010"; break;
                       case 2: sItem = "nw_wswmls007"; break;
                   }

        }
        else if (GetRange(5, nHD))   // * 8000 - 25000
        {
                  int nRandom = Random(4) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wswmls007"; break;
                       case 2: sItem = "nw_wswmls012"; break;
                       case 3: sItem = "nw_wswmls005"; break;
                       case 4: sItem = "nw_wswmls006"; break;
                   }

        }
        else if (GetRange(6, nHD))   // * 16000 and up
        {
                  int nRandom = Random(5) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wswmls012"; break;
                       case 2: sItem = "nw_wswmls005"; break;
                       case 3: sItem = "nw_wswmls006"; break;
                       case 4: sItem = "nw_wswmls004"; break;
                       case 5: sItem = "nw_wswmls013"; break;
                   }

        }
        if (sItem != "")
          dbCreateItemOnObject(sItem, oTarget, 1);
}
void CreateLongbow(object oTarget, object oAdventurer)
{

        string sItem = "";
        int nHD = GetHitDice(oAdventurer);

        if (GetRange(1, nHD))    // * 800
        {
                  int nRandom = Random(1) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wbwmln002"; break;
                   }

        }
        else if (GetRange(2, nHD))   // * 200 - 2500
        {
                  int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wbwmln002"; break;
                       case 2: sItem = "nw_wbwmln002"; break;
                       case 3: sItem = "nw_wbwmln008"; break;
                   }

        }
        else if (GetRange(3, nHD))   // * 800 - 10000
        {
                   int nRandom = Random(4) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wbwmln002"; break;
                       case 2: sItem = "nw_wbwmln008"; break;
                       case 3: sItem = "nw_wbwmln009"; break;
                       case 4: sItem = "nw_wbwmln004"; break;
                   }

        }
        else if (GetRange(4, nHD))   // * 2500 - 16500
        {
                  int nRandom = Random(2) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wbwmln009"; break;
                       case 2: sItem = "nw_wbwmln004"; break;
                   }

        }
        else if (GetRange(5, nHD))   // * 8000 - 25000
        {
                  int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wbwmln004"; break;
                       case 2: sItem = "nw_wbwmln007"; break;
                       case 3: sItem = "nw_wbwmln006"; break;
                   }

        }
        else if (GetRange(6, nHD))   // * 16000 and up
        {
                  int nRandom = Random(4) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wbwmln007"; break;
                       case 2: sItem = "nw_wbwmln006"; break;
                       case 3: sItem = "nw_wbwmln005"; break;
                       case 4: sItem = "nw_wbwmln003"; break;
                   }

        }
        if (sItem != "")
          dbCreateItemOnObject(sItem, oTarget, 1);
}
void CreateMorningstar(object oTarget, object oAdventurer)
{

        string sItem = "";
        int nHD = GetHitDice(oAdventurer);

        if (GetRange(1, nHD))    // * 800
        {
                  int nRandom = Random(1) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wblmms002"; break;
                   }

        }
        else if (GetRange(2, nHD))   // * 200 - 2500
        {
                  int nRandom = Random(1) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wblmms002"; break;
                   }

        }
        else if (GetRange(3, nHD))   // * 800 - 10000
        {
                  int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wblmms002"; break;
                       case 2: sItem = "nw_wblmms010"; break;
                       case 3: sItem = "nw_wblmms007"; break;
                   }

        }
        else if (GetRange(4, nHD))   // * 2500 - 16500
        {
                  int nRandom = Random(2) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wblmms007"; break;
                       case 2: sItem = "nw_wblmms003"; break;
                   }

        }
        else if (GetRange(5, nHD))   // * 8000 - 25000
        {
                  int nRandom = Random(2) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wblmms003"; break;
                       case 2: sItem = "nw_wblmms011"; break;
                   }

        }
        else if (GetRange(6, nHD))   // * 16000 and up
        {
                  int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wblmms011"; break;
                       case 2: sItem = "nw_wblmms006"; break;
                       case 3: sItem = "nw_wblmms004"; break;
                   }

        }
        if (sItem != "")
          dbCreateItemOnObject(sItem, oTarget, 1);
}
void CreateRapier(object oTarget, object oAdventurer)
{

        string sItem = "";
        int nHD = GetHitDice(oAdventurer);

        if (GetRange(1, nHD))    // * 800
        {
                  int nRandom = Random(1) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wswmrp002"; break;
                   }

        }
        else if (GetRange(2, nHD))   // * 200 - 2500
        {
                  int nRandom = Random(1) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wswmrp002"; break;
                   }

        }
        else if (GetRange(3, nHD))   // * 800 - 10000
        {
                  int nRandom = Random(4) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wswmrp002"; break;
                       case 2: sItem = "nw_wswmrp004"; break;
                       case 3: sItem = "nw_wswmrp010"; break;
                       case 4: sItem = "nw_wswmrp008"; break;
                   }

        }
        else if (GetRange(4, nHD))   // * 2500 - 16500
        {
                  int nRandom = Random(4) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wswmrp004"; break;
                       case 2: sItem = "nw_wswmrp010"; break;
                       case 3: sItem = "nw_wswmrp005"; break;
                       case 4: sItem = "nw_wswmrp008"; break;
                   }

        }
        else if (GetRange(5, nHD))   // * 8000 - 25000
        {
                  int nRandom = Random(4) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wswmrp005"; break;
                       case 2: sItem = "nw_wswmrp011"; break;
                       case 3: sItem = "nw_wswmrp007"; break;
                       case 4: sItem = "nw_wswmrp008"; break;
                   }

        }
        else if (GetRange(6, nHD))   // * 16000 and up
        {
                  int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wswmrp011"; break;
                       case 2: sItem = "nw_wswmrp007"; break;
                       case 3: sItem = "nw_wswmrp006"; break;
                   }

        }
        if (sItem != "")
          dbCreateItemOnObject(sItem, oTarget, 1);
}
void CreateScimitar(object oTarget, object oAdventurer)
{

        string sItem = "";
        int nHD = GetHitDice(oAdventurer);

        if (GetRange(1, nHD))    // * 800
        {
                  int nRandom = Random(1) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wswmsc002"; break;
                   }

        }
        else if (GetRange(2, nHD))   // * 200 - 2500
        {
                  int nRandom = Random(1) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wswmsc002"; break;
                   }

        }
        else if (GetRange(3, nHD))   // * 800 - 10000
        {
                  int nRandom = Random(2) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wswmsc002"; break;
                       case 2: sItem = "nw_wswmsc010"; break;
                   }

        }
        else if (GetRange(4, nHD))   // * 2500 - 16500
        {
                  int nRandom = Random(2) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wswmsc010"; break;
                       case 2: sItem = "nw_wswmsc004"; break;
                   }

        }
        else if (GetRange(5, nHD))   // * 8000 - 25000
        {
                  int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wswmsc004"; break;
                       case 2: sItem = "nw_wswmsc011"; break;
                       case 3: sItem = "nw_wswmsc006"; break;
                   }

        }
        else if (GetRange(6, nHD))   // * 16000 and up
        {
                  int nRandom = Random(4) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wswmsc011"; break;
                       case 2: sItem = "nw_wswmsc006"; break;
                       case 3: sItem = "nw_wswmsc007"; break;
                       case 4: sItem = "nw_wswmsc005"; break;
                   }

        }
        if (sItem != "")
          dbCreateItemOnObject(sItem, oTarget, 1);
}
void CreateScythe(object oTarget, object oAdventurer)
{

        string sItem = "";
        int nHD = GetHitDice(oAdventurer);

        if (GetRange(1, nHD))    // * 800
        {
                  int nRandom = Random(1) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wplmsc002"; break;
                   }

        }
        else if (GetRange(2, nHD))   // * 200 - 2500
        {
                  int nRandom = Random(1) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wplmsc002"; break;
                   }

        }
        else if (GetRange(3, nHD))   // * 800 - 10000
        {
                  int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wplmsc002"; break;
                       case 2: sItem = "nw_wplmsc010"; break;
                       case 3: sItem = "nw_wplmsc003"; break;
                   }

        }
        else if (GetRange(4, nHD))   // * 2500 - 16500
        {
                  int nRandom = Random(2) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wplmsc010"; break;
                       case 2: sItem = "nw_wplmsc003"; break;
                   }

        }
        else if (GetRange(5, nHD))   // * 8000 - 25000
        {
                  int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wplmsc003"; break;
                       case 2: sItem = "nw_wplmsc011"; break;
                       case 3: sItem = "nw_wplmsc006"; break;
                   }

        }
        else if (GetRange(6, nHD))   // * 16000 and up
        {
                  int nRandom = Random(4) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wplmsc011"; break;
                       case 2: sItem = "nw_wplmsc006"; break;
                       case 3: sItem = "nw_wplmsc005"; break;
                       case 4: sItem = "nw_wplmsc004"; break;
                   }

        }
        if (sItem != "")
          dbCreateItemOnObject(sItem, oTarget, 1);
}
void CreateShortsword(object oTarget, object oAdventurer)
{

        string sItem = "";
        int nHD = GetHitDice(oAdventurer);

        if (GetRange(1, nHD))    // * 800
        {
                  int nRandom = Random(1) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wswmss002"; break;
                   }

        }
        else if (GetRange(2, nHD))   // * 200 - 2500
        {
                  int nRandom = Random(1) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wswmss002"; break;
                   }

        }
        else if (GetRange(3, nHD))   // * 800 - 10000
        {
                  int nRandom = Random(2) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wswmss002"; break;
                       case 2: sItem = "nw_wswmss009"; break;
                   }

        }
        else if (GetRange(4, nHD))   // * 2500 - 16500
        {
                  int nRandom = Random(2) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wswmss009"; break;
                       case 2: sItem = "nw_wswmss011"; break;
                   }

        }
        else if (GetRange(5, nHD))   // * 8000 - 25000
        {
                  int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wswmss011"; break;
                       case 2: sItem = "nw_wswmss005"; break;
                       case 3: sItem = "nw_wswmss004"; break;
                   }

        }
        else if (GetRange(6, nHD))   // * 16000 and up
        {
                  int nRandom = Random(5) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wswmss011"; break;
                       case 2: sItem = "nw_wswmss005"; break;
                       case 3: sItem = "nw_wswmss004"; break;
                       case 4: sItem = "nw_wswmss006"; break;
                       case 5: sItem = "nw_wswmss003"; break;
                   }

        }
        if (sItem != "")
          dbCreateItemOnObject(sItem, oTarget, 1);
}
void CreateShortbow(object oTarget, object oAdventurer)
{

        string sItem = "";
        int nHD = GetHitDice(oAdventurer);

        if (GetRange(1, nHD))    // * 800
        {
                   int nRandom = Random(2) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wbwmsh002"; break;
                       case 2: sItem = "nw_wbwmsh002"; break;
                   }
       }
        else if (GetRange(2, nHD))   // * 200 - 2500
        {
                  int nRandom = Random(2) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wbwmsh002"; break;
                       case 2: sItem = "nw_wbwmsh008"; break;
                   }

        }
        else if (GetRange(3, nHD))   // * 800 - 10000
        {
                  int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wbwmsh008"; break;
                       case 2: sItem = "nw_wbwmsh009"; break;
                       case 3: sItem = "nw_wbwmsh003"; break;
                   }

        }
        else if (GetRange(4, nHD))   // * 2500 - 16500
        {
                  int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wbwmsh009"; break;
                       case 2: sItem = "nw_wbwmsh003"; break;
                       case 3: sItem = "nw_wbwmsh006"; break;
                   }

        }
        else if (GetRange(5, nHD))   // * 8000 - 25000
        {
                  int nRandom = Random(2) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wbwmsh006"; break;
                       case 2: sItem = "nw_wbwmsh007"; break;
                   }

        }
        else if (GetRange(6, nHD))   // * 16000 and up
        {
                  int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wbwmsh007"; break;
                       case 2: sItem = "nw_wbwmsh005"; break;
                       case 3: sItem = "nw_wbwmsh004"; break;
                   }

        }
        if (sItem != "")
          dbCreateItemOnObject(sItem, oTarget, 1);
}
void CreateShuriken(object oTarget, object oAdventurer)
{

        string sItem = "";
        int nHD = GetHitDice(oAdventurer);

        if (GetRange(1, nHD))    // * 800
        {
                  int nRandom = Random(5) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wthmsh002"; break;
                       case 2: sItem = "nw_wthmsh002"; break;
                       case 3: sItem = "nw_wthmsh003"; break;
                       case 4: sItem = "nw_wthmsh008"; break;
                       case 5: sItem = "nw_wthmsh006"; break;
                   }

        }
        else if (GetRange(2, nHD))   // * 200 - 2500
        {
                  int nRandom = Random(5) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wthmsh002"; break;
                       case 2: sItem = "nw_wthmsh003"; break;
                       case 3: sItem = "nw_wthmsh008"; break;
                       case 4: sItem = "nw_wthmsh006"; break;
                       case 5: sItem = "nw_wthmsh009"; break;
                   }

        }
        else if (GetRange(3, nHD))   // * 800 - 10000
        {
                  int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wthmsh006"; break;
                       case 2: sItem = "nw_wthmsh009"; break;
                       case 3: sItem = "nw_wthmsh005"; break;
                   }

        }
        else if (GetRange(4, nHD))   // * 2500 - 16500
        {
                  int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wthmsh009"; break;
                       case 2: sItem = "nw_wthmsh005"; break;
                       case 3: sItem = "nw_wthmsh004"; break;
                   }

        }
        else if (GetRange(5, nHD))   // * 8000 - 25000
        {
                  int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wthmsh005"; break;
                       case 2: sItem = "nw_wthmsh004"; break;
                       case 3: sItem = "nw_wthmsh007"; break;
                   }

        }
        else if (GetRange(6, nHD))   // * 16000 and up
        {
                  int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wthmsh005"; break;
                       case 2: sItem = "nw_wthmsh004"; break;
                       case 3: sItem = "nw_wthmsh007"; break;
                   }

        }
        if (sItem != "")
          dbCreateItemOnObject(sItem, oTarget, Random(40) + 1);
}
void CreateSickle(object oTarget, object oAdventurer)
{

        string sItem = "";
        int nHD = GetHitDice(oAdventurer);

        if (GetRange(1, nHD))    // * 800
        {
                  int nRandom = Random(1) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wspmsc002"; break;
                   }

        }
        else if (GetRange(2, nHD))   // * 200 - 2500
        {
                  int nRandom = Random(1) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wspmsc002"; break;
                   }

        }
        else if (GetRange(3, nHD))   // * 800 - 10000
        {
                  int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wspmsc002"; break;
                       case 2: sItem = "nw_wspmsc010"; break;
                       case 3: sItem = "nw_wspmsc004"; break;
                   }

        }
        else if (GetRange(4, nHD))   // * 2500 - 16500
        {
                  int nRandom = Random(5) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wspmsc010"; break;
                       case 2: sItem = "nw_wspmsc004"; break;
                       case 3: sItem = "nw_wspmsc005"; break;
                       case 4: sItem = "nw_wspmsc006"; break;
                       case 5: sItem = "nw_wspmsc003"; break;
                   }

        }
        else if (GetRange(5, nHD))   // * 8000 - 25000
        {
                  int nRandom = Random(4) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wspmsc005"; break;
                       case 2: sItem = "nw_wspmsc006"; break;
                       case 3: sItem = "nw_wspmsc003"; break;
                       case 4: sItem = "nw_wspmsc011"; break;
                   }

        }
        else if (GetRange(6, nHD))   // * 16000 and up
        {
                  int nRandom = Random(1) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wspmsc011"; break;
                   }

        }
        if (sItem != "")
          dbCreateItemOnObject(sItem, oTarget, 1);
}
void CreateSling(object oTarget, object oAdventurer)
{

        string sItem = "";
        int nHD = GetHitDice(oAdventurer);

        if (GetRange(1, nHD))    // * 800
        {
                  int nRandom = Random(2) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wbwmsl001"; break;
                       case 2: sItem = "nw_wbwmsl001"; break;
                   }

        }
        else if (GetRange(2, nHD))   // * 200 - 2500
        {
                   int nRandom = Random(2) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wbwmsl001"; break;
                       case 2: sItem = "nw_wbwmsl009"; break;
                   }

        }
        else if (GetRange(3, nHD))   // * 800 - 10000
        {
                  int nRandom = Random(2) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wbwmsl009"; break;
                       case 2: sItem = "nw_wbwmsl010"; break;
                   }

        }
        else if (GetRange(4, nHD))   // * 2500 - 16500
        {
                  int nRandom = Random(2) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wbwmsl010"; break;
                       case 2: sItem = "nw_wbwmsl003"; break;
                   }

        }
        else if (GetRange(5, nHD))   // * 8000 - 25000
        {
                  int nRandom = Random(2) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wbwmsl003"; break;
                       case 2: sItem = "nw_wbwmsl007"; break;
                   }

        }
        else if (GetRange(6, nHD))   // * 16000 and up
        {
                  int nRandom = Random(4) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wbwmsl007"; break;
                       case 2: sItem = "nw_wbwmsl006"; break;
                       case 3: sItem = "nw_wbwmsl008"; break;
                       case 4: sItem = "nw_wbwmsl004"; break;
                   }

        }
        if (sItem != "")
          dbCreateItemOnObject(sItem, oTarget, 1);
}
void CreateSpear(object oTarget, object oAdventurer)
{

        string sItem = "";
        int nHD = GetHitDice(oAdventurer);

        if (GetRange(1, nHD))    // * 800
        {
                  int nRandom = Random(1) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wplmss002"; break;
                   }

        }
        else if (GetRange(2, nHD))   // * 200 - 2500
        {
                  int nRandom = Random(1) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wplmss002"; break;
                   }
        }
        else if (GetRange(3, nHD))   // * 800 - 10000
        {
                  int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wplmss002"; break;
                       case 2: sItem = "nw_wbwmsl005"; break;
                       case 3: sItem = "nw_wplmss010"; break;
                   }

        }
        else if (GetRange(4, nHD))   // * 2500 - 16500
        {
                  int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wbwmsl005"; break;
                       case 2: sItem = "nw_wplmss010"; break;
                       case 3: sItem = "nw_wplmss005"; break;
                   }

        }
        else if (GetRange(5, nHD))   // * 8000 - 25000
        {
                  int nRandom = Random(4) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wplmss005"; break;
                       case 2: sItem = "nw_wplmss011"; break;
                       case 3: sItem = "nw_wplmss007"; break;
                       case 4: sItem = "nw_wplmss006"; break;
                   }

        }
        else if (GetRange(6, nHD))   // * 16000 and up
        {
                  int nRandom = Random(4) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wplmss011"; break;
                       case 2: sItem = "nw_wplmss007"; break;
                       case 3: sItem = "nw_wplmss006"; break;
                       case 4: sItem = "nw_wplmss004"; break;
                   }

        }
        if (sItem != "")
          dbCreateItemOnObject(sItem, oTarget, 1);
}
void CreateStaff(object oTarget, object oAdventurer)
{

        string sItem = "";
        int nHD = GetHitDice(oAdventurer);

        if (GetRange(1, nHD))    // * 800
        {
                  int nRandom = Random(1) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wdbmqs002"; break;
                   }

        }
        else if (GetRange(2, nHD))   // * 200 - 2500
        {
                  int nRandom = Random(1) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wdbmqs002"; break;
                   }

        }
        else if (GetRange(3, nHD))   // * 800 - 10000
        {
                  int nRandom = Random(4) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wdbmqs002"; break;
                       case 2: sItem = "nw_wdbmqs005"; break;
                       case 3: sItem = "nw_wdbmqs006"; break;
                       case 4: sItem = "nw_wdbmqs008"; break;
                   }

        }
        else if (GetRange(4, nHD))   // * 2500 - 16500
        {
                  int nRandom = Random(4) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wdbmqs005"; break;
                       case 2: sItem = "nw_wdbmqs006"; break;
                       case 3: sItem = "nw_wdbmqs008"; break;
                       case 4: sItem = "nw_wdbmqs004"; break;
                   }

        }
        else if (GetRange(5, nHD))   // * 8000 - 25000
        {
                  int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wdbmqs004"; break;
                       case 2: sItem = "nw_wdbmqs009"; break;
                       case 3: sItem = "nw_wdbmqs003"; break;
                   }

        }
        else if (GetRange(6, nHD))   // * 16000 and up
        {
                  int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wdbmqs009"; break;
                       case 2: sItem = "nw_wdbmqs003"; break;
                       case 3: sItem = "nw_wdbmqs007"; break;
                   }

        }
        if (sItem != "")
          dbCreateItemOnObject(sItem, oTarget, 1);
}
void CreateThrowingAxe(object oTarget, object oAdventurer)
{

        string sItem = "";
        int nHD = GetHitDice(oAdventurer);

        if (GetRange(1, nHD))    // * 800
        {
                  int nRandom = Random(1) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wthmax002"; break;
                   }

        }
        else if (GetRange(2, nHD))   // * 200 - 2500
        {
                  int nRandom = Random(4) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wthmax002"; break;
                       case 2: sItem = "nw_wthmax008"; break;
                       case 3: sItem = "nw_wthmax005"; break;
                       case 4: sItem = "nw_wthmax007"; break;
                   }

        }
        else if (GetRange(3, nHD))   // * 800 - 10000
        {
                  int nRandom = Random(5) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wthmax008"; break;
                       case 2: sItem = "nw_wthmax005"; break;
                       case 3: sItem = "nw_wthmax007"; break;
                       case 4: sItem = "nw_wthmax003"; break;
                       case 5: sItem = "nw_wthmax004"; break;
                   }

        }
        else if (GetRange(4, nHD))   // * 2500 - 16500
        {
                  int nRandom = Random(4) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wthmax007"; break;
                       case 2: sItem = "nw_wthmax003"; break;
                       case 3: sItem = "nw_wthmax004"; break;
                       case 4: sItem = "nw_wthmax009"; break;
                   }

        }
        else if (GetRange(5, nHD))   // * 8000 - 25000
        {
                  int nRandom = Random(4) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wthmax003"; break;
                       case 2: sItem = "nw_wthmax004"; break;
                       case 3: sItem = "nw_wthmax009"; break;
                       case 4: sItem = "nw_wthmax006"; break;
                   }

        }
        else if (GetRange(6, nHD))   // * 16000 and up
        {
                  int nRandom = Random(2) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wthmax009"; break;
                       case 2: sItem = "nw_wthmax006"; break;
                   }

        }
        if (sItem != "")
          dbCreateItemOnObject(sItem, oTarget, Random(40) + 1);
}
void CreateTwoBladedSword(object oTarget, object oAdventurer)
{

        string sItem = "";
        int nHD = GetHitDice(oAdventurer);

        if (GetRange(1, nHD))    // * 800
        {
                  int nRandom = Random(1) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wdbmsw002"; break;
                   }

        }
        else if (GetRange(2, nHD))   // * 200 - 2500
        {
                  int nRandom = Random(2) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wdbmsw002"; break;
                       case 2: sItem = "nw_wdbmsw002"; break;
                   }

        }
        else if (GetRange(3, nHD))   // * 800 - 10000
        {
                  int nRandom = Random(4) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wdbmsw002"; break;
                       case 2: sItem = "nw_wdbmsw010"; break;
                       case 3: sItem = "nw_wdbmsw006"; break;
                       case 4: sItem = "nw_wdbmsw007"; break;
                   }

        }
        else if (GetRange(4, nHD))   // * 2500 - 16500
        {
                  int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wdbmsw010"; break;
                       case 2: sItem = "nw_wdbmsw006"; break;
                       case 3: sItem = "nw_wdbmsw007"; break;
                   }

        }
        else if (GetRange(5, nHD))   // * 8000 - 25000
        {
                  int nRandom = Random(2) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wdbmsw011"; break;
                       case 2: sItem = "nw_wdbmsw005"; break;
                   }

        }
        else if (GetRange(6, nHD))   // * 16000 and up
        {
                  int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wdbmsw011"; break;
                       case 2: sItem = "nw_wdbmsw005"; break;
                       case 3: sItem = "nw_wdbmsw004"; break;
                   }

        }
        if (sItem != "")
          dbCreateItemOnObject(sItem, oTarget, 1);
}
void CreateWarhammer(object oTarget, object oAdventurer)
{

        string sItem = "";
        int nHD = GetHitDice(oAdventurer);

        if (GetRange(1, nHD))    // * 800
        {
                  int nRandom = Random(1) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wblmhw002"; break;
                   }

        }
        else if (GetRange(2, nHD))   // * 200 - 2500
        {
                  int nRandom = Random(1) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wblmhw002"; break;
                   }

        }
        else if (GetRange(3, nHD))   // * 800 - 10000
        {
                  int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wblmhw002"; break;
                       case 2: sItem = "nw_wblmhw011"; break;
                       case 3: sItem = "nw_wblmhw006"; break;
                   }

        }
        else if (GetRange(4, nHD))   // * 2500 - 16500
        {
                  int nRandom = Random(2) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wblmhw011"; break;
                       case 2: sItem = "nw_wblmhw006"; break;
                   }

        }
        else if (GetRange(5, nHD))   // * 8000 - 25000
        {
                  int nRandom = Random(4) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wblmhw006"; break;
                       case 2: sItem = "nw_wblmhw005"; break;
                       case 3: sItem = "nw_wblmhw012"; break;
                       case 4: sItem = "nw_wblmhw003"; break;
                   }

        }
        else if (GetRange(6, nHD))   // * 16000 and up
        {
                  int nRandom = Random(3) + 1;
                  switch (nRandom)
                  {
                       case 1: sItem = "nw_wblmhw012"; break;
                       case 2: sItem = "nw_wblmhw003"; break;
                       case 3: sItem = "nw_wblmhw004"; break;
                   }

        }
        if (sItem != "")
          dbCreateItemOnObject(sItem, oTarget, 1);
}
//1.71
void CreateDwarvenWaraxe(object oTarget, object oAdventurer)
{
        string sItem = "";
        int nHD = GetHitDice(oAdventurer);

        if (GetRange(1, nHD))    // * 800
        {
                  switch (Random(1))
                  {
                       case 0: sItem = "x2_wmdwraxe002"; break;
                  }
        }
        else if (GetRange(2, nHD))   // * 200 - 2500
        {
                  switch (Random(1))
                  {
                       case 0: sItem = "x2_wmdwraxe002"; break;
                  }
        }
        else if (GetRange(3, nHD))   // * 800 - 10000
        {
                  switch (Random(2))
                  {
                       case 0: sItem = "x2_wmdwraxe002"; break;
                       case 1: sItem = "x2_wmdwraxe003"; break;
                  }
        }
        else if (GetRange(4, nHD))   // * 2500 - 16500
        {
                  switch (Random(2))
                  {
                       case 0: sItem = "x2_wmdwraxe002"; break;
                       case 1: sItem = "x2_wmdwraxe003"; break;
                  }
        }
        else if (GetRange(5, nHD))   // * 8000 - 25000
        {
                  switch (Random(3))
                  {
                       case 0: sItem = "x2_wmdwraxe002"; break;
                       case 1: sItem = "x2_wmdwraxe003"; break;
                       case 2: sItem = "x2_wmdwraxe004"; break;
                  }
        }
        else if (GetRange(6, nHD))   // * 800 - 10000
        {
                  switch (Random(2))
                  {
                       case 0: sItem = "x2_wmdwraxe003"; break;
                       case 1: sItem = "x2_wmdwraxe004"; break;
                  }
        }

        else //if (GetRange(6, nHD))   // * 800 - 10000
        {
                  switch (Random(2))
                  {
                       case 0: sItem = "x2_wmdwraxe002"; break;
                       case 1: sItem = "x2_wmdwraxe003"; break;
                  }
        }
        if (sItem != "")
          dbCreateItemOnObject(sItem, oTarget, 1);
}
//1.71
void CreateWhip(object oTarget, object oAdventurer)
{
        string sItem = "";
        int nHD = GetHitDice(oAdventurer);

        if (GetRange(1, nHD))    // * 800
        {
                  switch (Random(1))
                  {
                       case 0: sItem = "x2_it_wpmwhip1"; break;
                  }
        }
        else if (GetRange(2, nHD))   // * 200 - 2500
        {
                  switch (Random(1))
                  {
                       case 0: sItem = "x2_it_wpmwhip1"; break;
                  }
        }
        else if (GetRange(3, nHD))   // * 800 - 10000
        {
                  switch (Random(2))
                  {
                       case 0: sItem = "x2_it_wpmwhip1"; break;
                       case 1: sItem = "x2_it_wpmwhip2"; break;
                  }
        }
        else if (GetRange(4, nHD))   // * 2500 - 16500
        {
                  switch (Random(2))
                  {
                       case 0: sItem = "x2_it_wpmwhip1"; break;
                       case 1: sItem = "x2_it_wpmwhip2"; break;
                  }
        }
        else if (GetRange(5, nHD))   // * 8000 - 25000
        {
                  switch (Random(4))
                  {
                       case 0: sItem = "x2_it_wpmwhip1"; break;
                       case 1: sItem = "x2_it_wpmwhip2"; break;
                       case 2: sItem = "x2_it_wpmwhip3"; break;
                       case 3: sItem = "x2_it_wpmwhip_h"; break;
                  }
        }
        else if (GetRange(6, nHD))   // * 800 - 10000
        {
                  switch (Random(5))
                  {
                       case 0: sItem = "x2_it_wpmwhip2"; break;
                       case 1: sItem = "x2_it_wpmwhip3"; break;
                       case 2: sItem = "x2_it_wpmwhip_h"; break;
                       case 3: sItem = "x2_it_wpmwhip3"; break;
                       case 4: sItem = "x2_it_crewpwhip"; break;
                  }
        }
        if (sItem != "")
          dbCreateItemOnObject(sItem, oTarget, 1);
}
//1.71
void CreateTrident(object oTarget, object oAdventurer)
{
        string sItem = "";
        int nHD = GetHitDice(oAdventurer);

        if (GetRange(1, nHD))    // * 800
        {
                  switch (Random(1))
                  {
                       case 0: sItem = "nw_wpltr002"; break;
                  }
        }
        else if (GetRange(2, nHD))   // * 200 - 2500
        {
                  switch (Random(1))
                  {
                       case 0: sItem = "nw_wpltr002"; break;
                  }
        }
        else if (GetRange(3, nHD))   // * 800 - 10000
        {
                  switch (Random(2))
                  {
                       case 0: sItem = "nw_wpltr002"; break;
                       case 1: sItem = "nw_wpltr003"; break;
                  }
        }
        else if (GetRange(4, nHD))   // * 2500 - 16500
        {
                  switch (Random(2))
                  {
                       case 0: sItem = "nw_wpltr002"; break;
                       case 1: sItem = "nw_wpltr003"; break;
                  }
        }
        else if (GetRange(5, nHD))   // * 8000 - 25000
        {
                  switch (Random(3))
                  {
                       case 0: sItem = "nw_wpltr002"; break;
                       case 1: sItem = "nw_wpltr003"; break;
                       case 2: sItem = "nw_wpltr004"; break;
                  }
        }
        else if (GetRange(6, nHD))   // * 800 - 10000
        {
                  switch (Random(5))
                  {
                       case 0: sItem = "nw_wpltr003"; break;
                       case 1: sItem = "nw_wpltr004"; break;
                       case 2: sItem = "nw_wpltr003"; break;
                       case 3: sItem = "nw_wpltr004"; break;
                       case 4: sItem = "nw_wpltr010"; break;
                  }
        }
        if (sItem != "")
          dbCreateItemOnObject(sItem, oTarget, 1);
}
//::///////////////////////////////////////////////
//:: Prefers
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Returns true if oAdventurer prefers using
    this weapon.
    CRITERIA: They have Weapon Focus
    nFeatWeaponType: Uses the feat constants
    to differentiate the weapon types
*/
//:://////////////////////////////////////////////
//:: Created By: Brent
//:: Created On: March 2002
//:://////////////////////////////////////////////
int Prefers(int nFeatWeaponType, object oAdventurer)
{
    return GetHasFeat(nFeatWeaponType, oAdventurer) > 0;
}
//1.71 - private function
void InitWeaponFocusArray(object oLastOpener);

void main()
{
    object oLastOpener = GetLastOpener();
    object oContainer = OBJECT_SELF;

    if (GetLocalInt(OBJECT_SELF, "NW_L_OPENONCE") > 0 || GetIsObjectValid(oLastOpener) == FALSE)
    {
        return; // * abort treasure if no one opened the container
    }
    SetLocalInt(OBJECT_SELF, "NW_L_OPENONCE",1);
    ShoutDisturbed();

    InitWeaponFocusArray(oLastOpener);
    int nWeaponFocusedIn = GetLocalInt(oContainer,"ARRAY_WF");
    if(nWeaponFocusedIn > 0)
    {
        int nWeapon = GetLocalInt(oContainer,"ARRAY_WF_"+IntToString(Random(nWeaponFocusedIn)+1));
        if(nWeapon == BASE_ITEM_BASTARDSWORD)
        {
            CreateBastardSword(oContainer, oLastOpener);
        }
        else if(nWeapon == BASE_ITEM_BASTARDSWORD)
        {
            CreateBattleAxe(oContainer, oLastOpener);
        }
        else if(nWeapon == BASE_ITEM_BASTARDSWORD)
        {
            CreateClub(oContainer, oLastOpener);
        }
        else if(nWeapon == BASE_ITEM_DAGGER)
        {
            CreateDagger(oContainer, oLastOpener);
        }
        else if(nWeapon == BASE_ITEM_DART)
        {
            CreateDart(oContainer, oLastOpener);
        }
        else if(nWeapon == BASE_ITEM_DIREMACE)
        {
            CreateDireMace(oContainer, oLastOpener);
        }
        else if(nWeapon == BASE_ITEM_DOUBLEAXE)
        {
            CreateDoubleAxe(oContainer, oLastOpener);
        }
        else if(nWeapon == BASE_ITEM_GREATAXE)
        {
            CreateGreatAxe(oContainer, oLastOpener);
        }
        else if(nWeapon == BASE_ITEM_GREATSWORD)
        {
            CreateGreatSword(oContainer, oLastOpener);
        }
        else if(nWeapon == BASE_ITEM_HALBERD)
        {
            CreateHalberd(oContainer, oLastOpener);
        }
        else if(nWeapon == BASE_ITEM_HANDAXE)
        {
            CreateHandAxe(oContainer, oLastOpener);
        }
        else if(nWeapon == BASE_ITEM_HEAVYCROSSBOW)
        {
            CreateHeavyCrossbow(oContainer, oLastOpener);
        }
        else if(nWeapon == BASE_ITEM_HEAVYFLAIL)
        {
            CreateHeavyFlail(oContainer, oLastOpener);
        }
        else if(nWeapon == BASE_ITEM_KAMA)
        {
            CreateKama(oContainer, oLastOpener);
        }
        else if(nWeapon == BASE_ITEM_KATANA)
        {
            CreateKatana(oContainer, oLastOpener);
        }
        else if(nWeapon == BASE_ITEM_KUKRI)
        {
            CreateKukri(oContainer, oLastOpener);
        }
        else if(nWeapon == BASE_ITEM_LIGHTCROSSBOW)
        {
            CreateLightCrossbow(oContainer, oLastOpener);
        }
        else if(nWeapon == BASE_ITEM_LIGHTFLAIL)
        {
            CreateLightFlail(oContainer, oLastOpener);
        }
        else if(nWeapon == BASE_ITEM_LIGHTHAMMER)
        {
            CreateLightHammer(oContainer, oLastOpener);
        }
        else if(nWeapon == BASE_ITEM_LIGHTMACE)
        {
            CreateLightMace(oContainer, oLastOpener);
        }
        else if(nWeapon == BASE_ITEM_LONGSWORD)
        {
            CreateLongSword(oContainer, oLastOpener);
        }
        else if(nWeapon == BASE_ITEM_LONGBOW)
        {
            CreateLongbow(oContainer, oLastOpener);
        }
        else if(nWeapon == BASE_ITEM_MORNINGSTAR)
        {
            CreateMorningstar(oContainer, oLastOpener);
        }
        else if(nWeapon == BASE_ITEM_RAPIER)
        {
            CreateRapier(oContainer, oLastOpener);
        }
        else if(nWeapon == BASE_ITEM_SCIMITAR)
        {
            CreateScimitar(oContainer, oLastOpener);
        }
        else if(nWeapon == BASE_ITEM_SCYTHE)
        {
            CreateScythe(oContainer, oLastOpener);
        }
        else if(nWeapon == BASE_ITEM_SHORTSWORD)
        {
            CreateShortsword(oContainer, oLastOpener);
        }
        else if(nWeapon == BASE_ITEM_SHORTBOW)
        {
            CreateShortbow(oContainer, oLastOpener);
        }
        else if(nWeapon == BASE_ITEM_SHURIKEN)
        {
            CreateShuriken(oContainer, oLastOpener);
        }
        else if(nWeapon == BASE_ITEM_SICKLE)
        {
            CreateSickle(oContainer, oLastOpener);
        }
        else if(nWeapon == BASE_ITEM_SLING)
        {
            CreateSling(oContainer, oLastOpener);
        }
        else if(nWeapon == BASE_ITEM_SHORTSPEAR)
        {
            CreateSpear(oContainer, oLastOpener);
        }
        else if(nWeapon == BASE_ITEM_QUARTERSTAFF)
        {
            CreateStaff(oContainer, oLastOpener);
        }
        else if(nWeapon == BASE_ITEM_THROWINGAXE)
        {
            CreateThrowingAxe(oContainer, oLastOpener);
        }
        else if(nWeapon == BASE_ITEM_TWOBLADEDSWORD)
        {
            CreateTwoBladedSword(oContainer, oLastOpener);
        }
        else if(nWeapon == BASE_ITEM_WARHAMMER)
        {
            CreateWarhammer(oContainer, oLastOpener);
        }
        else if(nWeapon == BASE_ITEM_DWARVENWARAXE)
        {
            CreateDwarvenWaraxe(oContainer, oLastOpener);
        }
        else if(nWeapon == BASE_ITEM_WHIP)
        {
            CreateWhip(oContainer, oLastOpener);
        }
        else if(nWeapon == BASE_ITEM_TRIDENT)
        {
            CreateTrident(oContainer, oLastOpener);
        }
    }
    else
    {
        int nClass = GetClassByPosition(1,oLastOpener);
        // * if get to this point then the PC did not have Weapon Focus
        // * in anything then do additional logic to give an appropriate weapon
        if(nClass == CLASS_TYPE_DRUID)
        {
            CreateSpecificDruidWeapon(oContainer, oLastOpener);
        }
        else if(nClass == CLASS_TYPE_WIZARD)
        {
            CreateSpecificWizardWeapon(oContainer, oLastOpener);
        }
        else if(nClass == CLASS_TYPE_PALADIN || nClass == CLASS_TYPE_FIGHTER || nClass == CLASS_TYPE_RANGER)
        {
            CreateLongSword(oContainer, oLastOpener);
        }
        else if(nClass == CLASS_TYPE_BARBARIAN)
        {
            CreateGreatAxe(oContainer, oLastOpener);
        }
        else if(nClass == CLASS_TYPE_MONK)
        {
            CreateSpecificMonkWeapon(oContainer, oLastOpener);
        }
        else if(nClass == CLASS_TYPE_CLERIC)
        {
            CreateLightMace(oContainer, oLastOpener);
        }
        else if(nClass == CLASS_TYPE_ROGUE || nClass == CLASS_TYPE_BARD)
        {
            CreateShortsword(oContainer, oLastOpener);
        }
        else //if(nClass == CLASS_TYPE_SORCERER)
        {
            CreateDagger(oContainer, oLastOpener);
        }
    }
}


void InitWeaponFocusArray(object oLastOpener)
{
SetLocalInt(OBJECT_SELF,"ARRAY_WF",0);
int nTh;
    if(GetHasFeat(FEAT_WEAPON_FOCUS_BASTARD_SWORD, oLastOpener) || GetHasFeat(FEAT_IMPROVED_CRITICAL_BASTARD_SWORD, oLastOpener))
    {
    SetLocalInt(OBJECT_SELF,"ARRAY_WF",++nTh);
    SetLocalInt(OBJECT_SELF,"ARRAY_WF_"+IntToString(nTh),BASE_ITEM_BASTARDSWORD);
    }
    if(GetHasFeat(FEAT_WEAPON_FOCUS_BATTLE_AXE,oLastOpener) || GetHasFeat(FEAT_IMPROVED_CRITICAL_BATTLE_AXE, oLastOpener))
    {
    SetLocalInt(OBJECT_SELF,"ARRAY_WF",++nTh);
    SetLocalInt(OBJECT_SELF,"ARRAY_WF_"+IntToString(nTh),BASE_ITEM_BATTLEAXE);
    }
    if(GetHasFeat(FEAT_WEAPON_FOCUS_CLUB,oLastOpener) || GetHasFeat(FEAT_IMPROVED_CRITICAL_CLUB, oLastOpener))
    {
    SetLocalInt(OBJECT_SELF,"ARRAY_WF",++nTh);
    SetLocalInt(OBJECT_SELF,"ARRAY_WF_"+IntToString(nTh),BASE_ITEM_CLUB);
    }
    if(GetHasFeat(FEAT_WEAPON_FOCUS_DAGGER,oLastOpener) || GetHasFeat(FEAT_IMPROVED_CRITICAL_DAGGER, oLastOpener))
    {
    SetLocalInt(OBJECT_SELF,"ARRAY_WF",++nTh);
    SetLocalInt(OBJECT_SELF,"ARRAY_WF_"+IntToString(nTh),BASE_ITEM_DAGGER);
    }
    if(GetHasFeat(FEAT_WEAPON_FOCUS_DART,oLastOpener) || GetHasFeat(FEAT_IMPROVED_CRITICAL_DART, oLastOpener))
    {
    SetLocalInt(OBJECT_SELF,"ARRAY_WF",++nTh);
    SetLocalInt(OBJECT_SELF,"ARRAY_WF_"+IntToString(nTh),BASE_ITEM_DART);
    }
    if(GetHasFeat(FEAT_WEAPON_FOCUS_DIRE_MACE,oLastOpener) || GetHasFeat(FEAT_IMPROVED_CRITICAL_DIRE_MACE, oLastOpener))
    {
    SetLocalInt(OBJECT_SELF,"ARRAY_WF",++nTh);
    SetLocalInt(OBJECT_SELF,"ARRAY_WF_"+IntToString(nTh),BASE_ITEM_DIREMACE);
    }
    if(GetHasFeat(FEAT_WEAPON_FOCUS_DOUBLE_AXE,oLastOpener) || GetHasFeat(FEAT_IMPROVED_CRITICAL_DOUBLE_AXE, oLastOpener))
    {
    SetLocalInt(OBJECT_SELF,"ARRAY_WF",++nTh);
    SetLocalInt(OBJECT_SELF,"ARRAY_WF_"+IntToString(nTh),BASE_ITEM_DOUBLEAXE);
    }
    if(GetHasFeat(FEAT_WEAPON_FOCUS_GREAT_AXE,oLastOpener) || GetHasFeat(FEAT_IMPROVED_CRITICAL_GREAT_AXE, oLastOpener))
    {
    SetLocalInt(OBJECT_SELF,"ARRAY_WF",++nTh);
    SetLocalInt(OBJECT_SELF,"ARRAY_WF_"+IntToString(nTh),BASE_ITEM_GREATAXE);
    }
    if(GetHasFeat(FEAT_WEAPON_FOCUS_GREAT_SWORD,oLastOpener) || GetHasFeat(FEAT_IMPROVED_CRITICAL_GREAT_SWORD, oLastOpener))
    {
    SetLocalInt(OBJECT_SELF,"ARRAY_WF",++nTh);
    SetLocalInt(OBJECT_SELF,"ARRAY_WF_"+IntToString(nTh),BASE_ITEM_GREATSWORD);
    }
    if(GetHasFeat(FEAT_WEAPON_FOCUS_HALBERD,oLastOpener) || GetHasFeat(FEAT_IMPROVED_CRITICAL_HALBERD, oLastOpener))
    {
    SetLocalInt(OBJECT_SELF,"ARRAY_WF",++nTh);
    SetLocalInt(OBJECT_SELF,"ARRAY_WF_"+IntToString(nTh),BASE_ITEM_HALBERD);
    }
    if(GetHasFeat(FEAT_WEAPON_FOCUS_HAND_AXE,oLastOpener) || GetHasFeat(FEAT_IMPROVED_CRITICAL_HAND_AXE, oLastOpener))
    {
    SetLocalInt(OBJECT_SELF,"ARRAY_WF",++nTh);
    SetLocalInt(OBJECT_SELF,"ARRAY_WF_"+IntToString(nTh),BASE_ITEM_HANDAXE);
    }
    if(GetHasFeat(FEAT_WEAPON_FOCUS_HEAVY_CROSSBOW,oLastOpener) || GetHasFeat(FEAT_IMPROVED_CRITICAL_HEAVY_CROSSBOW, oLastOpener))
    {
    SetLocalInt(OBJECT_SELF,"ARRAY_WF",++nTh);
    SetLocalInt(OBJECT_SELF,"ARRAY_WF_"+IntToString(nTh),BASE_ITEM_HEAVYCROSSBOW);
    }
    if(GetHasFeat(FEAT_WEAPON_FOCUS_HEAVY_FLAIL,oLastOpener) || GetHasFeat(FEAT_IMPROVED_CRITICAL_HEAVY_FLAIL, oLastOpener))
    {
    SetLocalInt(OBJECT_SELF,"ARRAY_WF",++nTh);
    SetLocalInt(OBJECT_SELF,"ARRAY_WF_"+IntToString(nTh),BASE_ITEM_HEAVYFLAIL);
    }
    if(GetHasFeat(FEAT_WEAPON_FOCUS_KAMA,oLastOpener) || GetHasFeat(FEAT_IMPROVED_CRITICAL_KAMA, oLastOpener))
    {
    SetLocalInt(OBJECT_SELF,"ARRAY_WF",++nTh);
    SetLocalInt(OBJECT_SELF,"ARRAY_WF_"+IntToString(nTh),BASE_ITEM_KAMA);
    }
    if(GetHasFeat(FEAT_WEAPON_FOCUS_KATANA,oLastOpener) || GetHasFeat(FEAT_IMPROVED_CRITICAL_KATANA, oLastOpener))
    {
    SetLocalInt(OBJECT_SELF,"ARRAY_WF",++nTh);
    SetLocalInt(OBJECT_SELF,"ARRAY_WF_"+IntToString(nTh),BASE_ITEM_KATANA);
    }
    if(GetHasFeat(FEAT_WEAPON_FOCUS_KUKRI,oLastOpener) || GetHasFeat(FEAT_IMPROVED_CRITICAL_KUKRI, oLastOpener))
    {
    SetLocalInt(OBJECT_SELF,"ARRAY_WF",++nTh);
    SetLocalInt(OBJECT_SELF,"ARRAY_WF_"+IntToString(nTh),BASE_ITEM_KUKRI);
    }
    if(GetHasFeat(FEAT_WEAPON_FOCUS_LIGHT_CROSSBOW,oLastOpener) || GetHasFeat(FEAT_IMPROVED_CRITICAL_LIGHT_CROSSBOW, oLastOpener))
    {
    SetLocalInt(OBJECT_SELF,"ARRAY_WF",++nTh);
    SetLocalInt(OBJECT_SELF,"ARRAY_WF_"+IntToString(nTh),BASE_ITEM_LIGHTCROSSBOW);
    }
    if(GetHasFeat(FEAT_WEAPON_FOCUS_LIGHT_FLAIL,oLastOpener) || GetHasFeat(FEAT_IMPROVED_CRITICAL_LIGHT_FLAIL, oLastOpener))
    {
    SetLocalInt(OBJECT_SELF,"ARRAY_WF",++nTh);
    SetLocalInt(OBJECT_SELF,"ARRAY_WF_"+IntToString(nTh),BASE_ITEM_LIGHTFLAIL);
    }
    if(GetHasFeat(FEAT_WEAPON_FOCUS_LIGHT_HAMMER,oLastOpener) || GetHasFeat(FEAT_IMPROVED_CRITICAL_LIGHT_HAMMER, oLastOpener))
    {
    SetLocalInt(OBJECT_SELF,"ARRAY_WF",++nTh);
    SetLocalInt(OBJECT_SELF,"ARRAY_WF_"+IntToString(nTh),BASE_ITEM_LIGHTHAMMER);
    }
    if(GetHasFeat(FEAT_WEAPON_FOCUS_LIGHT_MACE,oLastOpener) || GetHasFeat(FEAT_IMPROVED_CRITICAL_LIGHT_MACE, oLastOpener))
    {
    SetLocalInt(OBJECT_SELF,"ARRAY_WF",++nTh);
    SetLocalInt(OBJECT_SELF,"ARRAY_WF_"+IntToString(nTh),BASE_ITEM_LIGHTMACE);
    }
    if(GetHasFeat(FEAT_WEAPON_FOCUS_LONG_SWORD,oLastOpener) || GetHasFeat(FEAT_IMPROVED_CRITICAL_LONG_SWORD, oLastOpener))
    {
    SetLocalInt(OBJECT_SELF,"ARRAY_WF",++nTh);
    SetLocalInt(OBJECT_SELF,"ARRAY_WF_"+IntToString(nTh),BASE_ITEM_LONGSWORD);
    }
    if(GetHasFeat(FEAT_WEAPON_FOCUS_LONGBOW,oLastOpener) || GetHasFeat(FEAT_IMPROVED_CRITICAL_LONGBOW, oLastOpener))
    {
    SetLocalInt(OBJECT_SELF,"ARRAY_WF",++nTh);
    SetLocalInt(OBJECT_SELF,"ARRAY_WF_"+IntToString(nTh),BASE_ITEM_LONGBOW);
    }
    if(GetHasFeat(FEAT_WEAPON_FOCUS_MORNING_STAR,oLastOpener) || GetHasFeat(FEAT_IMPROVED_CRITICAL_MORNING_STAR, oLastOpener))
    {
    SetLocalInt(OBJECT_SELF,"ARRAY_WF",++nTh);
    SetLocalInt(OBJECT_SELF,"ARRAY_WF_"+IntToString(nTh),BASE_ITEM_MORNINGSTAR);
    }
    if(GetHasFeat(FEAT_WEAPON_FOCUS_RAPIER,oLastOpener) || GetHasFeat(FEAT_IMPROVED_CRITICAL_RAPIER, oLastOpener))
    {
    SetLocalInt(OBJECT_SELF,"ARRAY_WF",++nTh);
    SetLocalInt(OBJECT_SELF,"ARRAY_WF_"+IntToString(nTh),BASE_ITEM_RAPIER);
    }
    if(GetHasFeat(FEAT_WEAPON_FOCUS_SCIMITAR,oLastOpener) || GetHasFeat(FEAT_IMPROVED_CRITICAL_SCIMITAR, oLastOpener))
    {
    SetLocalInt(OBJECT_SELF,"ARRAY_WF",++nTh);
    SetLocalInt(OBJECT_SELF,"ARRAY_WF_"+IntToString(nTh),BASE_ITEM_SCIMITAR);
    }
    if(GetHasFeat(FEAT_WEAPON_FOCUS_SCYTHE,oLastOpener) || GetHasFeat(FEAT_IMPROVED_CRITICAL_SCYTHE, oLastOpener))
    {
    SetLocalInt(OBJECT_SELF,"ARRAY_WF",++nTh);
    SetLocalInt(OBJECT_SELF,"ARRAY_WF_"+IntToString(nTh),BASE_ITEM_SCYTHE);
    }
    if(GetHasFeat(FEAT_WEAPON_FOCUS_SHORT_SWORD,oLastOpener) || GetHasFeat(FEAT_IMPROVED_CRITICAL_SHORT_SWORD, oLastOpener))
    {
    SetLocalInt(OBJECT_SELF,"ARRAY_WF",++nTh);
    SetLocalInt(OBJECT_SELF,"ARRAY_WF_"+IntToString(nTh),BASE_ITEM_SHORTSWORD);
    }
    if(GetHasFeat(FEAT_WEAPON_FOCUS_SHORTBOW,oLastOpener) || GetHasFeat(FEAT_IMPROVED_CRITICAL_SHORTBOW, oLastOpener))
    {
    SetLocalInt(OBJECT_SELF,"ARRAY_WF",++nTh);
    SetLocalInt(OBJECT_SELF,"ARRAY_WF_"+IntToString(nTh),BASE_ITEM_SHORTBOW);
    }
    if(GetHasFeat(FEAT_WEAPON_FOCUS_SHURIKEN,oLastOpener) || GetHasFeat(FEAT_IMPROVED_CRITICAL_SHURIKEN, oLastOpener))
    {
    SetLocalInt(OBJECT_SELF,"ARRAY_WF",++nTh);
    SetLocalInt(OBJECT_SELF,"ARRAY_WF_"+IntToString(nTh),BASE_ITEM_SHURIKEN);
    }
    if(GetHasFeat(FEAT_WEAPON_FOCUS_SICKLE,oLastOpener) || GetHasFeat(FEAT_IMPROVED_CRITICAL_SICKLE, oLastOpener))
    {
    SetLocalInt(OBJECT_SELF,"ARRAY_WF",++nTh);
    SetLocalInt(OBJECT_SELF,"ARRAY_WF_"+IntToString(nTh),BASE_ITEM_SICKLE);
    }
    if(GetHasFeat(FEAT_WEAPON_FOCUS_SLING,oLastOpener) || GetHasFeat(FEAT_IMPROVED_CRITICAL_SLING, oLastOpener))
    {
    SetLocalInt(OBJECT_SELF,"ARRAY_WF",++nTh);
    SetLocalInt(OBJECT_SELF,"ARRAY_WF_"+IntToString(nTh),BASE_ITEM_SLING);
    }
    if(GetHasFeat(FEAT_WEAPON_FOCUS_SPEAR,oLastOpener) || GetHasFeat(FEAT_IMPROVED_CRITICAL_SPEAR, oLastOpener))
    {
    SetLocalInt(OBJECT_SELF,"ARRAY_WF",++nTh);
    SetLocalInt(OBJECT_SELF,"ARRAY_WF_"+IntToString(nTh),BASE_ITEM_SHORTSPEAR);
    }
    if(GetHasFeat(FEAT_WEAPON_FOCUS_STAFF,oLastOpener) || GetHasFeat(FEAT_IMPROVED_CRITICAL_STAFF, oLastOpener))
    {
    SetLocalInt(OBJECT_SELF,"ARRAY_WF",++nTh);
    SetLocalInt(OBJECT_SELF,"ARRAY_WF_"+IntToString(nTh),BASE_ITEM_QUARTERSTAFF);
    }
    if(GetHasFeat(FEAT_WEAPON_FOCUS_THROWING_AXE,oLastOpener) || GetHasFeat(FEAT_IMPROVED_CRITICAL_THROWING_AXE, oLastOpener))
    {
    SetLocalInt(OBJECT_SELF,"ARRAY_WF",++nTh);
    SetLocalInt(OBJECT_SELF,"ARRAY_WF_"+IntToString(nTh),BASE_ITEM_THROWINGAXE);
    }
    if(GetHasFeat(FEAT_WEAPON_FOCUS_TWO_BLADED_SWORD,oLastOpener) || GetHasFeat(FEAT_IMPROVED_CRITICAL_TWO_BLADED_SWORD, oLastOpener))
    {
    SetLocalInt(OBJECT_SELF,"ARRAY_WF",++nTh);
    SetLocalInt(OBJECT_SELF,"ARRAY_WF_"+IntToString(nTh),BASE_ITEM_TWOBLADEDSWORD);
    }
    if(GetHasFeat(FEAT_WEAPON_FOCUS_WAR_HAMMER,oLastOpener) || GetHasFeat(FEAT_IMPROVED_CRITICAL_WAR_HAMMER, oLastOpener))
    {
    SetLocalInt(OBJECT_SELF,"ARRAY_WF",++nTh);
    SetLocalInt(OBJECT_SELF,"ARRAY_WF_"+IntToString(nTh),BASE_ITEM_WARHAMMER);
    }
    if(GetHasFeat(FEAT_WEAPON_FOCUS_DWAXE,oLastOpener) || GetHasFeat(FEAT_IMPROVED_CRITICAL_DWAXE, oLastOpener))
    { //dwarven waraxe - added in expansion
    SetLocalInt(OBJECT_SELF,"ARRAY_WF",++nTh);
    SetLocalInt(OBJECT_SELF,"ARRAY_WF_"+IntToString(nTh),BASE_ITEM_DWARVENWARAXE);
    }
    if(GetHasFeat(FEAT_WEAPON_FOCUS_WHIP,oLastOpener) || GetHasFeat(FEAT_IMPROVED_CRITICAL_WHIP, oLastOpener))
    { //whip - added in expansion
    SetLocalInt(OBJECT_SELF,"ARRAY_WF",++nTh);
    SetLocalInt(OBJECT_SELF,"ARRAY_WF_"+IntToString(nTh),BASE_ITEM_WHIP);
    }
    if(GetHasFeat(FEAT_WEAPON_FOCUS_TRIDENT,oLastOpener) || GetHasFeat(FEAT_IMPROVED_CRITICAL_TRIDENT, oLastOpener))
    { //trident - added in patch 1.69
    SetLocalInt(OBJECT_SELF,"ARRAY_WF",++nTh);
    SetLocalInt(OBJECT_SELF,"ARRAY_WF_"+IntToString(nTh),BASE_ITEM_TRIDENT);
    }
}
