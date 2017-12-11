--[[
  Copyright (c) 2013 David Young dayoung@goliathdesigns.com

  This software is provided 'as-is', without any express or implied
  warranty. In no event will the authors be held liable for any damages
  arising from the use of this software.

  Permission is granted to anyone to use this software for any purpose,
  including commercial applications, and to alter it and redistribute it
  freely, subject to the following restrictions:

   1. The origin of this software must not be misrepresented; you must not
   claim that you wrote the original software. If you use this software
   in a product, an acknowledgment in the product documentation would be
   appreciated but is not required.

   2. Altered source versions must be plainly marked as such, and must not be
   misrepresented as being the original software.

   3. This notice may not be removed or altered from any source
   distribution.
]]

require "Blackboard"
require "DebugUtilities"
require "KnowledgeSource"
require "SandboxUtilities"
require "Soldier"
require "SoldierController"
require "SoldierKnowledge"
require "SoldierLogic"

local soldier;
local soldierController;
local soldierLogic;
local soldierUserData;

function Agent_Cleanup(agent)
end

function Agent_HandleEvent(agent, event)
    if (event.source == "keyboard" and event.pressed) then
        local key = event.key;
        
        if (key == "1_key" or key == "numpad_1_key") then
            soldierController:QueueCommand(agent, SoldierController.Commands.IDLE);
        elseif (key == "2_key" or key == "numpad_2_key") then
            soldierController:QueueCommand(agent, SoldierController.Commands.SHOOT);
        elseif (key == "3_key" or key == "numpad_3_key") then
            soldierController:QueueCommand(agent, SoldierController.Commands.MOVE);
        elseif (key == "4_key" or key == "numpad_4_key") then
            soldierController:ImmediateCommand(agent, SoldierController.Commands.DIE);
        elseif (key == "5_key" or key == "numpad_5_key") then
            soldierController:QueueCommand(agent, SoldierController.Commands.CHANGE_STANCE);
        elseif (key == "6_key" or key == "numpad_6_key") then
            soldierController:QueueCommand(agent, SoldierController.Commands.RELOAD);
        end
    end
end

function Agent_Initialize(agent)
    soldier = Soldier_CreateSoldier(agent);
    weapon = Soldier_CreateWeapon(agent);

    soldierController = SoldierController.new(agent, soldier, weapon);

    Soldier_AttachWeapon(soldier, weapon);
    weapon = nil;

    soldierUserData = {};
    soldierUserData.agent = agent;
    soldierUserData.controller = soldierController;
    soldierUserData.blackboard = Blackboard.new(soldierUserData);
    soldierUserData.blackboard:Set("alive", true);
    soldierUserData.blackboard:Set("ammo", 10);
    soldierUserData.blackboard:Set("maxAmmo", 10);
    soldierUserData.blackboard:Set("maxHealth", Agent.GetHealth(agent));
    soldierUserData.blackboard:AddSource(
        "enemy",
        KnowledgeSource.new(SoldierKnowledge_ChooseBestEnemy));
    soldierUserData.blackboard:AddSource(
        "bestFleePosition",
        KnowledgeSource.new(SoldierKnowledge_ChooseBestFleePosition),
        5000);
    
    -- soldierLogic = SoldierLogic_DecisionTree(soldierUserData);
    -- soldierLogic = SoldierLogic_FiniteStateMachine(soldierUserData);
    soldierLogic = SoldierLogic_BehaviorTree(soldierUserData);
end

function Agent_Update(agent, deltaTimeInMillis)
    if (soldierUserData.blackboard:Get("alive")) then
        soldierLogic:Update(deltaTimeInMillis);
    end

    soldierController:Update(agent, deltaTimeInMillis);
end