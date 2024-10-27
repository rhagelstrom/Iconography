--  	Author: Ryan Hagelstrom
--	  	Copyright © 2024
--	  	This work is licensed under a Creative Commons license 3.0.
--      http://creativecommons.org/licenses/by/3.0/
-- luacheck: globals IconographyManager IconographyManager
-- luacheck: globals onInit onClose customAddActorDisplayEffects moddedUpdateEffectsHelper
-- luacheck: globals getIconNextPositionXY onHover customAddChatMessage customDeliverChatMessage
-- luacheck: globals customOnReceiveMessage parseChatText changeChat getIconSize customOnDeliverMessage
-- luacheck: globals parseEffectLabelGetIcon sanitizeString
local updateEffectsHelper = nil;
local addActorDisplayEffects = nil;
local onDeliverMessage = nil;
local onReceiveMessage = nil;
local addChatMessage = nil;
local deliverChatMessage = nil;

local aConditions = {};
local aConditions_sm = {};
local aSpellsTraits = {};
local aSpellsTraits_sm= {};

local _aIconography = {
	aDataMap = { "Iconography", "reference.Iconography" },
	sRecordDisplayClass = "Iconography",
	bExport = 1,
};

function onInit()
    LibraryData.setRecordTypeInfo("Iconography", _aIconography);
    onDeliverMessage = ChatManager.onDeliverMessage;
    onReceiveMessage = ChatManager.onReceiveMessage;
    addChatMessage = Comm.addChatMessage;
    deliverChatMessage = Comm.deliverChatMessage;
    updateEffectsHelper = TokenManager.updateEffectsHelper;
    addActorDisplayEffects = ActorDisplayManager.addActorDisplayEffects;

    ChatManager.onDeliverMessage = customOnDeliverMessage;
    ChatManager.onReceiveMessage = customOnReceiveMessage;
    -- luacheck: push ignore 122
    Comm.addChatMessage = customAddChatMessage;
    Comm.deliverChatMessage = customDeliverChatMessage;
    -- luacheck: pop
    TokenManager.updateEffectsHelper = moddedUpdateEffectsHelper;
    ActorDisplayManager.addActorDisplayEffects = customAddActorDisplayEffects;
    ActorDisplayManager.setDisplayCallback('effects', '', IconographyManager.customAddActorDisplayEffects);

    Token.addEventHandler('onHover', IconographyManager.onHover);
    if PowerUp then
        PowerUp.registerExtension('Iconography', '~dev_version~');
    end
end

function onClose()
    ChatManager.onDeliverMessage = onDeliverMessage;
    ChatManager.onReceiveMessage =onReceiveMessage;
    -- luacheck: push ignore 122
    Comm.addChatMessage = addChatMessage;
    Comm.deliverChatMessage = deliverChatMessage;
    -- luacheck: pop
    TokenManager.updateEffectsHelper = updateEffectsHelper;
    ActorDisplayManager.addActorDisplayEffects =addActorDisplayEffects;

end

function addConditions(vType, bSmall, sIcon)
    if type(vType) == "table" then
		for kTag,vTag in pairs(vType) do
            if bSmall then
			    aConditions_sm[kTag] = vTag;
                TokenManager.addEffectConditionIcon(vType, sIcon);
            else
                aConditions[kTag] = vTag;
            end
		end
	elseif type(vType) == "string" then
		if not sIcon then return; end
        if bSmall then
            aConditions_sm[vType] = sIcon;
            TokenManager.addEffectConditionIcon(vType, sIcon);
        else
            aConditions[vType] = sIcon;
        end
    end
end

function addSpellsTraits(vType, bSmall, sIcon)
    if type(vType) == "table" then
		for kTag,vTag in pairs(vType) do
            if bSmall then
			    aSpellsTraits_sm[kTag] = vTag;
                TokenManager.addEffectTagIconSimple(vType, sIcon);
            else
                aSpellsTraits[kTag] = vTag;
            end
		end
	elseif type(vType) == "string" then
		if not sIcon then return; end
        if bSmall then
            aSpellsTraits_sm[vType] = sIcon;
            TokenManager.addEffectTagIconSimple(vType, sIcon);
        else
            aSpellsTraits[vType] = sIcon;
        end
    end
end

function getCondition(sCondition)
    return aConditions[sCondition];
end

function getConditionSmall(sCondition)
    return aConditions_sm[sCondition];
end

function getSpellTrait(sSpellTrait)
    return aSpellsTraits[sSpellTrait];
end

function getSpellTraitSmall(sSpellTrait)
    return aSpellsTraits_sm[sSpellTrait];
end

