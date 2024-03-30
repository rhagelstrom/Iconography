--    Author: Ryan Hagelstrom
--    Copyright © 2024
--    This work is licensed under a Creative Commons license 3.0.
--    http://creativecommons.org/licenses/by/3.0/
-- luacheck: globals onInit onClose update
function onInit()
    if super and super.onInit then
        super.onInit();
    end
    DB.addHandler(DB.getPath(header.subwindow.name.getDatabaseNode()), 'onAdd', update);
    DB.addHandler(DB.getPath(header.subwindow.name.getDatabaseNode()), 'onUpdate', update);
    update();
end

function onClose()
    if super and super.onClose then
        super.onClose();
    end
    DB.removeHandler(DB.getPath(header.subwindow.name.getDatabaseNode()), 'onAdd', update);
    DB.removeHandler(DB.getPath(header.subwindow.name.getDatabaseNode()), 'onUpdate', update);
end

function update()
    local sIcon = IconographyManager.parseEffectLabelGetIcon(header.subwindow.name.getValue());

    if sIcon == 'blank_Iconography' then
        local node = header.subwindow.name.getDatabaseNode();
        local sSchool = DB.getValue(DB.getChild(node, '..school', ''));
        sIcon = IconographyManager.parseEffectLabelGetIcon(sSchool);
    end
    if sIcon ~= 'blank_Iconography' then
        header.subwindow.usepower.setIcons(sIcon, sIcon, sIcon);
    else
        header.subwindow.usepower.setIcons('roll_cast','roll_cast','roll_cast')
    end
end
