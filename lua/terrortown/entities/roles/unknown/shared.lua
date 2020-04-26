if SERVER then
	AddCSLuaFile()

	resource.AddFile("materials/vgui/ttt/dynamic/roles/icon_unk.vmt")
end

function ROLE:PreInitialize()
	self.color = Color(190, 207, 210, 255)

	self.abbr = "unk" -- abbreviation
	self.unknownTeam = true
	self.surviveBonus = 1 -- bonus multiplier for every survive while another player was killed
	self.scoreKillsMultiplier = 2 -- multiplier for kill of player of another team
	self.scoreTeamKillsMultiplier = -4 -- multiplier for teamkill
	self.preventWin = true -- set true if role can't win (maybe because of own / special win conditions)

	self.defaultTeam = TEAM_NONE -- the team name: roles with same team name are working together
	self.defaultEquipment = SPECIAL_EQUIPMENT -- here you can set up your own default equipment

	self.conVarData =  {
		pct = 0.17, -- necessary: percentage of getting this role selected (per player)
		maximum = 1, -- maximum amount of roles in a round
		minPlayers = 6, -- minimum amount of players until this role is able to get selected
		random = 10 -- randomness of getting this role selected in a round
	}
end

if SERVER then
	hook.Add("PlayerDeath", "UnknownDeath", function(victim, infl, attacker)
		if victim:GetSubRole() == ROLE_UNKNOWN and IsValid(attacker) and attacker:IsPlayer() and attacker:GetSubRole() ~= ROLE_UNKNOWN then
			if INFECTED and attacker:GetSubRole() == ROLE_INFECTED then return end

			victim.unknownKiller = attacker
		end
	end)

	hook.Add("PostPlayerDeath", "UnknownPostDeath", function(ply)
		if ply:GetSubRole() == ROLE_UNKNOWN then
			local killer = ply.unknownKiller

			ply.unknownKiller = nil

			if IsValid(killer) and not ply.reviving then

				-- revive after 3s
				ply:Revive(3, function(p)
					if SIDEKICK and killer:GetSubRole() == ROLE_SIDEKICK then
						killer = killer:GetSidekickMate() or nil
					end

					if IsValid(killer) and killer:IsActive() then
						p:SetRole(killer:GetSubRole(), killer:GetTeam())
						p:SetDefaultCredits()

						SendFullStateUpdate()
					end
				end,
				function(p)
					return IsValid(p) and IsValid(killer) and killer:IsActive() and killer:Alive()
				end)
			end
		end
	end)
end