function customAddActorDisplayEffects(cDisplay, rActor, tCustom)
    addActorDisplayEffects(cDisplay, rActor, tCustom);
    if not cDisplay or not rActor then
        return;
    end
    if not cDisplay or not rActor then
		return;
	end
	if not TokenManager.isDefaultEffectsEnabled() then
		return;
	end
	local nodeCT = ActorManager.getCTNode(rActor);
    local sOptTE;
    if Session.IsHost then
        sOptTE = OptionsManager.getOption('TGME');
    elseif CombatManager.getFactionFromCT(nodeCT) == 'friend' then
        sOptTE = OptionsManager.getOption('TPCE');
    else
        sOptTE = OptionsManager.getOption('TNPCE');
    end
    if sOptTE == 'off' then
        local i = 1;
        local w = cDisplay.findWidget('effect' .. i);
        while w do
            w.destroy();
            i = i + 1;
            w = cDisplay.findWidget('effect' .. i);
        end
    else
        local aCondList = TokenManager.getDefaultEffectInfoFunction()(nodeCT);
        local nConds = #aCondList;
        local rEffectPosition = {
            nPosX = 0,
            nPosY = 20,
            nOffsetY = 20,
            nTokenMax = 100,
            nEffectSize = TokenManager.TOKEN_EFFECT_SIZE_LARGE,
            sDirection = 'left',
            bFull = false,
            nIcons = 0
        };
        local i = 1;
        while i <= nConds and not rEffectPosition.bFull do
            local w = cDisplay.findWidget('effect' .. i);
            if not w then
                local tWidget = {
                    name = 'effect' .. i,
                    icon = 'blank_Iconography',
                    position = 'topleft',
                    x = rEffectPosition.nPosX,
                    y = 0,
                    w = rEffectPosition.nEffectSize,
                    h = rEffectPosition.nEffectSize
                };
                w = cDisplay.addBitmapWidget(tWidget);
            end
            if w then
                w.setBitmap(IconographyManager.parseEffectLabelGetIcon(aCondList[i].sName));
                w.setTooltipText(aCondList[i].sName);
                w.setPosition('topleft', rEffectPosition.nPosX, rEffectPosition.nPosY);
                rEffectPosition = IconographyManager.getIconNextPositionXY(rEffectPosition);
            end
            i = i + 1;
        end
    end
end

