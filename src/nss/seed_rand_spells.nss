#include "nwnx_util"
#include "nw_inc_gff"
#include "inc_rand_spell"
#include "inc_array"

// If not seeding areas/treasures, the server is really laggy to start with
// And so a pretty big value of this is needed for the first few...
const int SEED_SPELLBOOK_COUNT_TIMEOUTS = 300;

void SpellbookSeedLoop(int nPos=-1, int nCounts=0)
{
    object oOld = GetLocalObject(GetModule(), "spellbook_seed_last_creature");
    if (GetLocalInt(oOld, "seed_spellbook_complete") || nPos == -1 || nCounts > SEED_SPELLBOOK_COUNT_TIMEOUTS)
    {
        if (nCounts % 100 == 0 && nCounts > 0)
        {
            WriteTimestampedLogEntry(GetName(oOld) + " (resref: " + GetResRef(oOld) + ") at " + IntToString(nCounts) + "of max " + IntToString(SEED_SPELLBOOK_COUNT_TIMEOUTS) + "...");
        }
        if (nCounts > SEED_SPELLBOOK_COUNT_TIMEOUTS)
        {
            WriteTimestampedLogEntry("WARNING: " + GetName(oOld) + " (resref: " + GetResRef(oOld) + ") hasn't signalled it is done seeding spellbooks after " + IntToString(SEED_SPELLBOOK_COUNT_TIMEOUTS) + " counts");
        }
        DestroyObject(oOld);
        nPos++;
        string sResRef = Array_At_Str("SEED_RAND_SPELLS", nPos);
        if (GetStringLength(sResRef) == 0)
        {
            // Tell on_mod_load that it's time to keep going (which currently just shuts down the server
            // but still...)
            WriteTimestampedLogEntry("Finished seeding spellbooks for  " + IntToString(nPos) + " UTCs!");
            SetLocalInt(GetModule(), "seeded_spellbooks", 1);
            return;
        }
        object oArea = GetObjectByTag("_ENCOUNTERS");
        location lSpawn = Location(oArea, Vector(10.0, 10.0, 0.0), 0.0);
        object oNew = CreateObject(OBJECT_TYPE_CREATURE, sResRef, lSpawn);
        WriteTimestampedLogEntry("Beginning spellbook seed for " + sResRef + " -> " + GetName(oNew));
        nCounts = 0;
        SetLocalObject(GetModule(), "spellbook_seed_last_creature", oNew);
    }
    DelayCommand(1.0, SpellbookSeedLoop(nPos, nCounts+1));
}

void main()
{
    NWNX_Util_SetInstructionLimit(52428888);
    DestroyCampaignDatabase("randspellbooks");
    SetLocalInt(GetModule(), RAND_SPELL_SEEDING_SPELLBOOKS, 1);
    string sResRef = NWNX_Util_GetFirstResRef(NWNX_UTIL_RESREF_TYPE_CREATURE, "", TRUE);
    while (GetStringLength(sResRef) > 0)
    {
        json jUTC = TemplateToJson(sResRef, RESTYPE_UTC);
        json jVarTable = GffGetList(jUTC, "VarTable");
        int nPos = 0;
        int bSeedSpellbook = 0;
        string sSpawnScript = "";
        int nSize = JsonGetLength(jVarTable);
        for (nPos=0; nPos<nSize; nPos++)
        {
            json jStruct = JsonArrayGet(jVarTable, nPos);
            string sVarName = JsonGetString(GffGetString(jStruct, "Name"));
            if (sVarName == "seed_spellbook")
            {
                bSeedSpellbook = 1;
            }
            if (sVarName == "spawn_script")
            {
                sSpawnScript = JsonGetString(GffGetString(jStruct, "Value"));
            }
            
            if (bSeedSpellbook && GetStringLength(sSpawnScript) > 0)
            {
                WriteTimestampedLogEntry("Creature needs spellbooks seeded: " + sResRef);
                Array_PushBack_Str("SEED_RAND_SPELLS", sResRef);
            }
        }
        sResRef = NWNX_Util_GetNextResRef();
    }
    
    DelayCommand(0.0, SpellbookSeedLoop());
}