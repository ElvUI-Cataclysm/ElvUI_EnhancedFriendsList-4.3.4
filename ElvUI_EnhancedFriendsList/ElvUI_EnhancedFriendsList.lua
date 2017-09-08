local E, L, V, P, G = unpack(ElvUI)
local EFL = E:NewModule("EnhancedFriendsList")
local EP = LibStub("LibElvUIPlugin-1.0")
local LSM = LibStub("LibSharedMedia-3.0", true)
local addonName = "ElvUI_EnhancedFriendsList"

local pairs, ipairs = pairs, ipairs
local format = format

local IsChatAFK = IsChatAFK
local IsChatDND = IsChatDND
local GetFriendInfo = GetFriendInfo
local GetQuestDifficultyColor = GetQuestDifficultyColor
local GetNumFriends = GetNumFriends
local LEVEL = LEVEL
local FRIENDS_BUTTON_TYPE_WOW = FRIENDS_BUTTON_TYPE_WOW
local LOCALIZED_CLASS_NAMES_FEMALE = LOCALIZED_CLASS_NAMES_FEMALE
local LOCALIZED_CLASS_NAMES_MALE = LOCALIZED_CLASS_NAMES_MALE
local RAID_CLASS_COLORS = RAID_CLASS_COLORS

local EnhancedOnline = "Interface\\AddOns\\ElvUI_EnhancedFriendsList\\Media\\Textures\\StatusIcon-Online"
local EnhancedOffline = "Interface\\AddOns\\ElvUI_EnhancedFriendsList\\Media\\Textures\\StatusIcon-Offline"
local EnhancedAfk = "Interface\\AddOns\\ElvUI_EnhancedFriendsList\\Media\\Textures\\StatusIcon-Away"
local EnhancedDnD = "Interface\\AddOns\\ElvUI_EnhancedFriendsList\\Media\\Textures\\StatusIcon-DnD"

local Locale = GetLocale()

-- Profile
P["enhanceFriendsList"] = {
	-- General
	["showBackground"] = true,
	["showStatusIcon"] = true,
	["enhancedTextures"] = true,
	-- Online
	["enhancedName"] = true,
	["colorizeNameOnly"] = false,
	["enhancedZone"] = false,
	["hideClass"] = true,
	["levelColor"] = false,
	["shortLevel"] = true,
	["sameZone"] = true,
	-- Offline
	["offlineEnhancedName"] = true,
	["offlineColorizeNameOnly"] = true,
	["offlineHideClass"] = true,
	["offlineHideLevel"] = false,
	["offlineLevelColor"] = false,
	["offlineShortLevel"] = true,
	["offlineShowZone"] = false,
	["offlineShowLastSeen"] = true,
	-- Name Text Font
	["nameFont"] = "PT Sans Narrow",
	["nameFontSize"] = 12,
	["nameFontOutline"] = "NONE",
	-- Zone Text Font
	["zoneFont"] = "PT Sans Narrow",
	["zoneFontSize"] = 12,
	["zoneFontOutline"] = "NONE"
}

-- Options
local function ColorizeSettingName(settingName)
	return format("|cff1784d1%s|r", settingName)
end

