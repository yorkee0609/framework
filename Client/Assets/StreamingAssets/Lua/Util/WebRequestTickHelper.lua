------------------- WebRequestTickHelper

local M = {}
M.m_webRequestTickMgr = CS.wt.framework.WebRequestTickMgr.Inst
M.inited = false
M.bundleLoadComplete = false
function M:init()
	print("isUseAsync: " ..(CS.wt.framework.AssetLoaderHelper.Inst.isUseAsync and "1" or "0"))
	if CS.t.framework.AssetLoaderHelper.Inst.isUseAsync and self.inited ~= true then
		self.inited = true
		self.m_webRequestTickMgr:SetFunc("ActiveDownload",function(obj)
			SDKUtil:getNetworkState(function(params)
				netType = params.data
				local webStr = ""
				if netType == "wifi" or newNetType == "wifi" then
					webStr = "(当前为wifi网络环境)"
				elseif netType == "4G" or netType == "5G" or netType == "2G" or netType == "3G" or newNetType == "4G" then
					webStr = "(当前为非wifi网络环境)"
				else
					webStr = "(请确保网络正常连接)"
				end
				local params = {
					on_ok_call = function(msg)
						static_rootControl:openView("Pops.CommonLoadingPop", nil)
					end,
					on_cancel_call = function(msg)
					end,
					no_close_btn = false,
					tow_close_btn = true,
					title = Language:getTextByKey("new_str_0005"),
					text = "游戏客户端内资源不足以流畅运行后续游戏，是否直接下载剩余游戏资源?"..webStr--Language:getTextByKey("new_str_1061")
				}
				static_rootControl:openView("Pops.CommonPop", params)
			end)

		end)


		self.m_webRequestTickMgr:SetFunc("CompleteDownload",function(obj)
			self.bundleLoadComplete = true
		end)
	end
end




return M
