int StartingConditional()
{
    object oPC = GetPCSpeaker();

    if (!GetIsObjectValid(oPC)) return FALSE;

    int i;
    for (i = 1; i < 30; i++)
    {
        DeleteLocalString(OBJECT_SELF, "gossip"+IntToString(i));
    }

    int nCount = 0;
    string sResRef = GetResRef(OBJECT_SELF);
    object oArea = GetArea(OBJECT_SELF);
    string sAreaResRef = GetResRef(oArea);



// ====================================
// HIGHCLIFF VILLAGER
// ====================================
   if (sResRef == "guard_thunder")
   {
        nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "The people of Thundertree are under my protection, so you best watch yourself.");
        nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Move along. I'm currently on duty.");
        nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Don't cause any trouble here, or Ansal will hunt you down.");
        nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "This place is a safe haven. Let's keep it that way for the sake of us both.");
   }
// ====================================
// BLACKLAKE GUARD
// ====================================
   else if (sResRef == "blklakeguard")
   {
        nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "I'm paid well to keep order, not chit-chat.");
        nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Move along. I'm on duty.");
        nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "I used to be a city guard. Let's just say I moved to greener, and safer pastures.");
        nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Meldanen is quite generous. He took not only me in, but also my family as well.");
   }
// ====================================
// THUNDERTREE VILLAGER
// ====================================
   else if (sResRef == "villager_thunder")
   {
        nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Ain't much in this town for the likes of you.");
        nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Don't see much visitors 'round here. Best it stay that way.");
        nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "On your way Neverwinter Woods, are ya? Not the safest place in the North.");
        nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Camilla's the only shopkeep here. She does most of her business with strangers such as yourself, though.");
        nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "More visitors. Just what this village needs.");
   }
// ====================================
// HIGHCLIFF VILLAGER
// ====================================
   else if (sResRef == "villager")
   {
        nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "It's been a good harvest this season.");
        nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "At least I still have land to farm.");
        nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "All the carousing the sailors are doing, I'm surprised the elder hasn't had a talk with their captain.");
        nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Good day to be outside, isn't it?");
        nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "More visitors. Just what this village needs.");
        nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Bandits, lizardfolk, people going missing... it's been an interesting year.");
        nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Only blacksmith in town is Edorio. A timid man, but he is skilled in his craft.");
        nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Branson has some good wares, though I'm sure he overcharges the travellers. And you didn't hear that from me!");
        nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "The High Road's not safe these days. Lots of travelers just... disappear, south of Neverwinter. Can't find a trace of them.");
        nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Don't go into the Mere of Dead Men. It's named so for a reason.");
   }
// ====================================
// HIGHCLIFF GUARD
// ====================================
   else if (sResRef == "guard")
   {
        nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Yes yes, I'm quite busy.");
        nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Don't go starting any trouble.");
        nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "I've got my eye on you.");
        nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Sorry, but I'm on a duty.");
        nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "This blade seems quite stout, doesn't it? It's recently forged by Edorio.");
        nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "When's the next lizardmen raid, I wonder?");
        nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "This village is peaceful enough. And it best stay that way.");
        nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "If you need some general goods or are looking for a place to sell things, Branson is the only guy who will offer that in this village.");
        nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "I'd steer clear of the High Road if I were you. Lots of bandit activity, lately.");
        nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "My friend was sent on patrol to the Mere of Dead Men, once... never to be seen again.");
   }
// ====================================
// COURTESAN
// ====================================
   if (sResRef == "courtesan")
   {
        if (GetItemInSlot(INVENTORY_SLOT_CHEST, oPC) == OBJECT_INVALID) // naked
        {
            nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "You can't run around like *that*! Miss Ophala will have a fit!");
        }

        nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "You'll have to wait your turn.");
        nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Hello, I'm rather busy right now. Sorry.");
        nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "I don't know how Ophala keeps us free of the sickness, but she does.");


        if (GetAbilityScore(oPC, ABILITY_CHARISMA) >= 13) // high charisma
        {
            nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "*Sigh* Business has been a little *too* busy since the plague hit, you know what I mean... ?");
            nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "You're new to the Mask, aren't you? Well, I'm sure you'll like it... ");
        }

        if (GetAbilityScore(oPC, ABILITY_CHARISMA) <= 9) // low charisma
        {
            nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Go away, you plague-ridden filth!");
            nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "I don't have time for your like. You'll wait your turn.");
            nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Oh, by the gods! Must all the dregs of society come in here?");
        }
   }
