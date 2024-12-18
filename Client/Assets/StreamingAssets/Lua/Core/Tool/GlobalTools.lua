---@class GlobalTools
GlobalTools = {}
--0.01
GlobalTools.base0_0_1 = 10;
--0.02
GlobalTools.base0_0_2 = 20
--0.025
GlobalTools.base0_0_2_5 = 25;
--0.033
GlobalTools.base0_0_3_3 = 33;
--0.05
GlobalTools.base0_0_5 = 51
--0.066
GlobalTools.base0_0_6_6 = 67;
--0.07
GlobalTools.base0_0_7 = 71
--0.15
GlobalTools.base0_1_5 = 153

--0.1
GlobalTools.base0_1 = 102;
--0.2
GlobalTools.base0_2 = 204;
--0.3
GlobalTools.base0_3 = 307;
--0.4
GlobalTools.base0_4 = 408;
--0.5
GlobalTools.base0_5 = 512;
--0.6
GlobalTools.base0_6 = 614;
--0.7
GlobalTools.base0_7 = 716;
--0.8
GlobalTools.base0_8 = 820;
--1.2
GlobalTools.base1_2 = 1228
--1.3
GlobalTools.base1_3 = 1331
--1.5
GlobalTools.base1_5 = 1536;
--1.7
GlobalTools.base1_7 = 1740;
--1.8
GlobalTools.base1_8 = 1843;
--2.5
GlobalTools.base2_5 = 2560;

--0
GlobalTools.base0 = 0;
--1
GlobalTools.base1 = 1024;
--2
GlobalTools.base2 = 2048;
--3
GlobalTools.base3 = 3072;
--4
GlobalTools.base4 = 4096;
--5
GlobalTools.base5 = 5120;
--6
GlobalTools.base6 = 6144;
--7
GlobalTools.base7 = 7168;
--8
GlobalTools.base8 = 8192;
--9
GlobalTools.base9 = 9216;
--10
GlobalTools.base10 = 10240;
--12
GlobalTools.base12 = 12288;
--13
GlobalTools.base13 = 13312;
--15
GlobalTools.base15 = 15360;
--30
GlobalTools.base30 = 30720;
--40
GlobalTools.base40 = 40960;
--50
GlobalTools.base50 = 51200;
--60
GlobalTools.base60 = 61440;

GlobalTools.base80 = 81920;
--90
GlobalTools.base90 = 92160;
--100
GlobalTools.base100 = 102400;
--120
GlobalTools.base120 = 122880
--165
GlobalTools.base165 = 168960
--180
GlobalTools.base180 = 184320
--441
GlobalTools.base441 = 451584
--480
GlobalTools.base480 = 491520
--512
GlobalTools.base512 = 524288
--999
GlobalTools.base999 = 1022976;
--1000
GlobalTools.base1000 = 1024000;
--1007
GlobalTools.base1007 = 1031168;
-- 1024
GlobalTools.base1024 = 1048576;
-- 2000
GlobalTools.base2000 = 2048000
--10000
GlobalTools.base10000 = 10240000;

GlobalTools.PI = 3216;

GlobalTools.Num = 0;

GlobalTools.baseNums = {
	[0] = GlobalTools.base0,
	[1] = GlobalTools.base1,
	[2] = GlobalTools.base2,
	[3] = GlobalTools.base3,
	[4] = GlobalTools.base4,
	[5] = GlobalTools.base5,
	[6] = GlobalTools.base6,
	[7] = GlobalTools.base7,
	[8] = GlobalTools.base8,
	[9] = GlobalTools.base9,
	[10] = GlobalTools.base10,
}



local total_bit_cnt = 64
local f_bit_cnt = 10
local i_bit_cnt = total_bit_cnt - f_bit_cnt
local f_mask = (1 << f_bit_cnt) - 1
local i_mask = -1 & ~f_mask
local f_range = f_mask + 1
local min_val = -(-math.mininteger >> f_bit_cnt)
local max_val = math.maxinteger >> f_bit_cnt


local fontPool = {}

