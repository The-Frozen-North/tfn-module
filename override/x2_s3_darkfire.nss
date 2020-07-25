//::///////////////////////////////////////////////
//:: OnHit Darkfire
//:: x2_s3_darkfire
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*

   OnHit Castspell Fire Damage property for the
   flaming weapon spell (x2_s0_flmeweap).

   We need to use this property because we can not
   add random elemental damage to a weapon in any
   other way and implementation should be as close
   as possible to the book.

   Behavior:
   The casterlevel is set as a variable on the
   weapon, so if players leave and rejoin, it
   is lost (and the script will just assume a
   minimal caster level).


*/
//:://////////////////////////////////////////////
//:: Created By: Georg Zoeller
//:: Created On: 2003-07-17
//:://////////////////////////////////////////////

void main()
{
  // Get Caster Level
  int nLevel = GetCasterLevel(OBJECT_SELF);
  //1.72: support for damage type override
  int nDmgVfxS, nDmgVfxL, nDamageType = GetLocalInt(GetSpellCastItem(),IntToString(SPELL_FLAME_WEAPON)+"_DAMAGE_TYPE");
  switch(nDamageType)
  {
  case DAMAGE_TYPE_ACID: nDmgVfxS = VFX_IMP_ACID_S; nDmgVfxL = VFX_IMP_ACID_L; break;
  case DAMAGE_TYPE_ELECTRICAL: nDmgVfxS = VFX_IMP_LIGHTNING_S; nDmgVfxL = VFX_IMP_LIGHTNING_M; break;
  case DAMAGE_TYPE_SONIC: nDmgVfxS = VFX_IMP_SONIC; nDmgVfxL = VFX_IMP_SONIC; break;
  case DAMAGE_TYPE_COLD: nDmgVfxS = VFX_IMP_FROST_S; nDmgVfxL = VFX_IMP_FROST_L; break;
  case DAMAGE_TYPE_DIVINE: nDmgVfxS = VFX_IMP_SUNSTRIKE; nDmgVfxL = VFX_IMP_SUNSTRIKE; break;
  case DAMAGE_TYPE_NEGATIVE: nDmgVfxS = VFX_IMP_NEGATIVE_ENERGY; nDmgVfxL = VFX_IMP_NEGATIVE_ENERGY; break;
  case DAMAGE_TYPE_POSITIVE: nDmgVfxS = VFX_IMP_SUNSTRIKE; nDmgVfxL = VFX_IMP_SUNSTRIKE; break;
  case DAMAGE_TYPE_MAGICAL: nDmgVfxS = VFX_IMP_MAGBLUE; nDmgVfxL = VFX_IMP_MAGBLUE; break;
  case DAMAGE_TYPE_PIERCING: case DAMAGE_TYPE_SLASHING: case DAMAGE_TYPE_BLUDGEONING: nDmgVfxS = VFX_COM_BLOOD_REG_RED; nDmgVfxL = VFX_COM_BLOOD_LRG_RED; break;
  default: nDamageType = DAMAGE_TYPE_FIRE; nDmgVfxS = VFX_IMP_FLAME_S; nDmgVfxL = VFX_IMP_FLAME_M; break;
  }

  int nDmg = d6() + (nLevel/2);

  effect eDmg = EffectDamage(nDmg,nDamageType);
  effect eVis;
  if (nDmg<10) // if we are doing below 12 point of damage, use small flame
  {
    eVis =EffectVisualEffect(nDmgVfxS);
  }
  else
  {
     eVis =EffectVisualEffect(nDmgVfxL);
  }
  eDmg = EffectLinkEffects (eVis, eDmg);
  object oTarget = GetSpellTargetObject();

  if (GetIsObjectValid(oTarget))
  {
      ApplyEffectToObject(DURATION_TYPE_INSTANT, eDmg, oTarget);
  }
}
