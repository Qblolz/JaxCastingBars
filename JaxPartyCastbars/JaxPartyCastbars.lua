JaxPartyCastBars = LibStub("AceAddon-3.0"):NewAddon("JaxPartyCastBars", "AceEvent-3.0", "AceHook-3.0","AceConsole-3.0")
local defaults = {
  profile = {
	offsetY = 0,
	offsetX = 210,
	scale = 0.7,
	attachPointBar = "CENTER",
	attachPointFrame = "CENTER"
  }
}
function JaxPartyCastBars:OnInitialize()
	JaxPartyCastBars.db = LibStub("AceDB-3.0"):New("jpcbDB", defaults, true)
	self:SetupOptions()
end

local JPC = CreateFrame("Frame","JPC",UIParent)
local usingRaidFrames = tonumber(GetCVar("useCompactPartyFrames"))
local spellBars = {}
local InArena = function() return (select(2,IsInInstance()) == "arena") end

hooksecurefunc("CompactRaidFrameContainer_SetFlowSortFunction", function(_,_)
		JPC:UpdateBars()
end)

function JPC:UpdateBars()
	local rFrame = _G["CompactRaidFrame1"]

	local raidFramesOn = tonumber(rFrame and rFrame:IsShown())
	for k,sp in ipairs(spellBars) do
		sp:SetScale(JaxPartyCastBars.db.profile.scale)
		if (GetNumGroupMembers() > k or raidFramesOn)  then
			sp:ClearAllPoints()
			if (raidFramesOn == 1) or (UnitInRaid("player")) then
				local numPartyMembers = raidFramesOn == 1 and (GetNumGroupMembers() + 1) or GetNumGroupMembers()
				for g = 1,numPartyMembers,1 do
					local raidFrame = nil
					if CompactRaidFrameManager_GetSetting("KeepGroupsTogether") then
						if UnitInRaid("player") then
							raidFrame = _G["CompactRaidGroup1Member"..g]
						else
							raidFrame = _G["CompactPartyFrameMember"..g]
						end
					else
						raidFrame = _G["CompactRaidFrame"..g]
					end
					if raidFrame and raidFrame.unit == sp.unit then
						sp:SetParent(raidFrame)
						sp:SetPoint(JaxPartyCastBars.db.profile.attachPointFrame, raidFrame, JaxPartyCastBars.db.profile.attachPointBar, JaxPartyCastBars.db.profile.offsetX, JaxPartyCastBars.db.profile.offsetY)
					end
				end
			else
				local partyFrame = _G["PartyMemberFrame"..k]
				if partyFrame and partyFrame.unit == sp.unit then
					sp:SetParent(partyFrame)
					sp:SetPoint(JaxPartyCastBars.db.profile.attachPointFrame, partyFrame, JaxPartyCastBars.db.profile.attachPointBar, JaxPartyCastBars.db.profile.offsetX, JaxPartyCastBars.db.profile.offsetY)
				end
			end
		end
	end
end

function JPC:GROUP_ROSTER_UPDATE()
	JPC:UpdateBars()
end

local function JPC_OnUpdate(self)
	local rFrame = _G["CompactRaidFrame1"]
	local raidFramesOn = tonumber(rFrame and rFrame:IsShown())

	if usingRaidFrames ~= raidFramesOn then
		usingRaidFrames = raidFramesOn
		self:UpdateBars()
	end
end

local function JPC_OnLoad(self)
	JPC.locked = true
	self:RegisterEvent("GROUP_ROSTER_UPDATE")
	self:SetScript("OnEvent",function(self,event,...) if self[event] then self[event](self,...) end end)
	for i=1,4 do
		local spellbar = CreateFrame("StatusBar", "raid"..i.."SpellBar", UIParent, "SmallCastingBarFrameTemplate");
		spellbar:SetScale(JaxPartyCastBars.db.profile.scale)
		CastingBarFrame_SetUnit(spellbar, "party"..i, true, true);
		spellBars[i] = spellbar
	end
	JPC:UpdateBars()
	self:SetScript("OnUpdate",JPC_OnUpdate)
end

function JPC_Unlock()
	local lock = not JPC.locked
	JPC.locked = not JPC.locked
	for i=1,4 do
		if spellBars[i] then
			if lock then
				spellBars[i]:SetAlpha(0)
			else
				spellBars[i]:Show()
				spellBars[i]:SetAlpha(1)
				spellBars[i].Icon:SetTexture(GetSpellTexture(116));
			end
		end
	end
end

JPC:RegisterEvent("VARIABLES_LOADED")
JPC:SetScript("OnEvent",JPC_OnLoad)
SLASH_JaxPartyCastbars1 = "/jpcb"
SLASH_JaxPartyCastbars2 = "/jaxpartycastbars"
SlashCmdList.JaxPartyCastbars = function(msg)
end