local curveData = nil
--标准值
GlobalTools.one = 1000
--浮点数 转 定点数
function GlobalTools:ToFix( v )
	--return math.modf( v * GlobalTools.one ) 
	--return fixmath.tofix(v)
	if math.type(v) == "float" then
		Logger.logError(" GlobalTools:ToFix 的参数不能是浮点数  ")
		Logger.logError(debug.traceback())
		return GlobalTools:CommonToFix( v );
	end
	return v << f_bit_cnt
end

--- 将指定的数转换成定点数（战斗中不使用转换）
function GlobalTools:ToExistFixNum(v)
	if GlobalTools.baseNums[v] then
		return GlobalTools.baseNums[v]
	end
	Logger.logError(string.format("找不到%s定点数", tostring(v)))
	return GlobalTools:ToFix(v)
end

--定点数 转 浮点数
function GlobalTools:ToFloat( v )
	--return v / GlobalTools.one
	--return v:tonumber()
	local symbol = 1
	if v < 0 then
		v = -v
		symbol = -symbol
	end
	return symbol*((v >> f_bit_cnt) + (v & f_mask) / f_range)
end

--时间误差转换函数
function GlobalTools:ToFixTime( fix )
	return fix - GlobalTools:Div( fix, GlobalTools.base1024 ) * 4;
end

function GlobalTools:ToFloatTime( fix )
	return fix + GlobalTools:Div( fix, GlobalTools.base1024 ) * 4;
end


function GlobalTools:FloatToFixTable( target_table )
	local result = {}
	for k,v in pairs(target_table) do
		if type(v) == "number" then
			local value = GlobalTools:ToFix( math.floor(v) );
			result[k] = value;
		else
			result[k] = v;
		end
	end
	return result;
end

--返回ACos值 返回角度 参数 是 -1024 ~ 1024 之间
local acosData = require("Core.Tool.AcosData");
function GlobalTools:ACos( radianFix )
	local fix_value = GlobalTools:Clamp01(radianFix)
    return acosData[fix_value]
end

--返回Cos值 参数是角度 angle
local cosData = require("Core.Tool.CosData");
function GlobalTools:Cos( angle )
	return cosData[angle] or 0
end

--返回Sin值 参数是角度 angle
local sinData = require("Core.Tool.SinData");
function GlobalTools:Sin( angle )
	return sinData[angle] or 0
end


--普通数 转 扩大10000倍的数
function GlobalTools:CommonToScale( v )
	return v * GlobalTools.one
end

--扩大10000倍的数 转 普通数
function GlobalTools:ScaleToCommon( v )
	return v / GlobalTools.one
end

-- 普通数转换成定点数
function GlobalTools:CommonToFix( num )
	return GlobalTools:Div( GlobalTools:ToFix( math.floor(num * GlobalTools.one) ), GlobalTools.base1000 ) 
end
-- 定点数转普通数
function GlobalTools:FixToCommon( num )
	return math.floor( GlobalTools:ToFloat( num ) / GlobalTools.one );
end

GlobalTools.dropFlyTarget = nil;

--转换成int值
function GlobalTools:toint(n)
    local s = tostring(n)
    local i,j = s:find('%.')
    if i then
        return tonumber(s:sub(1,i-1))
    else
        return n
    end
end

GlobalTools.curve = {};



function GlobalTools:Abs( v )
	if v > 0 then
		return v;
	end
	return -v;
end

function GlobalTools:LoadCurveData()
	curveData = require("Core.Tool.CurveData");
end

function GlobalTools:GetCurve(name, isY)
	local curCurveData = curveData[name];
	if curCurveData ~= nil then
		if isY then
			if GlobalTools.curve[name.."curveY"] == nil then
				GlobalTools.curve[name.."curveY"] = require("Core.Tool.Curve").new();
			end
			local curveY = curCurveData["curveY"]
			GlobalTools.curve[name.."curveY"]:setData(curveY);
			return GlobalTools.curve[name.."curveY"];
		else
			if GlobalTools.curve[name.."curveX"] == nil then
				GlobalTools.curve[name.."curveX"] = require("Core.Tool.Curve").new();
			end
			local curveX = curCurveData["curveX"]
			GlobalTools.curve[name.."curveX"]:setData(curveX);
			return GlobalTools.curve[name.."curveX"];
		end
	end
