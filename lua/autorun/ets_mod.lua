function tableToString(o, listIndexes)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
		 if listIndexes == nil or listIndexes == false then
			 s = s .. tableToString(v) .. ','
		 elseif listIndexes == true then
			s = s .. '['..k..'] = ' .. tableToString(v) .. ','
		 end
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

-- I don't know if I should define this here but I can move it later
function interpPuts(putString) -- inPUT outPUT STRING
	local temp = {}
    local inputs = {}
    local outputs = {}
	
	local i = 1
    local j = 1

	for sub in (putString .. ";"):gmatch("([^;]*)%;") do
		temp[i] = sub
		--print(sub)
		i = i+1
	end

    for i = 1, #temp do
		local ins = (temp[i] .. ":"):match("([^:]*)%:")
			inputs[i] = ins
			temp[i] = temp[i]:gsub(ins .. ":", "")
			--print("ins: " .. ins)
	end
	
	
	for i = 1, #temp do
		j = 1
		outputs[i] = {}
		for ets_outs in (temp[i] .. ","):gmatch("([^,]*)%,") do
			outputs[i][j] = ets_outs
			--print(ets_outs)
			j = j+1
		end
	end
	
	-- Add type TODO: Do it dynamically
	--for i = 1, #inputs do
		--inputs[i] = inputs[i] .. " [NORMAL]"
	--end
	
	return inputs, outputs
end

function flattenTable(arr)
	local result = { }
	
	local function flattenTable(arr)
		for _, v in ipairs(arr) do
			if type(v) == "table" then
				flattenTable(v)
			else
				table.insert(result, v)
			end
		end
	end
	
	flattenTable(arr)
	return result
end

function mergeTypes(names, _type)
	local out = {}
	for s = 1, #names do
		out[2*s-1] = names[s]
		out[2*s] = _type
	end
	return out
end

function appendTypes(names, _type)
	local _names = {}
	for s = 1, #names do
		_names[s] = names[s] .. " [" .. _type .. "]"
	end
	return _names
end

function removeDupes(items, clean)
  local r,dup,c,NaN = {},{},1,{}  
  for i=1,#items do
    local e = items[i]
    local k = e~=e and NaN or e
    if k~=nil and not dup[k] then  
      c, r[c], dup[k]= c+1, e, true 
    end
  end
  if clean == nil or clean == true then return cleanNils(r)
  else return r end
end

function cleanNils(t)
  local ans = {}
  for _,v in pairs(t) do
    ans[ #ans+1 ] = v
  end
  return ans
end


print("EmergencyTemporalShift's mod has loaded")
