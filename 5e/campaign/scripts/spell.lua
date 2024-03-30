--    Author: Ryan Hagelstrom
--    Copyright © 2024
--    This work is licensed under a Creative Commons license 3.0.
--    http://creativecommons.org/licenses/by/3.0/
-- luacheck: globals onInit  update Iconography
function onInit()
    if super and super.onInit then
        super.onInit();
    end
    update()
end

function update()
    local sIcon = IconographyManager.parseEffectLabelGetIcon(name.getValue(), true)
    if sIcon == 'blank_Iconography' then
        local node = name.getDatabaseNode();
        local sSchool = DB.getValue(DB.getChild(node, '..school', ''));
        sIcon = IconographyManager.parseEffectLabelGetIcon(sSchool, true);
    end
    Iconography.setIcon(sIcon);
    if sIcon == 'blank_Iconography' then
        Iconography.setVisible(false);
    else
        Iconography.setVisible(true);

    end
end
