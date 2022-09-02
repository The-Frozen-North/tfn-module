#include "x0_i0_spells"
#include "inc_quest"

void main()
{
    if (!GetLocalInt(OBJECT_SELF, "UDObeliskHasPlayers"))
	{
		return;
	}
	object oTest = GetFirstObjectInArea(OBJECT_SELF);
    int nTrapPulses = GetLocalInt(OBJECT_SELF, "UDObeliskTrapTriggered");
	int bHasPlayer = 0;
    int bCompleted = GetLocalInt(OBJECT_SELF, "UDObeliskPuzzleComplete");
    int nGridSize = GetLocalInt(OBJECT_SELF, "PUZZLE_GRID_SIZE");
	while (GetIsObjectValid(oTest))
	{
		if (GetIsPC(oTest) || GetIsDM(oTest))
		{
			bHasPlayer = 1;
		}
        
        if (!GetIsDead(oTest))
        {
            if (nTrapPulses > 0 && GetObjectType(oTest) == OBJECT_TYPE_CREATURE && !bCompleted)
            {
                int nDamage;
                if (nGridSize == 5)
                {
                    nDamage = d4() + Random(1 + min(30, nTrapPulses/5)) + nTrapPulses/5;
                }
                else
                {
                    nDamage = d4() + Random(1 + min(30, nTrapPulses/8)) + nTrapPulses/8;
                }
                int nChanceForConDrain = nTrapPulses;
                if (Random(100) < nChanceForConDrain)
                {
                    if (!FortitudeSave(oTest, 14, SAVING_THROW_TYPE_POISON))
                    {
                        effect eDmg = SupernaturalEffect(EffectAbilityDecrease(ABILITY_CONSTITUTION, 1));
                        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eDmg, oTest, HoursToSeconds(12)); 
                    }
                }
                ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(nDamage, DAMAGE_TYPE_ACID), oTest);
            }
            int bApplyDispel = 0;
            if (!GetIsPC(oTest))
            {
                if (GetQuestEntry(GetMaster(oTest), "q_beholder_prot") < 3) 
                {
                    bApplyDispel = 1;
                }
            }
            else if (GetQuestEntry(oTest, "q_beholder_prot") < 3) 
            {
                bApplyDispel = 1;
            }
            if (bApplyDispel)
            {
                effect eInvalid;
                if (!GetHasEffect(EFFECT_TYPE_SPELL_FAILURE, oTest))
                {
                    spellsDispelMagic(oTest, 40, eInvalid, eInvalid);
                    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, TagEffect(EffectSpellFailure(), "obelisk_spellfail"), oTest, 9999.0);
                }
            }
            else
            {
                effect eTest = GetFirstEffect(oTest);
                while (GetIsEffectValid(eTest))
                {
                    if (GetEffectCreator(eTest) == OBJECT_SELF && GetEffectType(eTest) == EFFECT_TYPE_SPELL_FAILURE && GetEffectTag(eTest) == "obelisk_spellfail")
                    {
                        RemoveEffect(oTest, eTest);
                        break;
                    }
                    eTest = GetNextEffect(oTest);
                }
            }
        }
        		
		oTest = GetNextObjectInArea(OBJECT_SELF);
	}
    if (nTrapPulses > 0)
    {
        SetLocalInt(OBJECT_SELF, "UDObeliskTrapTriggered", nTrapPulses + 1);
    }
    if (!bHasPlayer)
    {
        SetLocalInt(OBJECT_SELF, "UDObeliskHasPlayers", 0);
    }
}