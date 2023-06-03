void main()
{
// stealth
   SetTlkOverride(40067, "While in Stealth mode, your character is nearly undetectable. Creatures will roll Listen and Spot checks versus your Move Silently and Hide skills. If you fail the skill check, you will be noticed by them.");

// flurry of blows
   SetTlkOverride(6026,
                  "Type of Feat: Class\n" +
                  "Prerequisite: Monk level 1.\n" +
                  "Specifics: Monks receive an extra attack per round when fighting with unarmed attacks, kamas, quarterstaves, or shurikens. However, all attacks in that round suffer a -2 attack penalty.\n" +
                  "Use: Combat.");

// barkskin
   SetTlkOverride(6099,
                  "Caster Level(s): Druid 2\n" +
                  "Innate Level: 2\n" +
                  "School: Transmutation\n" +
                  "Descriptor(s): None\n" +
                  "Component(s): Verbal, Somatic\n" +
                  "Range: Touch\n" +
                  "Area of Effect / Target: Single\n" +
                  "Duration: 1 Hour / Level\n" +
                  "Additional Counter Spells:\n" +
                  "Save: Harmless\n" +
                  "Spell Resistance: No\n" +
                  "\n" +
                  "Barkskin hardens the target creature's skin, granting a natural armor bonus to Armor Class based on the caster's level:\n" +
                  "Level 1-6: +2\n" +
                  "Level 7-12: +3\n" +
                  "Levels 13+: +4");

// darkfire
   SetTlkOverride(3782,
                  "Caster Level(s): Cleric 3\n" +
                  "Innate Level: 3\n" +
                  "School: Evocation\n" +
                  "Descriptor(s): Fire\n" +
                  "Component(s): Verbal, Somatic\n" +
                  "Range: Touch\n" +
                  "Area of Effect / Target: Creature, Melee Weapon\n" +
                  "Duration: 1 Hour / Level\n" +
                  "Additional Counter Spells:\n" +
                  "Save: None\n" +
                  "Spell Resistance: No\n" +
                  "\n" +
                  "This spell allows the caster to immolate a non-magical weapon. The weapon will do 1d6 points of fire damage. The caster can either target a specific melee weapon in his inventory or a creature to enchant the weapon the creature is wielding.");

// flame weapon
   SetTlkOverride(3764,
                  "Caster Level(s): Wizard / Sorcerer 2\n" +
                   "Innate Level: 2\n" +
                   "School: Evocation\n" +
                   "Descriptor(s): Weapon Enchantment\n" +
                   "Component(s): Verbal, Somatic\n" +
                   "Range: Touch\n" +
                   "Area of Effect / Target: Creature or Melee Weapon\n" +
                   "Duration: 1 Minute / Level\n" +
                   "Additional Counter Spells:\n" +
                   "Save: None\n" +
                   "Spell Resistance: No\n" +
                   "\n" +
                   "Sets a melee weapon aflame, granting 1d4 points of fire damage. You can target a specific weapon or a creature with this spell.");

// divine favor
   SetTlkOverride(54,
                  "Caster Level(s): Cleric 1, Paladin 1\n" +
                   "Innate Level: 1\n" +
                   "School: Evocation\n" +
                   "Descriptor(s):\n" +
                   "Component(s): Verbal, Somatic\n" +
                   "Range: Personal\n" +
                   "Area of Effect / Target: Caster\n" +
                   "Duration: 1 Turn\n" +
                   "Additional Counter Spells:\n" +
                   "Save: None\n" +
                   "Spell Resistance: No\n" +
                   "\n" +
                   "The caster gains a +1 bonus to attack and weapon damage rolls for every four caster levels (at least +1, to a maximum of +5).");
// gmw
   SetTlkOverride(3769,
                  "Caster Level(s): Bard 3, Cleric 4, Paladin 3, Wizard / Sorcerer 3\n" +
                  "Innate Level: 3\n" +
                  "School: Transmutation\n" +
                  "Descriptor(s): Weapon Enchantment\n" +
                  "Component(s): Verbal, Somatic\n" +
                  "Range: Short\n" +
                  "Area of Effect / Target: Creature or  Melee Weapon\n" +
                  "Duration: 1 Hour / Level\n" +
                  "Additional Counter Spells:\n" +
                  "Save: None\n" +
                  "Spell Resistance: No\n" +
                  "\n" +
                  "You empower the touched weapon with a +2 enhancement bonus. You can either directly target the weapon you want to cast this spell on, or you can target a creature, affecting the creature's main hand weapon.");

// magic vestment
   SetTlkOverride(3772,
                  "Caster Level(s): Cleric 3\n" +
                  "Innate Level: 3\n" +
                  "School: Transmutation\n" +
                  "Descriptor(s): Armor Enchantment\n" +
                  "Component(s): Verbal, Somatic\n" +
                  "Range: Touch\n" +
                  "Area of Effect / Target: Creature, Armor or Shield\n" +
                  "Duration: 1 Hour / Level\n" +
                  "Additional Counter Spells:\n" +
                  "Save: None\n" +
                  "Spell Resistance: No\n" +
                  "\n" +
                  "You empower the touched armor or shield with a +1 AC bonus per 4 caster levels (maximum of +5).");

// forceful hand
   SetTlkOverride(2689,
                  "Caster Level(s): Wizard / Sorcerer 6\n" +
                  "Innate Level: 6\n" +
                  "School: Evocation\n" +
                  "Descriptor(s):\n" +
                  "Component(s): Verbal, Somatic\n" +
                  "Range: Long\n" +
                  "Area of Effect / Target: Single\n" +
                  "Duration: 1 round / level\n" +
                  "Additional Counter Spells:\n" +
                  "Save: None\n" +
                  "Spell Resistance: Yes\n" +
                  "\n" +
                  "A giant hand appears and attempts to bull rush one target. The hand gains a +9 bonus on the Strength check. A target that is bull rushed is knocked down and is dazed for the duration of the spell.");

// circle of death
   SetTlkOverride(6114,
                  "Caster Level(s): Wizard / Sorcerer 6\n" +
                  "Innate Level: 6\n" +
                  "School: Necromancy\n" +
                  "Descriptor(s): Death\n" +
                  "Component(s): Verbal, Somatic\n" +
                  "Range: Medium\n" +
                  "Area of Effect / Target: Colossal\n" +
                  "Duration: Instant\n" +
                  "Additional Counter Spells: Death Ward\n" +
                  "Save: Fortitude Negates\n" +
                  "Spell Resistance: Yes\n" +
                  "\n" +
                  "A wave of negative energy bursts from the target location. A number of enemy creatures equal to 1d4 per caster level must make a Fortitude save or die, beginning with those creatures with the lowest Hit Dice.");

// greater sanctuary
   SetTlkOverride(2371,
                  "Caster Level(s): Cleric 6, Wizard / Sorcerer 8\n" +
                  "Innate Level: 7\n" +
                  "School: Transmutation\n" +
                  "Descriptor(s):\n" +
                  "Component(s): Verbal, Somatic\n" +
                  "Range: Personal\n" +
                  "Area of Effect / Target: Caster\n" +
                  "Duration: 1 round / level\n" +
                  "Additional Counter Spells:\n" +
                  "Save: None\n" +
                  "Spell Resistance: No\n" +
                  "\n" +
                  "The caster becomes ethereal. No other creature can detect the caster. Attacking or performing a hostile action will make the etherealness vanish.\n" +
                  "\n" +
                  "This spell is subject to a diminishing return, capped at 25% duration. This is reset when the affected creature rests.");

// true seeing
   SetTlkOverride(6518,
                  "Caster Level(s): Cleric 5, Druid 7, Wizard / Sorcerer 6\n" +
                  "Innate Level: 5\n" +
                  "School: Divination\n" +
                  "Descriptor(s):\n" +
                  "Component(s): Verbal, Somatic\n" +
                  "Range: Touch\n" +
                  "Area of Effect / Target: Single\n" +
                  "Duration: 1 Turn / Level\n" +
                  "Additional Counter Spells: Greater Shadow Conjuration\n" +
                  "Save: Harmless\n" +
                  "Spell Resistance: No\n" +
                  "\n" +
                  "The target creature can see through Darkness and Invisibility effects, and gains a +20 bonus to all spot and search checks.");
// find traps
   SetTlkOverride(6544,
                  "Caster Level(s): Bard 3, Cleric 2, Wizard / Sorcerer 3\n" +
                  "Innate Level: 2\n" +
                  "School: Divination\n" +
                  "Descriptor(s):\n" +
                  "Component(s): Verbal, Somatic\n" +
                  "Range: Personal\n" +
                  "Area of Effect / Target: Colossal\n" +
                  "Duration: Instant\n" +
                  "Additional Counter Spells:\n" +
                  "Save: Harmless\n" +
                  "Spell Resistance: No\n" +
                  "\n" +
                  "All traps within the area of effect become known to the caster of this spell and are attempted to be disarmed.");

// knock
   SetTlkOverride(6190,
                  "Caster Level(s): Wizard / Sorcerer 2\n" +
                  "Innate Level: 2\n" +
                  "School: Transmutation\n" +
                  "Descriptor(s):\n" +
                  "Component(s): Verbal\n" +
                  "Range: Personal\n" +
                  "Area of Effect / Target: Colossal\n" +
                  "Duration: Instant\n" +
                  "Additional Counter Spells:\n" +
                  "Save: None\n" +
                  "Spell Resistance: No\n" +
                  "\n" +
                  "This spell will attempt to unlock doors and containers sealed by conventional locks in a 150ft radius around the caster. Exceptionally complex locking mechanisms or magically sealed doors and containers are beyond the abilities of this spell.");


   string sDiminishingReturn = "The invisibility effect is subject to a diminishing return, capped at 25% duration. This is reset when the affected creature rests.";

// improved invis
    SetTlkOverride(6185, GetStringByStrRef(6185) + "\n" + sDiminishingReturn);

// invis
    SetTlkOverride(6187, GetStringByStrRef(6187) + "\n" + sDiminishingReturn);

// invis sphere
    SetTlkOverride(6189, GetStringByStrRef(6189) + "\n" + sDiminishingReturn);
}