// ====================================
// ANYONE ELSE IN MOONSTONE
// ====================================
    else if (GetStringLeft(sAreaResRef, 9) == "core_moon")
    {

        if (GetCurrentHitPoints(oPC) <= (GetMaxHitPoints(oPC)/2)) // injured
        {
            nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Ahhh! It's a plague victim, spouting blood everywhere!");
            nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Get away from me! Under all that blood you probably have the Wailing Death!");
            nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "You can't come in here wounded like that!");
        }
        else
        {

            if (GetItemInSlot(INVENTORY_SLOT_CHEST, oPC) == OBJECT_INVALID) // naked
            {
                nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "One of the girls kick you out, did she?");
                nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Err... you're a bit eager to get the festivities started, aren't you?");
                nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Poor soul lost everything, I see. Have a brother who ended up the same way.");
            }

            nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "You're here to have some fun, too, 'fore the Wailing Death takes you, hey?");
            nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "The gods have abandoned us. The Helmites can't even cure the plague with their blessings, you know that?");
            nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Might as well have some fun before the Wailing Death takes us, you know what I mean?");

            if (GetAbilityScore(oPC, ABILITY_INTELLIGENCE) <= 8) // low intelligence
            {
                nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Hmph. Funny how the lackwits never get the plague, but the good ones die off.");
                nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Do you work for Ophala? I hear she has some simpleton guards, she does.");
            }

            if (GetAbilityScore(oPC, ABILITY_CHARISMA) <= 9) // low charisma
            {
                nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Stay away from me! You never know who has the plague!");
                nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "You just get lost, now! Don't need no plague spread to the fine girls, here.");
            }
        }
    }
// ====================================
// COMMONER
// ====================================
    else if (sResRef == "commoner")
    {
        if (GetItemInSlot(INVENTORY_SLOT_CHEST, oPC) == OBJECT_INVALID) // naked
        {
            nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "A naked plague victim! Don't touch me!");
            nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Why are you naked? You must be plague stricken! Get away from me!");
            nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "What are you doing with no clothes! You want to get sick and catch the plague?");
        }
        else if (GetCurrentHitPoints(oPC) <= (GetMaxHitPoints(oPC)/2)) // injured
        {
            nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "That must have been some fight you were in. Don't those wounds hurt?");
            nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "You're bleeding all over the place! Get some healing before your wounds get infected with plague!");
            nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Those wounds look terrible! You better get looked after before you come down with the Wailing Death.");
        }
        else
        {
            nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Them nobles are up to something in the Blacklake district. I hear they got themselves a secret cure for the plague!");
            nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "I heard there was a prison break in the Peninsula district. I suppose we'll be burning more corpses if it's true.");
            nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "You must be one of the new city guard. Hopefully you can do something about those zombies in the Beggar's Nest.");
            nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "The militia can't keep order anymore! The guards in the Core don't even care that there was a prison break in the Penisula district.");
            nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "The nobles in the Blacklake district have sealed themselves away from everyone. There's something strange there, mark my words!");
            nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "They say plague-corpses walk the streets in the Beggar's Nest, feasting on the living!");
            nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "There's anarchy in the Docks district! I heard criminals are coming from the sewers and the city guard are afraid to delve down there now.");
            nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "I heard the Blacklake nobles have a cure for the plague, but they won't share it with us common folk! I hear a lot of things, though.");
            nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Not sure if it's because of some city ordinance, but the only place you can sell stuff is at Olgerd's pawnshop.");
            nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "You can sell off that junk to Olgerd. He's in the markets in the docks.");
            nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Need a blade? You should talk to Durga at the Shining Knights Arms and Armor.");
            nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "If you need an item identified, head on over to the Cloaktower.");
            nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Need supplies? See Olgerd at his store. Sleazy little man, but he has good stock.");

            if (GetAbilityScore(oPC, ABILITY_INTELLIGENCE) <= 8) // low intelligence
            {
                nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Not too bright, are you? Maybe your mind was destroyed by the plague! Get away from me!");
                nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "You aren't quite right in the head, are you? Maybe you escaped during the prison break in the Penisula district.");
            }

            if (GetAbilityScore(oPC, ABILITY_CHARISMA) <= 9) // low charisma
            {
                nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "People like you belong in the sewers - along with the rest of the thugs and ruffians!");
                nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Hmph! You look like you must be one of them escaped convicts from the prison break in the Peninsula district!");
            }
        }
    }