end


function GlobalTools:Clamp( value, min, max )
	if value < min then
		return min
	elseif value > max then
		return max
	end
	return value
end


function GlobalTools:Clamp01( value )
	if value < 0 then
		return 0
	elseif value > GlobalTools.base1 then
		return GlobalTools.base1
	end
	return value
end

--平方
function GlobalTools:ToFix2( v )
	-- return math.modf( v * v * GlobalTools.one * GlobalTools.one ) 
	return  GlobalTools:Mul(v,v);
end

function GlobalTools:Max( v1, v2 )
	if v1 > v2 then
		return v1;
	else
		return v2;
	end
end

function GlobalTools:Min( v1, v2 )
	if v1 < v2 then
		return v1;
	else
		return v2;
	end
end

function GlobalTools:ToFixVector3( vector3 )
	local fixVec3 = FixVector3.New(0,0,0)
	fixVec3.x = GlobalTools:CommonToFix(vector3.x);
	fixVec3.y = GlobalTools:CommonToFix(vector3.y);
	fixVec3.z = GlobalTools:CommonToFix(vector3.z);
	return fixVec3
end


--3D方向 无平方距离
function GlobalTools:Distance3DOne( startP, endP )
	local dir = startP - endP
	local dir_distance = dir:Magnitude()
    --我和敌人之间的距离
    return dir_distance
end


--3D方向 平方距离
function GlobalTools:Distance3D( startP, endP )
	local dir = startP - endP
	local dir_distance = dir:SqrMagnitude()
    --我和敌人之间的距离
    return dir_distance
end


--去除了y方向的 无平方距离
function GlobalTools:DistanceOne( startP, endP )
	if startP == endP then
		return GlobalTools.base0;
	end
    --敌人的位置
	local startP_y = startP.y
    startP.y = GlobalTools.base0
	--我的位置
	local endP_y = endP.y
    endP.y = GlobalTools.base0
	local dir = startP - endP
	local dir_distance = dir:Magnitude()
	startP.y = startP_y
	endP.y = endP_y
    --我和敌人之间的距离
    return dir_distance
end


-- radius 半径 是单一距离
-- 检测 半径 radius 是否 小于 2点之间的距离
-- 小于就是 true 
-- 大于就是 false
function GlobalTools:CheckDistanceMinTwoPoint( startP, endP, radius )
	local x_cha = startP.x - endP.x;
	if radius < GlobalTools:Abs(x_cha) then
		return true
	end
	local z_cha = startP.z - endP.z;
	if radius < GlobalTools:Abs(z_cha) then
		return true
	end
	local distance = GlobalTools:Distance( startP, endP );
	return GlobalTools:ToFix2(radius) < distance;
end


--去除了y方向的 平方距离
function GlobalTools:Distance( startP, endP )
	if startP == endP then
		return GlobalTools.base0;
	end
	local start_x = startP.x;
	local start_z = startP.z;
	local end_x = endP.x;
	local end_z = endP.z;
    --敌人的位置
	--local startP_y = startP.y
    --startP.y = GlobalTools.base0
	----我的位置
	--local endP_y = endP.y
    --endP.y = GlobalTools.base0
	--local dir = startP - endP
	----我和敌人之间的方向( 规范到 0 ~ 1 之间了 )
	--local dir_distance = dir:SqrMagnitude()
	--startP.y = startP_y
	--endP.y = endP_y
	local x_cha = start_x - end_x;
	local z_cha = start_z - end_z;
	local x_2 = GlobalTools:Mul(x_cha,x_cha);
	local z_2 = GlobalTools:Mul(z_cha,z_cha);
    --我和敌人之间的距离
    return x_2 + z_2;
end


function GlobalTools:Dir3D( startP, endP )
	local dir = startP - endP
	--我和敌人之间的方向( 规范到 0 ~ 1 之间了 )
	local dir_normal = dir:SetNormalize()
    return dir_normal
end


function GlobalTools:Dir3DOne( startP, endP )
	local dir = startP - endP
	--我和敌人之间的方向( 规范到 0 ~ 1 之间了 )
	local dir_normal = dir:SetNormalize()
    return dir_normal;
