local function get_unique_edl_file()
	local path = mp.get_property("path")
	if not path then
		mp.osd_message("No file currently playing.", 2)
		mp.msg.error("No file currently playing.")
		return nil
	end

	local base_name = path:gsub("%.[^%.]+$", "") -- Remove extension
	local edl_file = base_name .. ".edl"
	local counter = 1

	-- Find a unique filename
	while io.open(edl_file, "r") do
		edl_file = string.format("%s-%d.edl", base_name, counter)
		counter = counter + 1
	end

	-- Create the new file with the header
	local file = io.open(edl_file, "w")
	if file then
		file:write("# mpv EDL v0\n")
		file:write("# FILE,start,length,end\n")
		file:close()
	else
		mp.osd_message("Failed to create new EDL file.", 2)
		mp.msg.error("Failed to create new EDL file.")
		return nil
	end

	return edl_file
end

local edl_file = nil
local edl_in_progress = nil -- Tracks the in-progress segment

local function mark_in()
	if edl_in_progress then
		mp.osd_message("Already marked IN. Complete the segment with OUT.", 2)
		return
	end

	if not edl_file then
		edl_file = get_unique_edl_file()
		if not edl_file then
			return
		end
	end

	edl_in_progress = {
		file = mp.get_property("path"),
		time_in = mp.get_property_number("time-pos"),
	}

	local message = string.format("Marked IN at %.2f seconds", edl_in_progress.time_in)
	mp.osd_message(message, 2)
	mp.msg.info(message)
end

local function finalize_ed_record(time_out)
	if not edl_in_progress then
		mp.osd_message("No IN marker to complete. Use IN first.", 2)
		return
	end

	if not edl_file then
		edl_file = get_unique_edl_file()
		if not edl_file then
			return
		end
	end

	local length = time_out - edl_in_progress.time_in
	if length < 0 then
		mp.osd_message("Invalid segment: OUT is before IN.", 2)
		mp.msg.error("Invalid segment: OUT is before IN.")
		return
	end

	local file = io.open(edl_file, "a")
	if file then
		file:write(
			string.format("%s,%.6f,%.6f,%.6f\n", edl_in_progress.file, edl_in_progress.time_in, length, time_out)
		)
		file:close()
		local message = string.format("Marked OUT at %.2f seconds (Duration: %.2f seconds)", time_out, length)
		mp.osd_message(message, 2)
		mp.msg.info(message)
		edl_in_progress = nil -- Reset after completing the segment
	else
		mp.osd_message("Failed to open EDL file for appending.", 2)
		mp.msg.error("Failed to open EDL file for appending.")
	end
end

local function mark_out()
	finalize_ed_record(mp.get_property_number("time-pos"))
end

local function mark_end()
	finalize_ed_record(mp.get_property_number("duration"))
end

mp.add_key_binding("Ctrl+i", "mark_in", mark_in)
mp.add_key_binding("Ctrl+o", "mark_out", mark_out)
mp.add_key_binding("Ctrl+p", "mark_end", mark_end)