function moddedUpdateEffectsHelper(tokenCT, nodeCT)
    local sOptTE;
    if Session.IsHost then
        sOptTE = OptionsManager.getOption('TGME');
    elseif CombatManager.getFactionFromCT(nodeCT) == 'friend' then
        sOptTE = OptionsManager.getOption('TPCE');
    else
        sOptTE = OptionsManager.getOption('TNPCE');
    end

    local sOptTASG = OptionsManager.getOption('TASG');
    local sOptTESZ = OptionsManager.getOption('TESZ');
    local rEffectPosition = {
        nPosX = 0,
        nPosY = 0,
        nTokenMax = 0,
        nEffectSize = TokenManager.TOKEN_EFFECT_SIZE_STANDARD,
        sDirection = 'left',
        bFull = false,
        nIcons = 0
    };

    if sOptTESZ == 'small' then
        rEffectPosition.nEffectSize = TokenManager.TOKEN_EFFECT_SIZE_SMALL;
    elseif sOptTESZ == 'large' then
        rEffectPosition.nEffectSize = TokenManager.TOKEN_EFFECT_SIZE_LARGE;
    end
    if sOptTASG == '80' then
        TokenManager.TOKEN_HEALTHBAR_HOFFSET = 10;
        TokenManager.TOKEN_HEALTHDOT_HOFFSET = 5;
        rEffectPosition.nEffectSize = rEffectPosition.nEffectSize * 0.8;
        rEffectPosition.nPosX = rEffectPosition.nEffectSize / 2;
    else
        rEffectPosition.nEffectSize = rEffectPosition.nEffectSize * 0.9;
        rEffectPosition.nPosX = 0;
    end

    if sOptTE == 'off' then
        local i = 1;
        local w = tokenCT.findWidget('effect' .. i);
        while w do
            w.destroy();
            i = i + 1;
            w = tokenCT.findWidget('effect' .. i);
        end
    elseif sOptTE == 'mark' or sOptTE == 'markhover' then
        local bWidgetsVisible = (sOptTE == 'mark');

        local tTooltip = {};
        local aCondList = TokenManager.getDefaultEffectInfoFunction()(nodeCT);
        for _, v in ipairs(aCondList) do
            table.insert(tTooltip, v.sEffect);
        end
        if #tTooltip > 0 then
            local w = tokenCT.findWidget('effect1');
            if not w then
                local tWidget = {name = 'effect1', icon = 'spellcasting_sm_Iconography'};
                w = tokenCT.addBitmapWidget(tWidget);
            else
                w.setBitmap('spellcasting_sm_Iconography');
            end
            if w then
                w.setTooltipText(table.concat(tTooltip, '\r'));
                w.setPosition('topleft', rEffectPosition.nEffectSize / 2, rEffectPosition.nEffectSize / 2);
                w.setSize(rEffectPosition.nEffectSize, rEffectPosition.nEffectSize);
                w.setVisible(bWidgetsVisible);
            end
            local i = 2;
            w = tokenCT.findWidget('effect' .. i);
            while w do
                w.destroy();
                i = i + 1;
                w = tokenCT.findWidget('effect' .. i);
            end
        else
            local i = 1;
            local w = tokenCT.findWidget('effect' .. i);
            while w do
                w.destroy();
                i = i + 1;
                w = tokenCT.findWidget('effect' .. i);
            end
        end
    else
        local bWidgetsVisible = (sOptTE == 'on');
        local aCondList = TokenManager.getDefaultEffectInfoFunction()(nodeCT);
        local nConds = #aCondList;

        if sOptTASG == '80' then
            rEffectPosition.nTokenMax = 80;
        else
            rEffectPosition.nTokenMax = 100;
        end
        for i = 1, nConds do
            local w = tokenCT.findWidget('effect' .. i);
            if not w then
                local tWidget = {name = 'effect' .. i};
                w = tokenCT.addBitmapWidget(tWidget);
            end
            if w then
                w.setBitmap(IconographyManager.parseEffectLabelGetIcon(aCondList[i].sName));
                w.setTooltipText(aCondList[i].sName);

                if rEffectPosition.bFull then
                    w.destroy();
                    w = tokenCT.findWidget('effect' .. rEffectPosition.nIcons);
                    w.setBitmap('spellcasting_sm_Iconography');
                    local tTooltip = {};
                    table.insert(tTooltip, w.getTooltipText());
                    for j = i, nConds do
                        table.insert(tTooltip, aCondList[j].sEffect);
                    end
                    w.setTooltipText(table.concat(tTooltip, '\r'));
                    break
                end
                if rEffectPosition.bFull then
                    w.setBitmap('cond_more');
                    local tTooltip = {};
                    for j = rEffectPosition.nIcons, nConds do
                        table.insert(tTooltip, aCondList[j].sEffect);
                    end
                    w.setTooltipText(table.concat(tTooltip, '\r'));
                end

                w.setPosition('topleft', rEffectPosition.nPosX, rEffectPosition.nPosY);
                w.setSize(rEffectPosition.nEffectSize, rEffectPosition.nEffectSize);
                rEffectPosition = IconographyManager.getIconNextPositionXY(rEffectPosition);
                w.setVisible(bWidgetsVisible);
            end
        end
        local j = rEffectPosition.nIcons + 1;
        local w = tokenCT.findWidget('effect' .. j);
        while rEffectPosition.bFull and w do
            tokenCT.deleteWidget('effect' .. j);
            j = j + 1;
            w = tokenCT.findWidget('effect' .. j);
        end
    end
end