end


--start 和 end 之间的方向
function GlobalTools:Dir( startP, endP )
	if startP == nil or endP == nil and startP == endP then
		return FixVector3.New(0,0,0);
	end
	--敌人的位置
	local startP_y = startP.y
    startP.y = GlobalTools.base0;
	--我的位置
	local endP_y = endP.y
    endP.y = GlobalTools.base0;
	local dir = startP - endP
	local dir_normal = dir:SetNormalize()
	startP.y = startP_y
	endP.y = endP_y
    return dir_normal
end


function GlobalTools:localToWorldPos( parent, localPos )

	 local forward = Vector3.forward;
	 if parent.forward ~= nil then
	 	forward = parent.forward:toVector3()
	 end	
	 local qua = Quaternion.FromToRotation(Vector3.forward, forward)
	 local pos = GlobalTools:ToFixVector3(Quaternion.MulVec3(qua, localPos:toVector3()))
	 if parent.position ~= nil then
	 	pos = parent.position + GlobalTools:ToFixVector3(Quaternion.MulVec3(qua, localPos:toVector3()))
	 end
	 return pos
end

function GlobalTools:Sub( fix_a, fix_b, fix )
	-- local result = FixVector3(0,0,0);
	--SetPositionBig(pos)local result = {x = 0,y = 0,z=0}
	fix.x = fix_a.x - fix_b.x;
	fix.y = fix_a.y - fix_b.y;
	fix.z = fix_a.z - fix_b.z;
end

--2个定点数相乘
function GlobalTools:Mul( fix_a, fix_b )
	--local result = math.floor( (fix_a * fix_b) / GlobalTools.one )
	--return result;
	--return fix_a * fix_b / GlobalTools.base1
	local symbol = 1
	if fix_a < 0 then
		fix_a = -fix_a
		symbol = -symbol
	end
	if fix_b < 0 then
		fix_b = -fix_b
		symbol = -symbol
	end
	return symbol*(fix_a * fix_b + (f_range >> 1) >> f_bit_cnt)
end