// ====================================
// PEASANT
// ====================================
    else if (sResRef == "peasant")
    {
        if (GetItemInSlot(INVENTORY_SLOT_CHEST, oPC) == OBJECT_INVALID) // naked
        {
            nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "'Tis nice undercothes you've got there.");
            nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Ah! My eyes! Please be decent enough to dress yourself!");
            nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "A bit underdressed for the weather, don't you think?");
        }
        else if (GetCurrentHitPoints(oPC) <= (GetMaxHitPoints(oPC)/2)) // injured
        {
            nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Ouch! You look like a dressed animal with all of those wounds!");
            nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "You are heavily wounded! Get ye to a temple!");
            nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "You seem more than a bit bloodied.");
        }
        else
        {
            nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Don't travel north. There's bandits on the road.");
            nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Oh, there's sure to be a war, there is. Everyone's talking about it!");
            nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Oh... you must be one of the mercenaries come to town, right?");
            nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "You must be one of Lady Aribeth's stalwart heroes! I hope you find the cure!");
            nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Nice to see good people like yourself here.");
            nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Been a good year on the farm! Hope the weather holds.");
            nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Excuse me. I haven't the time to speak right now.");

            if (GetAbilityScore(oPC, ABILITY_INTELLIGENCE) <= 8) // low intelligence
            {
                nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Must be a hard life to be so stupi... uh, nevermind.");
                nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "'Tis a slow day and I've someone slow to spend it with.");
                nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Dropped on yer head as a child? I've known folks like that.");
            }

            if (GetAbilityScore(oPC, ABILITY_CHARISMA) <= 9) // low charisma
            {
                nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "It's people like you who give adventuring a bad name.");
                nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "I don't want any trouble. Just leave me alone.");
                nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "I work on a farm and I never expected to see someone who is dirtier than me!");
                nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Move along. Ain't got time for you.");
            }
        }
    }
// ====================================
// OLD MAN/WOMAN
// ====================================
    else if (GetStringLeft(sResRef, 3) == "old")
    {
        if (GetItemInSlot(INVENTORY_SLOT_CHEST, oPC) == OBJECT_INVALID) // naked
        {
            nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Has the Wailing driven you mad!? At least put some clothing on!");
            nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Aye, I'd run around naked too, if it weren't for the boils...");
            nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "You'd better get some clothes on you before you get lynched as a plague-spreader!");
        }
        else if (GetCurrentHitPoints(oPC) <= (GetMaxHitPoints(oPC)/2)) // injured
        {
            nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Those wounds look terrible! You're - You're not a Wailer are you?");
            nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Aye, the Tyrists are so busy with the plague-struck, they've no time for the honest wounded!");
            nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Look at those wounds - Guards catch you trying to break quarantine?");
        }
        else
        {
            nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Lord Nasher hasn't made an appearance for weeks. Who can blame him? It stinks of burning bodies out here.");
            nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Be careful around the Core - people are getting upset about how long it's taking to get a cure.");
            nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "So you're Nasher's lackeys, are you? You'll smell like the rest of us after a day near the corpse burning pits.");
            nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "The church, the government, the militia, they've all turned on us. All we've got is ourselves...");
            nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "The Tyrists keep on whining about their precious cure - You know what? There's no cure for being dead...");
            nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "This is what we've become, is it? Guttersnipes and harpies, all of us...");

            if (GetAbilityScore(oPC, ABILITY_INTELLIGENCE) <= 8) // low intelligence
            {
                nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "You think you're a dim wit? You'd make a finer ruler than that fool Nasher!");
                nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Dumb as a post yet they made you militia even so, hmm?");
            }


            if (GetAbilityScore(oPC, ABILITY_CHARISMA) >= 13) // high charisma
            {
                nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Just between you and I, I wouldn't trust anyone around these parts, least of all those in charge.");
            }

            if (GetAbilityScore(oPC, ABILITY_CHARISMA) <= 9) // low charisma
            {
                nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "You smell as bad as the politics around here... Not as bad as the burn-pits, though...");
                nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "You know what? I may not like you but I like the folks in charge even less, right now...");
                nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "I'd call the guard but it looks like they've sold out to the likes of you these days...");
            }
        }
    }