function EFL:InsertOptions()
	E.Options.args.enhanceFriendsList = {
		order = 54,
		type = "group",
		name = ColorizeSettingName(L["Enhanced Friends List"]),
		get = function(info) return E.db.enhanceFriendsList[ info[#info] ] end,
		set = function(info, value) E.db.enhanceFriendsList[ info[#info] ] = value end,
		args = {
			header = {
				order = 1,
				type = "header",
				name = L["Enhanced Friends List"]
			},
			general = {
				order = 2,
				type = "group",
				name = L["General"],
				guiInline = true,
				args = {
					showBackground = {
						order = 1,
						type = "toggle",
						name = L["Show Background"],
						set = function(info, value) E.db.enhanceFriendsList.showBackground = value EFL:EnhanceFriends() end
					},
					showStatusIcon = {
						order = 2,
						type = "toggle",
						name = L["Show Status Icon"],
						set = function(info, value) E.db.enhanceFriendsList.showStatusIcon = value EFL:EnhanceFriends() end
					},
					enhancedTextures = {
						order = 3,
						type = "toggle",
						name = L["Enhanced Status"],
						set = function(info, value) E.db.enhanceFriendsList.enhancedTextures = value EFL:EnhanceFriends() EFL:FriendDropdownUpdate() end
					}
				}
			},
			onlineFriends = {
				order = 3,
				type = "group",
				name = L["Online Friends"],
				guiInline = true,
				args = {
					enhancedName = {
						order = 1,
						type = "toggle",
						name = L["Enhanced Name"],
						set = function(info, value) E.db.enhanceFriendsList.enhancedName = value EFL:EnhanceFriends() end
					},
					colorizeNameOnly = {
						order = 2,
						type = "toggle",
						name = L["Colorize Name Only"],
						set = function(info, value) E.db.enhanceFriendsList.colorizeNameOnly = value EFL:EnhanceFriends() end,
						disabled = function() return not E.db.enhanceFriendsList.enhancedName end
					},
					enhancedZone = {
						order = 3,
						type = "toggle",
						name = L["Enhanced Zone"],
						set = function(info, value) E.db.enhanceFriendsList.enhancedZone = value EFL:EnhanceFriends() end
					},
					hideClass = {
						order = 4,
						type = "toggle",
						name = L["Hide Class Text"],
						set = function(info, value) E.db.enhanceFriendsList.hideClass = value EFL:EnhanceFriends() end
					},
					levelColor = {
						order = 5,
						type = "toggle",
						name = L["Level Range Color"],
						set = function(info, value) E.db.enhanceFriendsList.levelColor = value EFL:EnhanceFriends() end
					},
					shortLevel = {
						order = 6,
						type = "toggle",
						name = L["Short Level"],
						set = function(info, value) E.db.enhanceFriendsList.shortLevel = value EFL:EnhanceFriends() end
					},
					sameZone = {
						order = 7,
						type = "toggle",
						name = L["Same Zone Color"],
						desc = L["Friends that are in the same area as you, have their zone info colorized green."],
						set = function(info, value) E.db.enhanceFriendsList.sameZone = value EFL:EnhanceFriends() end
					}
				}
			},
			offlineFriends = {
				order = 4,
				type = "group",
				name = L["Offline Friends"],
				guiInline = true,
				args = {
					offlineEnhancedName = {
						order = 1,
						type = "toggle",
						name = L["Enhanced Name"],
						set = function(info, value) E.db.enhanceFriendsList.offlineEnhancedName = value EFL:EnhanceFriends() end
					},
					offlineColorizeNameOnly = {
						order = 2,
						type = "toggle",
						name = L["Colorize Name Only"],
						set = function(info, value) E.db.enhanceFriendsList.offlineColorizeNameOnly = value EFL:EnhanceFriends() end,
						disabled = function() return not E.db.enhanceFriendsList.offlineEnhancedName end
					},
					offlineHideClass = {
						order = 3,
						type = "toggle",
						name = L["Hide Class Text"],
						set = function(info, value) E.db.enhanceFriendsList.offlineHideClass = value EFL:EnhanceFriends() end
					},
					offlineHideLevel = {
						order = 4,
						type = "toggle",
						name = L["Hide Level"],
						set = function(info, value) E.db.enhanceFriendsList.offlineHideLevel = value EFL:EnhanceFriends() end
					},
					offlineLevelColor = {
						order = 5,
						type = "toggle",
						name = L["Level Range Color"],
						set = function(info, value) E.db.enhanceFriendsList.offlineLevelColor = value EFL:EnhanceFriends() end,
						disabled = function() return E.db.enhanceFriendsList.offlineHideLevel end
					},
					offlineShortLevel = {
						order = 6,
						type = "toggle",
						name = L["Short Level"],
						set = function(info, value) E.db.enhanceFriendsList.offlineShortLevel = value EFL:EnhanceFriends() end,
						disabled = function() return E.db.enhanceFriendsList.offlineHideLevel end
					},
					offlineShowZone = {
						order = 7,
						type = "toggle",
						name = L["Show Zone"],
						set = function(info, value) E.db.enhanceFriendsList.offlineShowZone = value EFL:EnhanceFriends() end
					},
					offlineShowLastSeen = {
						order = 8,
						type = "toggle",
						name = L["Show Last Seen"],
						set = function(info, value) E.db.enhanceFriendsList.offlineShowLastSeen = value EFL:EnhanceFriends() end
					}
				}
			},
			font = {
				order = 5,
				type = "group",
				name = L["Font"],
				guiInline = true,
				args = {
					nameFont = {
						order = 1,
						type = "select", dialogControl = "LSM30_Font",
						name = L["Name Font"],
						values = AceGUIWidgetLSMlists.font,
						set = function(info, value) E.db.enhanceFriendsList.nameFont = value EFL:EnhanceFriends() end
					},
					nameFontSize = {
						order = 2,
						type = "range",
						name = L["Name Font Size"],
						min = 6, max = 22, step = 1,
						set = function(info, value) E.db.enhanceFriendsList.nameFontSize = value EFL:EnhanceFriends() end
					},
					nameFontOutline = {
						order = 3,
						type = "select",
						name = L["Name Font Outline"],
						desc = L["Set the font outline."],
						values = {
							["NONE"] = NONE,
							["OUTLINE"] = "OUTLINE",
							["MONOCHROMEOUTLINE"] = "MONOCROMEOUTLINE",
							["THICKOUTLINE"] = "THICKOUTLINE"
						},
						set = function(info, value) E.db.enhanceFriendsList.nameFontOutline = value EFL:EnhanceFriends() end
					},
					zoneFont = {
						order = 4,
						type = "select", dialogControl = "LSM30_Font",
						name = L["Zone Font"],
						values = AceGUIWidgetLSMlists.font,
						set = function(info, value) E.db.enhanceFriendsList.zoneFont = value EFL:EnhanceFriends() end
					},
					zoneFontSize = {
						order = 5,
						type = "range",
						name = L["Zone Font Size"],
						min = 6, max = 22, step = 1,
						set = function(info, value) E.db.enhanceFriendsList.zoneFontSize = value EFL:EnhanceFriends() end
					},
					zoneFontOutline = {
						order = 6,
						type = "select",
						name = L["Zone Font Outline"],
						desc = L["Set the font outline."],
						values = {
							["NONE"] = NONE,
							["OUTLINE"] = "OUTLINE",
							["MONOCHROMEOUTLINE"] = "MONOCROMEOUTLINE",
							["THICKOUTLINE"] = "THICKOUTLINE"
						},
						set = function(info, value) E.db.enhanceFriendsList.zoneFontOutline = value EFL:EnhanceFriends() end
					}
				}
			}
		}
	}
end

local function ClassColorCode(class)
	for k, v in pairs(LOCALIZED_CLASS_NAMES_MALE) do
		if class == v then
			class = k
		end
	end
	if Locale ~= "enUS" then
		for k, v in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do
			if class == v then
				class = k
			end
		end
	end

	local color = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class]
	if not color then
		return format("|cFF%02x%02x%02x", 255, 255, 255)
	else
		return format("|cFF%02x%02x%02x", color.r*255, color.g*255, color.b*255)
	end
end

local function OfflineColorCode(class)
	for k, v in pairs(LOCALIZED_CLASS_NAMES_MALE) do
		if class == v then
			class = k
		end
	end
	if Locale ~= "enUS" then
		for k, v in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do
			if class == v then
				class = k
			end
		end
	end

	local color = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class]
	if not color then
		return format("|cFF%02x%02x%02x", 160, 160, 160)
	else
		return format("|cFF%02x%02x%02x", color.r*160, color.g*160, color.b*160)
	end
end

local function timeDiff(t2, t1)
	if t2 < t1 then return end

	local d1, d2, carry, diff = date("*t", t1), date("*t", t2), false, {}
	local colMax = {60, 60, 24, date("*t", time{year = d1.year,month = d1.month + 1, day = 0}).day, 12}

	d2.hour = d2.hour - (d2.isdst and 1 or 0) + (d1.isdst and 1 or 0)
	for i, v in ipairs({"sec", "min", "hour", "day", "month", "year"}) do 
		diff[v] = d2[v] - d1[v] + (carry and -1 or 0)
		carry = diff[v] < 0
		if carry then diff[v] = diff[v] + colMax[i] end
	end

	return diff
end

function EFL:EnhanceFriends()
	local scrollFrame = FriendsFrameFriendsScrollFrame
	local buttons = scrollFrame.buttons
	local numButtons = #buttons
	local name, level, class, area, connected, status
	local playerZone = GetRealZoneText()

	for i = 1, numButtons do
		local Cooperate = false
		local button = buttons[i]
		local nameText, nameColor, infoText, broadcastText

		if button.buttonType == FRIENDS_BUTTON_TYPE_WOW then
			name, level, class, area, connected, status = GetFriendInfo(button.id)
			if not name then return end

			local diff = level ~= 0 and format("|cff%02x%02x%02x", GetQuestDifficultyColor(level).r * 255, GetQuestDifficultyColor(level).g * 255, GetQuestDifficultyColor(level).b * 255) or "|cFFFFFFFF"
			local shortLevel = E.db.enhanceFriendsList.shortLevel and L["SHORT_LEVEL"] or LEVEL

			if E.db.enhanceFriendsList.showBackground then
				button.background:Show()
			else
				button.background:Hide()
			end

			button.name:ClearAllPoints()
			if E.db.enhanceFriendsList.showStatusIcon then
				button.name:Point("TOPLEFT", 20, -3)
				button.status:Show()
			else
				button.status:Hide()
				button.name:Point("TOPLEFT", 3, -3)
			end

			infoText = area
			broadcastText = nil

			if connected then
				if status == "" then
					button.status:SetTexture(E.db.enhanceFriendsList.enhancedTextures and EnhancedOnline or FRIENDS_TEXTURE_ONLINE)
				elseif status == CHAT_FLAG_AFK then
					button.status:SetTexture(E.db.enhanceFriendsList.enhancedTextures and EnhancedAfk or FRIENDS_TEXTURE_AFK)
				elseif status == CHAT_FLAG_DND then
					button.status:SetTexture(E.db.enhanceFriendsList.enhancedTextures and EnhancedDnD or FRIENDS_TEXTURE_DND)
				end

				if not ElvCharacterDB.EnhancedFriendsList_Data[name] then
					ElvCharacterDB.EnhancedFriendsList_Data[name] = {}
				end

				ElvCharacterDB.EnhancedFriendsList_Data[name].level = level
				ElvCharacterDB.EnhancedFriendsList_Data[name].class = class
				ElvCharacterDB.EnhancedFriendsList_Data[name].area = area
				ElvCharacterDB.EnhancedFriendsList_Data[name].lastSeen = format("%i", time())

				if E.db.enhanceFriendsList.enhancedName then
					if E.db.enhanceFriendsList.colorizeNameOnly then
						if E.db.enhanceFriendsList.hideClass then
							if E.db.enhanceFriendsList.levelColor then
								nameText = format("%s%s|r|cffffffff - %s|r %s%s|r", ClassColorCode(class), name, shortLevel, diff, level)
							else
								nameText = format("%s%s|r|cffffffff - %s %s|r", ClassColorCode(class), name, shortLevel, level)
							end
						else
							if E.db.enhanceFriendsList.levelColor then
								nameText = format("%s%s|r|cffffffff - %s|r %s%s|r|cffffffff %s|r", ClassColorCode(class), name, shortLevel, diff, level, class)
							else
								nameText = format("%s%s|r|cffffffff - %s %s %s|r", ClassColorCode(class), name, shortLevel, level, class)
							end
						end
					else
						if E.db.enhanceFriendsList.hideClass then
							if E.db.enhanceFriendsList.levelColor then
								nameText = format("%s%s - %s %s%s|r", ClassColorCode(class), name, shortLevel, diff, level)
							else
								nameText = format("%s%s - %s %s", ClassColorCode(class), name, shortLevel, level)
							end
						else
							if E.db.enhanceFriendsList.levelColor then
								nameText = format("%s%s - %s %s%s|r %s%s", ClassColorCode(class), name, shortLevel, diff, level, ClassColorCode(class), class)
							else
								nameText = format("%s%s - %s %s %s", ClassColorCode(class), name, shortLevel, level, class)
							end
						end
					end
				else
					if E.db.enhanceFriendsList.hideClass then
						if E.db.enhanceFriendsList.levelColor then
							nameText = format("%s, %s %s%s|r", name, shortLevel, diff, level)
						else
							nameText = format("%s, %s %s", name, shortLevel, level)
						end
					else
						if E.db.enhanceFriendsList.levelColor then
							nameText = format("%s, %s %s%s|r %s", name, shortLevel, diff, level, class)
						else
							nameText = format("%s, %s %s %s", name, shortLevel, level, class)
						end
					end
				end

				nameColor = FRIENDS_WOW_NAME_COLOR
				Cooperate = true
			else
				button.status:SetTexture(E.db.enhanceFriendsList.enhancedTextures and EnhancedOffline or FRIENDS_TEXTURE_OFFLINE)

				if ElvCharacterDB.EnhancedFriendsList_Data[name] then
					local lastSeen = ElvCharacterDB.EnhancedFriendsList_Data[name].lastSeen
					local td = timeDiff(time(), tonumber(lastSeen))
					level = ElvCharacterDB.EnhancedFriendsList_Data[name].level
					class = ElvCharacterDB.EnhancedFriendsList_Data[name].class
					area = ElvCharacterDB.EnhancedFriendsList_Data[name].area

					local offlineShortLevel = E.db.enhanceFriendsList.offlineShortLevel and L["SHORT_LEVEL"] or LEVEL
					local offlineDiff = level ~= 0 and format("|cff%02x%02x%02x", GetQuestDifficultyColor(level).r * 160, GetQuestDifficultyColor(level).g * 160, GetQuestDifficultyColor(level).b * 160) or "|cFFAFAFAF|r"
					local offlineDiffColor
					if E.db.enhanceFriendsList.offlineEnhancedName then
						if E.db.enhanceFriendsList.offlineColorizeNameOnly then
							offlineDiffColor = E.db.enhanceFriendsList.offlineLevelColor and offlineDiff or "|cFFAFAFAF|r"
						else
							offlineDiffColor = E.db.enhanceFriendsList.offlineLevelColor and offlineDiff or OfflineColorCode(class)
						end
					else
						offlineDiffColor = E.db.enhanceFriendsList.offlineLevelColor and offlineDiff or "|cFFAFAFAF|r"
					end

					if E.db.enhanceFriendsList.offlineEnhancedName then
						if E.db.enhanceFriendsList.offlineColorizeNameOnly then
							if E.db.enhanceFriendsList.offlineHideClass then
								if E.db.enhanceFriendsList.offlineHideLevel then
									nameText = format("%s%s", OfflineColorCode(class), name)
								else
									nameText = format("%s%s|r - %s %s%s", OfflineColorCode(class), name, offlineShortLevel, offlineDiffColor, level)
								end
							else
								if E.db.enhanceFriendsList.offlineHideLevel then
									nameText = format("%s%s|r - %s", OfflineColorCode(class), name, class)
								else
									nameText = format("%s%s|r - %s %s%s|r %s", OfflineColorCode(class), name, offlineShortLevel, offlineDiffColor, level, class)
								end
							end
						else
							if E.db.enhanceFriendsList.offlineHideClass then
								if E.db.enhanceFriendsList.offlineHideLevel then
									nameText = format("%s%s", OfflineColorCode(class), name)
								else
									nameText = format("%s%s - %s %s%s", OfflineColorCode(class), name, offlineShortLevel, offlineDiffColor, level)
								end
							else
								if E.db.enhanceFriendsList.offlineHideLevel then
									nameText = format("%s%s - %s", OfflineColorCode(class), name, class)
								else
									nameText = format("%s%s - %s %s%s|r %s%s", OfflineColorCode(class), name, offlineShortLevel, offlineDiffColor, level, OfflineColorCode(class), class)
								end
							end
						end
					else
						if E.db.enhanceFriendsList.offlineHideClass then
							if E.db.enhanceFriendsList.offlineHideLevel then
								nameText = name
							else
								nameText = format("%s - %s %s%s", name, offlineShortLevel, offlineDiffColor, level)
							end
						else
							if E.db.enhanceFriendsList.offlineHideLevel then
								nameText = format("%s - %s", name, class)
							else
								nameText = format("%s - %s %s%s|r %s", name, offlineShortLevel, offlineDiffColor, level, class)
							end
						end
					end

					if E.db.enhanceFriendsList.offlineShowZone then
						if E.db.enhanceFriendsList.offlineShowLastSeen then
							infoText = format("%s - %s %s", area, L["Last seen"], RecentTimeDate(td.year, td.month, td.day, td.hour))
						else
							infoText = area
						end
					else
						if E.db.enhanceFriendsList.offlineShowLastSeen then
							infoText = format("%s %s", L["Last seen"], RecentTimeDate(td.year, td.month, td.day, td.hour))
						else
							infoText = ""
						end
					end
				else
					nameText = name

					if E.db.enhanceFriendsList.offlineShowZone then
						if E.db.enhanceFriendsList.offlineShowLastSeen then
							infoText = format("%s - %s", area, area)
						else
							infoText = area
						end
					else
						if E.db.enhanceFriendsList.offlineShowLastSeen then
							infoText = area
						else
							infoText = ""
						end
					end
				end

				nameColor = FRIENDS_GRAY_COLOR
			end
		end

		if nameText then
			button.name:SetText(nameText)
			button.name:SetTextColor(nameColor.r, nameColor.g, nameColor.b)
			button.info:SetText(infoText)
			button.info:SetTextColor(0.49, 0.52, 0.54)
			if Cooperate then
				if E.db.enhanceFriendsList.enhancedZone then
					if E.db.enhanceFriendsList.sameZone then
						if infoText == playerZone then
							button.info:SetTextColor(0, 1, 0)
						else
							button.info:SetTextColor(1, 0.96, 0.45)
						end
					else
						button.info:SetTextColor(1, 0.96, 0.45)
					end
				else
					if E.db.enhanceFriendsList.sameZone then
						if infoText == playerZone then
							button.info:SetTextColor(0, 1, 0)
						else
							button.info:SetTextColor(0.49, 0.52, 0.54)
						end
					else
						button.info:SetTextColor(0.49, 0.52, 0.54)
					end
				end
			end
			button.name:SetFont(LSM:Fetch("font", E.db.enhanceFriendsList.nameFont), E.db.enhanceFriendsList.nameFontSize, E.db.enhanceFriendsList.nameFontOutline)
			button.info:SetFont(LSM:Fetch("font", E.db.enhanceFriendsList.zoneFont), E.db.enhanceFriendsList.zoneFontSize, E.db.enhanceFriendsList.zoneFontOutline)
		end
	end
end

function EFL:FriendDropdownUpdate()
	local status
	if IsChatAFK() then
		status = E.db.enhanceFriendsList.enhancedTextures and EnhancedAfk or FRIENDS_TEXTURE_AFK
	elseif IsChatDND() then
		status = E.db.enhanceFriendsList.enhancedTextures and EnhancedDnD or FRIENDS_TEXTURE_DND
	else
		status = E.db.enhanceFriendsList.enhancedTextures and EnhancedOnline or FRIENDS_TEXTURE_ONLINE
	end

	FriendsFrameStatusDropDownStatus:SetTexture(status)
end

function EFL:FriendListUpdate()
	if not ElvCharacterDB.EnhancedFriendsList_Data then
		ElvCharacterDB.EnhancedFriendsList_Data = {}
	end

	if E.global.EnhancedFriendsList_Data then
		ElvCharacterDB.EnhancedFriendsList_Data = E.global.EnhancedFriendsList_Data
		E.global.EnhancedFriendsList_Data = nil
	end

	hooksecurefunc("HybridScrollFrame_Update", EFL.EnhanceFriends)
	hooksecurefunc("FriendsFrame_UpdateFriends", EFL.EnhanceFriends)
	hooksecurefunc("FriendsFrameStatusDropDown_Update", EFL.FriendDropdownUpdate)
end

function EFL:Initialize()
	EP:RegisterPlugin(addonName, EFL.InsertOptions)

	EFL:FriendListUpdate()
end

local function InitializeCallback()
	EFL:Initialize()
end

E:RegisterModule(EFL:GetName(), InitializeCallback) 