function getIconNextPositionXY(rEffectPosition)
    local rReturnEffectPosition = UtilityManager.copyDeep(rEffectPosition);
    if not rEffectPosition.bFull then
        if rEffectPosition.sDirection == 'left' then
            if rEffectPosition.nPosY + 2 * rEffectPosition.nEffectSize + TokenManager.TOKEN_EFFECT_MARGIN >
                rEffectPosition.nTokenMax then
                rReturnEffectPosition.sDirection = 'top';
                rReturnEffectPosition.nPosX = rEffectPosition.nEffectSize + TokenManager.TOKEN_EFFECT_MARGIN;
                rReturnEffectPosition.nPosY = rEffectPosition.nOffsetY;
                rReturnEffectPosition.nBottomY = rEffectPosition.nPosY;
            else
                rReturnEffectPosition.nPosX = rEffectPosition.nPosX;
                rReturnEffectPosition.nPosY = rEffectPosition.nPosY + rEffectPosition.nEffectSize +
                                                  TokenManager.TOKEN_EFFECT_MARGIN;
            end
        elseif rEffectPosition.sDirection == 'top' then
            if rEffectPosition.nPosX + 2 * rEffectPosition.nEffectSize + TokenManager.TOKEN_EFFECT_MARGIN >
                rEffectPosition.nTokenMax then
                rReturnEffectPosition.sDirection = 'bottom';
                rReturnEffectPosition.nPosX = rEffectPosition.nEffectSize + TokenManager.TOKEN_EFFECT_MARGIN;
                rReturnEffectPosition.nPosY = rEffectPosition.nBottomY;
            else
                rReturnEffectPosition.nPosX = rEffectPosition.nPosX + rEffectPosition.nEffectSize +
                                                  TokenManager.TOKEN_EFFECT_MARGIN;
                rReturnEffectPosition.nPosY = rEffectPosition.nPosY;
            end
        elseif rEffectPosition.sDirection == 'bottom' then
            if rEffectPosition.nPosX + 2 * rEffectPosition.nEffectSize + TokenManager.TOKEN_EFFECT_MARGIN >
                rEffectPosition.nTokenMax then
                rReturnEffectPosition.sDirection = 'right';
                rReturnEffectPosition.nPosX = rEffectPosition.nPosX;
                rReturnEffectPosition.nPosY = rEffectPosition.nEffectSize + TokenManager.TOKEN_EFFECT_MARGIN;
            else
                rReturnEffectPosition.nPosX = rEffectPosition.nPosX + rEffectPosition.nEffectSize +
                                                  TokenManager.TOKEN_EFFECT_MARGIN;
                rReturnEffectPosition.nPosY = rEffectPosition.nPosY;
            end
        elseif rEffectPosition.sDirection == 'right' then
            rReturnEffectPosition.nPosX = rEffectPosition.nPosX;
            rReturnEffectPosition.nPosY = rEffectPosition.nPosY + rEffectPosition.nEffectSize + TokenManager.TOKEN_EFFECT_MARGIN;
            if rReturnEffectPosition.nPosY + 2 * rReturnEffectPosition.nEffectSize + TokenManager.TOKEN_EFFECT_MARGIN >
                rReturnEffectPosition.nTokenMax then
                rReturnEffectPosition.bFull = true;
            end
        end
        rReturnEffectPosition.nIcons = rEffectPosition.nIcons + 1;
    end
    return rReturnEffectPosition;
end

function onHover(tokenMap, bOver)
    local nodeCT = CombatManager.getCTFromToken(tokenMap);
	if nodeCT then
        if TokenManager.isDefaultEffectsEnabled() then
            local sOption;
            if Session.IsHost then
                sOption = OptionsManager.getOption('TGME');
            elseif CombatManager.getFactionFromCT(nodeCT) == 'friend' then
                sOption = OptionsManager.getOption('TPCE');
            else
                sOption = OptionsManager.getOption('TNPCE');
            end
            if (sOption == 'hover') or (sOption == 'markhover') then
                local i = 1;
                local wgt = tokenMap.findWidget('effect' .. i);
                while wgt do
                    wgt.setVisible(bOver);
                    i = i + 1;
                    wgt = tokenMap.findWidget('effect' .. i);
                end
            end
        end
    end
end
function customAddChatMessage(messagedata)
    changeChat(messagedata);
    addChatMessage(messagedata);
end

function customDeliverChatMessage(messagedata, aUsers)
    changeChat(messagedata);
    deliverChatMessage(messagedata, aUsers);
end

-- We can't do it with a callback
-- because of the callback ordering and other callbacks from the ruleset
-- overwrite out font changes
function customOnDeliverMessage(messagedata, ...)
    local ret = onDeliverMessage(messagedata, ...);
    if messagedata and messagedata.font then
        changeChat(messagedata);
    end
    return ret;
end

-- We can't do it with a callback
-- because of the callback ordering and other callbacks from the ruleset
-- overwrite out font changes
function customOnReceiveMessage(messagedata, ...)
    local ret = onReceiveMessage(messagedata, ...);
    if messagedata and messagedata.font then
        changeChat(messagedata);
    end
    return ret;
end