// ====================================
// SAILOR
// ====================================
    else if (sResRef == "sailor")
    {
        nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Hope I can get a pint or two of ale tonight.");
        nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "I miss the roll and pitch of the gentle waves. Back to sea for me, if they ever let us.");
        nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Might be a bit of a storm rollin' in off the ocean tonight, not that it matters anyways.");
        nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Hope you're not itching for a ride on the ship. We ain't going anywhere for a wee while.");
        nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Nothing like the smell of fish guts and the gentle slap of waves against the dock to make one feel at home.");
        nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Oh how I wish I was out on the briney blue ocean again.");
    }
// ====================================
// CHILD
// ====================================
    else if (sResRef == "child")
    {
        nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "You funny looking.");
        nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Mother said not to talk to strangers!");
        nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Do you have the plague?");
        nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Who are you?");
    }
// ====================================
// NOBLEMAN/NOBLEWOMAN
// ====================================
    else if (GetStringLeft(sResRef, 5) == "noble")
    {
        if (GetItemInSlot(INVENTORY_SLOT_CHEST, oPC) == OBJECT_INVALID) // naked
        {
            nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Degenerate! Show some modesty and dress yourself! This isn't Calimshan!");
            nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Why are you naked? The plague must be affecting your mind! Get your filth out of the Blacklake!");
            nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "A naked plague victim! How did you get past our barricades? Don't touch me.");
        }
        else if (GetCurrentHitPoints(oPC) <= (GetMaxHitPoints(oPC)/2)) // injured
        {
            nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Such wounds! Did plague victims attack you? I had thought our barricades would keep them at bay.");
            nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "You look absolutely wretched! Did you clash with the infected?");
        }
        else
        {
            nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "I regret that the Blacklake must shut out the plagues and weak, but what choice do we have?");
            nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "I think the plague is a result of the poor classes we allowed into the district. The barricades were long overdue.");
            nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "I hope a plague cure is found soon. The barricades can't keep everyone out. Ugh.");
            nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "The Divine Elegance is such a fine shop. Best tailor this side of the Sword Coast, I'd say.");
            nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Have you been to Argali's Apparels recently? She has the comfiest boots and the coziest of cloaks!");

            if (GetAbilityScore(oPC, ABILITY_CHARISMA) >= 13) // high charisma
            {
                nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Hello, you must be one of the new city guard. I wish you luck.");
                nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "A word of advice. If you get the Wailing Death, you won't last long in this district. We'll put you behind the barricades.");
                nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "You'll have to pardon me. The plague has taken my desire for conversation.");
                nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "I hope a plague cure is found soon. The barricades can't keep everyone out.");
            }

            if (GetAbilityScore(oPC, ABILITY_CHARISMA) <= 9) // low charisma
            {
                nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Stay away from me! You look like the sort that might carry the plague.");
                nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Don't touch me! You're ugly enough to be one of the plague-stricken. Why didn't the barricades keep you out?");
                nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Stand away from me. You could be one of Meldanen's thugs, or even a plague victim!");
                nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Don't touch me! I might catch something.");
            }
        }
    }
