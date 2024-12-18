--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-01-19 09:44:39
]]

---@class WRandom伪随机
WRandom = {}

--根据随机种子设定好了数据序列
--设定随机种子

--是否使用梅森算法
WRandom.common_index = 100;
WRandom.seed = 100;
--是否使用真随机
WRandom.useRealRandom = false;
function WRandom:setSeed( seed, seedTeam, useRealRandom )
    WRandom.seed = seed or 100;
    WRandom.seedTeam = seedTeam or -1
    WRandom.useRealRandom = useRealRandom or false;
    WRandom:initRandomPool(seedTeam);
end

--左闭右开
function WRandom:randomNum( min, max, isCommon )
    if WRandom.useRealRandom == true then
        return GlobalTools:ToFix( math.random( min, max ) )
    else
        if min == max then
            return min
        end
        min = min or 0;
        max = max or 0;

        if isCommon == nil then
            return GlobalTools:ToFix( min + WRandom:common_random() % (max - min) )
        else
            return min + WRandom:common_random() % (max - min)
        end
    end
end


function WRandom:initRandomPool()
    WRandom.random_pool = require("Core.Tool.BattleRandom");
    WRandom.common_index = WRandom.seed % #WRandom.random_pool;
end

function WRandom:common_random()
    if WRandom.common_index > #WRandom.random_pool then
        WRandom.common_index = 1;
    end
    local number =  WRandom.random_pool[WRandom.common_index]
    WRandom.common_index = WRandom.common_index + 1;
    return number or 0;
end

--[[
    @desc: 梅森螺旋算法 ---------------------------------------------------------
    author:{author}
    time:2020-05-07 19:36:06
    @return:
]]

--固定数
WRandom.FixNum = 1812433253
WRandom.N = 624
WRandom.M = 397
WRandom.MT = nil
WRandom.index = 0
WRandom.isInit = false




return WRandom