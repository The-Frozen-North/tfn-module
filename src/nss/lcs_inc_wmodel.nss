#include "lcs_inc_general"

const int WEAPON_MODEL_TOP_VAL_MIN = 0;
const int WEAPON_MODEL_TOP_VAL_MAX = 25;

const int WEAPON_MODEL_MID_VAL_MIN = 0;
const int WEAPON_MODEL_MID_VAL_MAX = 25;

const int WEAPON_MODEL_BTM_VAL_MIN = 0;
const int WEAPON_MODEL_BTM_VAL_MAX = 25;

const int SHIELD_MODEL_VAL_MIN = 0;
const int SHIELD_MODEL_VAL_MAX = 260;

const int HELMET_MODEL_VAL_MIN = 0;
const int HELMET_MODEL_VAL_MAX = 105;

const int CLOAK_MODEL_VAL_MIN = 0;
const int CLOAK_MODEL_VAL_MAX = 15;

//==========================================/
//use for:
//- weapons (top, middle, bottom)
//- shields
//- helmets
void set_model_next(object item, int type, int index, object user, int val_min, int val_max)
//==========================================/
    {
    int val = GetItemAppearance(item, type, index);
    object new_item;

    int inventory_slot = get_item_equip_slot(item, user);

    while(!GetIsObjectValid(new_item))
        {
        val++;

        if(val > val_max)
            {
            val = val_min;
            }
        new_item = CopyItemAndModify(item, type, index, val, TRUE);
        }
    DestroyObject(item);

    equip_item(new_item, inventory_slot, user);
    }

//==========================================/
//use for:
//- weapons (top, middle, bottom)
//- shields
//- helmets
void set_model_prev(object item, int type, int index, object user, int val_min, int val_max)
//==========================================/
    {
    int val = GetItemAppearance(item, type, index);
    object new_item;

    int inventory_slot = get_item_equip_slot(item, user);

    while(!GetIsObjectValid(new_item))
        {
        val--;

        if(val < val_min)
            {
            val = val_max;
            }
        new_item = CopyItemAndModify(item, type, index, val);
        }
    DestroyObject(item);

    equip_item(new_item, inventory_slot, user);
    }

