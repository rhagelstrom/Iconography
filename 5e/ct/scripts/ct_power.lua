--  	Author: Ryan Hagelstrom
--	  	Copyright © 2024
--	  	This work is licensed under a Creative Commons license 3.0.
--      http://creativecommons.org/licenses/by/3.0/
-- luacheck: globals onInit update power_Iconography
function onInit()
    if super and super.onInit then
        super.onInit();
    end
    update();
end

function update()
    local sSpell = value.getValue():lower():match('^(.+)%s+-%s+.*')
    if not sSpell then
        sSpell = value.getValue():lower();
    end
    local sIcon =IconographyManager.parseEffectLabelGetIcon(sSpell);
    if sIcon == 'blank_Iconography' then
       local node = value.getDatabaseNode();
       local sDescription = DB.getValue(DB.getChild(node, '..desc', ''));
       sSpell = sDescription:match(('.+School:%s+(%w+).+'))
    end
    power_Iconography.setIcon(IconographyManager.parseEffectLabelGetIcon(sSpell));
end
