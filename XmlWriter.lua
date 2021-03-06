--[[
This file is part of markuplanguagewriter. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/markuplanguagewriter/master/COPYRIGHT. No part of markuplanguagewriter, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of markuplanguagewriter. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/markuplanguagewriter/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local markuplanguagewriter = halimede.require.markuplanguagewriter
local Writer = markuplanguagewriter.Writer


local XmlWriter = moduleclass('XmlWriter', Writer)

function module:initialize()
	Writer.initialize(self)
end

assert.globalTableHasChieldFieldOfTypeFunctionOrCall('string', 'gsub')
function _constructAttribute(alwaysEscapedCharacters, attributesArray, attributeName, attributeValue)	
	local quotationMark = '"'
	local doubleQuotesPresent = false
	local singleQuotePresent = false
	
	local escapedAttributeValue = attributeValue:gsub('[<>&"\']', function(matchedCharacter)
		local result = alwaysEscapedCharacters[matchedCharacter]
		if result ~= matchedCharacter then
			return result
		end
		
		if matchedCharacter == '"' then
			quotationMark = "'"
			doubleQuotesPresent = true
		elseif matchedCharacter == '\'' then
			singleQuotePresent = true
		end
		
		return matchedCharacter
	end)

	local reEscapeBecauseBothDoubleAndSingleQuotesArePresent = doubleQuotesPresent and singleQuotePresent
	if reEscapeBecauseBothDoubleAndSingleQuotesArePresent then
		quotationMark = '"'
		
		escapedAttributeValue = attributeValue:gsub('[<>&"]', function(matchedCharacter)
			local result = alwaysEscapedCharacters[matchedCharacter]
			if result ~= matchedCharacter then
				return result
			end
			
			if matchedCharacter == '"' then
				-- We do not return '&quot;' as it is more verbose; we save a byte
				return '&#38;'
			else
				return matchedCharacter
			end
		end)
	
	end
	
	attributesArray:insert(' ' .. attributeName .. '=' .. quotationMark .. escapedAttributeValue .. quotationMark)
end

module.static.singleton = module:new()