// ====================================
// GUARD/MILITIA
// ====================================
    else if (GetStringLeft(sResRef, 8) == "nwknight" || GetStringLeft(sResRef, 7) == "nwguard" || GetStringLeft(sResRef, 7) == "militia")
    {
        nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Staying safe I hope.");
        nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Everything's in order.");
        nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Everything all right?");
        nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "No lollygaggin'.");
        nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "What is it?");
        nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Trouble?");
        nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "I used to be an adventurer like you. Now I'm stuck in this city.");
        nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "I should've joined the army.");
        nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "You should talk to Durga. Get yourself some proper steel.");
    }
// ====================================
// PLAGUE VICTIM
// ====================================
    else if (GetStringLeft(sResRef, 6) == "plague")
    {
        nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "You think you know pain? Do you!?");
        nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "My neighbor... he died of the plague. Then he came back as a zombie. That's not going to happen to me... is it? IS IT!");
        nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "How long before they get in here? Zombies are mindless, but they'll smell us... they'll throw themselves at us. We're all going to die...");
        nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Where are the guards? Where is Lord Nasher? They left us to die! To die!");
        nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "What is wrong with this city? Plague... death... did we kick the Fates' dog or something?");
        nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Lost everyone. Don't know where the family is. No clue...");
        nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Can you do something? Can you? I don't see how...");
        nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "It hurts. Everything hurts so bad...");
    }
// ====================================
// BEGGAR
// ====================================
    else if (sResRef == "beggar")
    {
        nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Please... can you spare a coin?");
        nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "A few gold pieces ain't nothing. You can spare that, can't you?");
        nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "I ain't done nothing.");
        nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Don't forget them who's less fortunate than yourself.");
        nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "To the Hells with all of you! You rich piles of dung walking by us like we're not there!");
        nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Sure, sure. I'm a dirty beggar... why would you want to even speak to me.");
        nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "This place is nothing but a rotten, stinking corpse that's sat in the sun far too long.");
        nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "A coin or two for a veteran? It's not much to ask...");
    }
// ====================================
// STUDENT
// ====================================
    else if (sResRef == "student")
    {
        nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "I have a lot to learn still, before Sedos will put me in the field.");
        nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "I'm one of the new recruits. Are you one as well?");
        nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "This uniform is a little tacky...");
        nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Sorry, I'm a bit busy right now.");
        nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Do you need something?");
        nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "My training has only started, but I hope I can do some good out there soon.");
    }
// ====================================
// MERCENARY
// ====================================
    else if (GetStringLeft(sResRef, 9) == "mercenary")
    {
        if (GetItemInSlot(INVENTORY_SLOT_CHEST, oPC) == OBJECT_INVALID) // naked
        {
            nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Lost yer shirt at the gambling table, I see. Ha ha!");
            nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Ha ha! Just come out of th' Moonstone Mask, did ya? Lose something?");
            nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Yer not some naked plague victim, are ya? Get away, already!");
        }
        else if (GetCurrentHitPoints(oPC) <= (GetMaxHitPoints(oPC)/2)) // injured
        {
            nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "What are you doing, running in here getting blood all over the place?!");
            nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "You're bloody injured! Or are you some plague victim? Out! Get out!!");
            nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Must have been some fight, by the look of ye.");
        }
        else
        {
            nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Now this is a sorry state. Can't leave the city, an' can't do anything while we're here. 'Cept wait for the Wailing Death to take us.");
            nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Don't stand so close. Ya never know who gots the Wailing Death, 'til it's too late.");

            if (GetAbilityScore(oPC, ABILITY_INTELLIGENCE) <= 8) // low intelligence
            {
                nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "I had a cousin slow like ye. He were a mercenary, too... but he drowned in a puddle.");
                nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "I've no time for simpletons. We're not hiring, anyway.");
                nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "hat? Has the bloody plague stricken ye dumb?");
            }

            if (GetAbilityScore(oPC, ABILITY_CHARISMA) <= 9) // low charisma
            {
                nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "We wouldn't hire yer like even if our pockets were full of gold... which they ain't.");
                nCount++; SetLocalString(OBJECT_SELF, "gossip"+IntToString(nCount), "Don't come near me! Don't know who might have the plague, an ye looks like a fine candidate.");
            }
        }
    }

    SetCustomToken(12213, GetLocalString(OBJECT_SELF, "gossip"+IntToString(Random(nCount)+1)));

    return TRUE;
}