function parseChatText(sMsgText)
    local sReturn;
    local sMsgTxt = sMsgText:lower();
    local sEffect = sMsgTxt:match('^effect%s%[\'(.+)\']');
    local sDamage = sMsgTxt:match('^%[damage.+]%s*(.+)%s+%[%d+].*');
    local sCast = sMsgTxt:match('^%[cast]%s*(.+)%s+%[.+')
    local sSaveVs = sMsgTxt:match('^%[save vs]%s*(.+)%s+%[.*dc.*');
    local sCastButton = sMsgTxt:match('(.+)%s+%-%s*$');
    local sArcaneWard = sMsgTxt:match('^begins%s%[cast%]([^%[.]+)');

    if not sEffect then
        sEffect = sMsgTxt:match('^%[effect]%s*(.+)');
    end

    if not sDamage then
        sDamage = sMsgTxt:match('^%[damage]%s*(.+)%s+%[type:.+');
    end

    if sEffect then
        local aEffectComps = EffectManager.parseEffect(sEffect);
        local sLabel;
        if aEffectComps[1] and aEffectComps[1] ~= '' then
            sLabel = IconographyManager.sanitizeString(aEffectComps[1]);
        end
        sReturn = sLabel;
    elseif sCast then
        sReturn = IconographyManager.sanitizeString(sCast);
    elseif sDamage then
        sReturn = IconographyManager.sanitizeString(sDamage);
    elseif sCastButton then
        sReturn = IconographyManager.sanitizeString(sCastButton);
    elseif sSaveVs then
        local aEffectComps = EffectManager.parseEffect(sSaveVs);
        sReturn = IconographyManager.sanitizeString(aEffectComps[1]);
    elseif sArcaneWard then
        sReturn = IconographyManager.sanitizeString(sArcaneWard);
    else
        sReturn = IconographyManager.sanitizeString(sMsgTxt);
    end
    return sReturn;
end

function changeChat(messagedata)
    if messagedata.icon and messagedata.icon:match('Iconography') then
        return;
    end
    local sParsedChat = parseChatText(messagedata.text);
    if sParsedChat and IconographyManager.getConditionSmall(sParsedChat) or IconographyManager.getSpellTraitSmall(sParsedChat) then
        if IconographyManager.getConditionSmall(sParsedChat) then
            messagedata.icon = IconographyManager.getConditionSmall(sParsedChat);
        else
            messagedata.icon = IconographyManager.getSpellTraitSmall(sParsedChat);
        end
    elseif sParsedChat and not sParsedChat:match('[%[]%(%)]') then
        if messagedata.sender ~= 'GM' then
            for _, node in pairs(CombatManager.getCombatantNodes()) do
                local nodeCreature = nil;
                local bFound = false;
                local sName = DB.getValue(node, 'name', '');
                if sName == messagedata.sender then
                    local rActor = ActorManager.resolveActor(node);
                    if rActor and ActorManager.isPC(rActor) then
                        nodeCreature = ActorManager.getCreatureNode(rActor);
                    end
                end
                if nodeCreature then
                    local aPowers = DB.getChildList(nodeCreature, 'powers');
                    for _, nodePower in ipairs(aPowers) do
                        local sPower = IconographyManager.sanitizeString(DB.getValue(nodePower, 'name', ''));
                        if sPower == sParsedChat then
                            local sSchool = DB.getValue(nodePower, 'school', ''):lower();
                            local sIcon = IconographyManager.getSpellTraitSmall(sSchool);
                            if sIcon then
                                messagedata.icon = sIcon;
                                break
                            end
                        end
                    end
                end
                if bFound then
                    break
                end
            end
        end
    end
end

function parseEffectLabelGetIcon(sEffect, bLarge)
    local sIcon = 'blank_Iconography';
    local sLabel;
    if not sEffect then
        return sIcon;
    end
    local aEffectComps = EffectManager.parseEffect(sEffect);
    if aEffectComps[1] and aEffectComps[1] ~= '' then
        sLabel = IconographyManager.sanitizeString(aEffectComps[1]);
    end
    if sLabel and sLabel:match('exhaustion') then
        sLabel = 'exhaustion'
    end
    if sLabel then
        sLabel = StringManager.sanitize(sLabel);
        if bLarge then
            if IconographyManager.getCondition(sLabel) then
                sIcon = IconographyManager.getCondition(sLabel);
            elseif IconographyManager.getSpellTrait(sLabel) then
                sIcon = IconographyManager.getSpellTrait(sLabel);
            end
        else
            if IconographyManager.getConditionSmall(sLabel) then
                sIcon = IconographyManager.getConditionSmall(sLabel);
            elseif IconographyManager.getSpellTraitSmall(sLabel) then
                sIcon = IconographyManager.getSpellTraitSmall(sLabel);
            end
        end
    end
    return sIcon;
end

-- Lowers the string
-- Removes leading and trailing spaces
-- Removes (*) and leading and trailing spaces
-- Removes aoe and leading and traling spaces
-- Removes '
-- Replaces space and / with _
function sanitizeString(sString)
    local sReturn = '';
    if sString then
        sReturn = sString:lower():gsub('^%s*', ''):gsub('%s*$', ''):gsub('%s*%(.*%)%s*', '')
                :gsub('%s+aoe%s+', ''):gsub('[%s/]','_'):gsub('\'', '');
    end
    return sReturn;
end