--2个定点数相除
function GlobalTools:Div( fix_a, fix_b )
	--local result = math.floor( (fix_a / fix_b) * GlobalTools.one ) 
	--return result;
	--return fix_a / fix_b * GlobalTools.base1
	if fix_b == 0 then
		return 0;
	end
	local symbol = 1
	if fix_a < 0 then
		fix_a = -fix_a
		symbol = -symbol
	end
	if fix_b < 0 then
		fix_b = -fix_b
		symbol = -symbol
	end
	return symbol*((fix_a << f_bit_cnt) // fix_b)
end

GlobalTools.Rad2Deg = GlobalTools:Div( GlobalTools.base180, GlobalTools.PI )
GlobalTools.Deg2Rad = GlobalTools:Div( GlobalTools.PI,GlobalTools.base180 )


function GlobalTools:FastSqart(dx, dy)
	local min, max, approx;
	if dx < 0 then
		dx = -dx
	end
	if dy < 0 then
		dy = -dy
	end
	if dx < dy then
		min = dx
		max = dy
	else
		min = dy
		max = dx
	end
	approx = self:Mul(max , self.base1007) + self:Mul(min , self.base441)
	if max < (min << 4) then
		approx = approx - self:Mul(max, self.base40)
	end
	-- add 512 for proper rounding
	return ((approx + 512) >> 10)
end


function GlobalTools:FastSqartCommon(dx, dy)
	local min, max, approx;
	if dx < 0 then
		dx = -dx
	end
	if dy < 0 then
		dy = -dy
	end
	if dx < dy then
		min = dx
		max = dy
	else
		min = dy
		max = dx
	end
	approx = (max * 1007) + (min * 441)
	if max < (min << 4) then
		approx = approx - max * 40
	end
	-- add 512 for proper rounding
	return ((approx + 512) >> 10)
end


-- 在父 Transform 找子 Transform
function GlobalTools:FindTransform( root, name )
	local tran = nil;
    if root.name == name then
        return root
    end

    for i = 1,root.childCount do
        local trans = root:GetChild(i-1)
        tran = GlobalTools:FindTransform(trans, name)
        if tran ~= nil then
            return tran
        end
    end
    return nil
end

--通过组件名字获取 
function GlobalTools:GetComponents( root, componentName )
	local list = List.new()
	GlobalTools:GetComponentsChild(root, componentName, list)
	return list
end


function GlobalTools:GetComponentsChild( root, componentName, list )
	local com = root.gameObject:GetComponent(componentName)
	if com ~= nil then
		list:add(com)
	end

	for i = 1,root.childCount do
        local child = root:GetChild(i-1)
        GlobalTools:GetComponentsChild(child, componentName, list)
    end
end


function GlobalTools:GetPartOfList(list, count)
	local temp = list:clone()
	if temp.Count <= count then
		return temp
	else
		local result = List.new()
		local index = 0
		while index < count do
			result:add(temp:get(0))
			temp:removeAt(0)
			index = index + 1
		end
		return result
	end
	
end

---@return List
function GlobalTools:RandomList(list, count)
	local temp = list:clone()
	if temp.Count <= count then
		return temp
	else
		local result = List.new()
		for i = 1, count do
			local index = WRandom:randomNum(0,temp.Count,true);
			result:add(temp:get(index))
			temp:removeAt(index)
		end
		return result
	end
end

---@return List 
function GlobalTools:RandomList(list, count)
	local temp = list:clone()
	if temp.Count <= count then
		return temp
	else
		local result = List.new()
		for i = 1, count do
			local index = WRandom:randomNum(0,temp.Count,true);
			result:add(temp:get(index))
			temp:removeAt(index)
		end
		return result
	end
end

---@param list List
---@return List 保留n个随机
function GlobalTools:RetainRandomByCount(list, count)
	while list.Count > count do
		local index = WRandom:randomNum(0, list.Count,true);
		list:removeAt(index)
	end
	return list
end

---@param arr []
function GlobalTools:RandomOneFromArray(arr)
	if #arr == 1 then
		return arr[1]
	elseif #arr > 1 then
		local index = WRandom:randomNum(0, #arr,true);
		return arr[index+1]
	end
	return nil
end

---@param list List
function GlobalTools:RandomOneFromList(list)
	if list.Count == 1 then
		return list:get(0)
	elseif list.Count > 1 then
		local index = WRandom:randomNum(0, list.Count,true);
		return list:get(index)
	end
	return nil
end

function GlobalTools:CheckRandom1(rate)
	return self:CheckRandom100(GlobalTools:Mul(rate, GlobalTools.base100))
end

function GlobalTools:CheckRandom100(rate)
	return WRandom:randomNum(0, 100) < rate
end


function GlobalTools:Lerp( vec, from, to, t )
	--定点数的百分比
	t = GlobalTools:Clamp01(t)
	vec.x = from.x + GlobalTools:Mul( (to.x - from.x), t )
	vec.y = from.y + GlobalTools:Mul( (to.y - from.y), t )
	vec.z = from.z + GlobalTools:Mul( (to.z - from.z), t )
end


-- nNum 是定点数
function GlobalTools:GetPreciseDecimal(nNum, n)
	if type(nNum) ~= "number" then
		return nNum;
	end
	n = n or 0;
	n = math.floor(n)
	if n < 0 then
		n = 0;
	end
	local nDecimal = 10 ^ n
	local nTemp = math.floor(nNum * nDecimal);
	local nRet = nTemp / nDecimal;
	return nRet;
end


function GlobalTools:ToStringVec( vec ) 
	return "("..vec.x..","..vec.y..","..vec.z..")";
end

function GlobalTools:ToCharacterHan(num)
	if type(num) ~= "number" then
		return nil;
	end
	if num == 0 then
		return "零"
	elseif num  == 1 then
		return "一"
	elseif num  == 2 then
		return "二"
	elseif num  == 3 then
		return "三"
	elseif num  == 4 then
		return "四"
	elseif num  == 5 then
		return "五"
	elseif num  == 6 then
		return "六"
	elseif num  == 7 then
		return "七"
	elseif num  == 8 then
		return "八"
	elseif num  == 9 then
		return "九"
	end
end


return GlobalTools