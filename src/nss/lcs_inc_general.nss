const string APART_ROW = "lc0_";
const string APART_MAX_INDEX = "1c1_";
const string APART_INDEX = "1c2_";

//==========================================/
int get_item_equip_slot(object item, object user)
//==========================================/
    {
    int n = 0;
    while(n < NUM_INVENTORY_SLOTS)
        {
        if(GetItemInSlot(n, user) == item)
            {
            return n;
            }
        n++;
        }

    return -1;
    }

//==========================================/
void equip_item(object item, int equip_slot, object user)
//==========================================/
    {
    effect immobilize = ExtraordinaryEffect(EffectCutsceneImmobilize());
    ApplyEffectToObject(DURATION_TYPE_PERMANENT, immobilize, user);

    //----------------------------------------//
    AssignCommand(user, ActionEquipItem(item, equip_slot));
    RemoveEffect(user, immobilize);
    }

//==========================================/
void set_apart_2da_row(string s2da, int index, int apart_row)
//==========================================/
    {
    SetLocalInt(OBJECT_SELF, APART_ROW + s2da + IntToHexString(index), apart_row);
    SetLocalInt(OBJECT_SELF, APART_INDEX + s2da + IntToHexString(apart_row), index);
    }

//==========================================/
int get_apart_2da_row(string s2da, int index)
//==========================================/
    {
    return GetLocalInt(OBJECT_SELF, APART_ROW + s2da + IntToHexString(index));
    }

//==========================================/
int get_apart_2da_index(string s2da, int apart_row)
//==========================================/
    {
    return GetLocalInt(OBJECT_SELF, APART_INDEX + s2da + IntToHexString(apart_row));
    }

//==========================================/
void set_apart_max_index(string s2da, int index)
//==========================================/
    {
    SetLocalInt(OBJECT_SELF, APART_MAX_INDEX + s2da, index);
    }

//==========================================/
int get_apart_max_index(string s2da)
//==========================================/
    {
    return GetLocalInt(OBJECT_SELF, APART_MAX_INDEX + s2da);
    }
