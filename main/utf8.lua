function utf8_sub(s, i, j)
	j = j or i
	local pos = 1
	local current_char = 1
	local start_byte, end_byte

	while pos <= #s do
		local char_byte = s:byte(pos)
		local char_len

		if char_byte >= 0 and char_byte <= 127 then
			char_len = 1
		elseif char_byte >= 194 and char_byte <= 223 then
			char_len = 2
		elseif char_byte >= 224 and char_byte <= 239 then
			char_len = 3
		elseif char_byte >= 240 and char_byte <= 244 then
			char_len = 4
		end

		if current_char == i then
			start_byte = pos
		end
		if current_char == j then
			end_byte = pos + char_len - 1
			break
		end

		pos = pos + char_len
		current_char = current_char + 1
	end

	return s:sub(start_byte, end_byte)
end


function utf8_len(s)
	local pos = 1
	local length = 0

	while pos <= #s do
		local char_byte = s:byte(pos)

		-- Определяем длину символа по первому байту UTF-8
		local char_len
		if char_byte >= 0 and char_byte <= 127 then
			char_len = 1
		elseif char_byte >= 194 and char_byte <= 223 then
			char_len = 2
		elseif char_byte >= 224 and char_byte <= 239 then
			char_len = 3
		elseif char_byte >= 240 and char_byte <= 244 then
			char_len = 4
		else
			
		end

		length = length + 1
		pos = pos + char_len
	end

	return length
end

local utf8_upper_map = {
	-- Русские буквы
	["а"] = "А", ["б"] = "Б", ["в"] = "В", ["г"] = "Г", ["д"] = "Д", ["е"] = "Е", ["ё"] = "Ё", ["ж"] = "Ж",
	["з"] = "З", ["и"] = "И", ["й"] = "Й", ["к"] = "К", ["л"] = "Л", ["м"] = "М", ["н"] = "Н", ["о"] = "О",
	["п"] = "П", ["р"] = "Р", ["с"] = "С", ["т"] = "Т", ["у"] = "У", ["ф"] = "Ф", ["х"] = "Х", ["ц"] = "Ц",
	["ч"] = "Ч", ["ш"] = "Ш", ["щ"] = "Щ", ["ъ"] = "Ъ", ["ы"] = "Ы", ["ь"] = "Ь", ["э"] = "Э", ["ю"] = "Ю", ["я"] = "Я",
	-- Английские буквы
	["a"] = "A", ["b"] = "B", ["c"] = "C", ["d"] = "D", ["e"] = "E", ["f"] = "F", ["g"] = "G",
	["h"] = "H", ["i"] = "I", ["j"] = "J", ["k"] = "K", ["l"] = "L", ["m"] = "M", ["n"] = "N", ["o"] = "O",
	["p"] = "P", ["q"] = "Q", ["r"] = "R", ["s"] = "S", ["t"] = "T", ["u"] = "U", ["v"] = "V",
	["w"] = "W", ["x"] = "X", ["y"] = "Y", ["z"] = "Z"
}

function utf8_to_upper(s)
	local result = {}
	local pos = 1

	while pos <= #s do
		local char_byte = s:byte(pos)
		local char_len
		local char

		-- Определяем длину символа по первому байту UTF-8
		if char_byte >= 0 and char_byte <= 127 then
			char_len = 1
		elseif char_byte >= 194 and char_byte <= 223 then
			char_len = 2
		elseif char_byte >= 224 and char_byte <= 239 then
			char_len = 3
		elseif char_byte >= 240 and char_byte <= 244 then
			char_len = 4
		else
			error("Неверная кодировка UTF-8")
		end

		-- Извлекаем символ
		char = s:sub(pos, pos + char_len - 1)

		-- Преобразуем символ в верхний регистр, если есть соответствие
		result[#result + 1] = utf8_upper_map[char] or char

		pos = pos + char_len
	end

	-- Объединяем обратно в строку
	return table.concat(result)
end
