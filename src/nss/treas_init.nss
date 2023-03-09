#include "inc_trap"
#include "inc_lock"
#include "inc_loot"
#include "inc_respawn"

void main()
{
    int nAreaCR = GetLocalInt(GetArea(OBJECT_SELF), "cr");
    int nCR = nAreaCR;
    
    // This needs to be here too to apply to dm-spawned treasures
    
    float fQualityMult = GetLocalFloat(OBJECT_SELF, "quality_mult");
    string sTreasureTier = GetLocalString(OBJECT_SELF, "treasure");
    if (fQualityMult <= 0.0) {
        if (sTreasureTier == "low") { fQualityMult = TREASURE_LOW_QUALITY; }
        else if (sTreasureTier == "medium") { fQualityMult = TREASURE_MEDIUM_QUALITY; }
        else if (sTreasureTier == "high") { fQualityMult = TREASURE_HIGH_QUALITY; }
        else { fQualityMult = 1.0; }
    }
    float fQuantityMult = GetLocalFloat(OBJECT_SELF, "quantity_mult");
    if (fQuantityMult <= 0.0) {
       if (sTreasureTier == "low") { fQuantityMult = TREASURE_LOW_QUANTITY; }
       else if (sTreasureTier == "medium") { fQuantityMult = TREASURE_MEDIUM_QUANTITY; }
       else if (sTreasureTier == "high") { fQuantityMult = TREASURE_HIGH_QUANTITY; }
       else { fQuantityMult = 1.0; }
    }
    
    SetLocalFloat(OBJECT_SELF, "quantity_mult", fQuantityMult);
    if (fQualityMult > 0.0)
    {
        nAreaCR = FloatToInt(IntToFloat(nAreaCR) * fQualityMult);
    }
    
    float fScale = GetLocalFloat(OBJECT_SELF, "scale");
    if (fScale > 0.0)
    {
        SetObjectVisualTransform(OBJECT_SELF, OBJECT_VISUAL_TRANSFORM_SCALE, fScale);
    }
    
    // This may be unused now
    SetLocalInt(OBJECT_SELF, "cr", nAreaCR);
    // This is most definitely used - reflects quality
    // If something overwrote this, leave the old values alone
    if (!GetLocalInt(OBJECT_SELF, "area_cr"))
    {
        SetLocalInt(OBJECT_SELF, "area_cr", nAreaCR);
    }

    SetEventScript(OBJECT_SELF, EVENT_SCRIPT_PLACEABLE_ON_DEATH, "treas_death");
    GenerateTrapOnObject();
    GenerateLockOnObject();
    SetSpawn();

    if (GetLocked(OBJECT_SELF))
    {
        SetEventScript(OBJECT_SELF, EVENT_SCRIPT_PLACEABLE_ON_MELEEATTACKED, "bash_lock");
        SetEventScript(OBJECT_SELF, EVENT_SCRIPT_PLACEABLE_ON_UNLOCK, "treas_unlock");
        SetEventScript(OBJECT_SELF, EVENT_SCRIPT_PLACEABLE_ON_USED, "treas_locked");
        SetPlotFlag(OBJECT_SELF, FALSE);
    }
    else
    {
        SetEventScript(OBJECT_SELF, EVENT_SCRIPT_PLACEABLE_ON_USED, "treas_fopen");
        SetPlotFlag(OBJECT_SELF, TRUE);
    }
}
