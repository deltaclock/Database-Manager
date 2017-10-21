local white = Color.new(255,255,255)
local red =  Color.new(255,51,51)-- Create a new color
--[[TODO 
*add file size check
*add app.db options
*Themeing options
]]
System.createDirectory("ux0:/data/iconsbak")

function confirm(text)
	System.setMessage(text, false, BUTTON_YES_NO)
	while true do
		Graphics.initBlend()
		Screen.clear()
		Graphics.termBlend()
		Screen.flip()
		local state = System.getMessageState()
		if state == FINISHED then
			return true
		elseif state == CANCELED then
			return false
		end
	end
end

function printText(text1, y1, color, text2, y2)--y1-y2 vertical pos
	local timer = Timer.new()
	time = 0
	while true do
		time = math.ceil(3-Timer.getTime(timer)/1000)
		Graphics.initBlend()
		Screen.clear()
		Graphics.debugPrint(10, y1, text1, color)
		Graphics.debugPrint(10, y2, text2..time.." sec", white)
		Graphics.termBlend()
		Screen.flip()
		if time == 0 then
			Timer.destroy(timer)
		 	break 
		end
	end
end

function wipeDB()
	local flag = confirm("Your database will be wipped!\nYour system will reboot!\nProceed?")
	if flag then 
		System.deleteFile("ur0:shell/db/app.db")
		printText("", 45, white, "Rebooting in ", 5)
		System.reboot()
	else
		printText("Wipe canceled", 5, red, "Exiting in ", 45)
		System.exit()
	end			
end

function updateDB()
	System.deleteFile("ux0:/id.dat")
	local flag = confirm("Do you wanna reboot now?")
	if flag then 
		printText("", 45, white, "Rebooting in ", 5)
		System.reboot()
	else
		printText("Reboot canceled", 5, red, "Exiting in ", 45)
		System.exit()
	end		
end

function copy(file1, file2)--move file1 to file2
	System.deleteFile(file2)
	file = System.openFile(file1, FREAD)
	size = System.sizeFile(file)
	data = System.readFile(file, size)
	newfile = System.openFile(file2, FCREATE)
	System.writeFile(newfile, data, size)
end

while true do
	-- Draw a string on the screen
	Graphics.initBlend()
	Screen.clear()
	Graphics.debugPrint(10, 5, "Database Manager by deltaclock", white)
	Graphics.debugPrint(10, 45, "Press X to backup your icon layout.", white)
	Graphics.debugPrint(10, 65, "Press O to restore your icon layout.", white)
	Graphics.debugPrint(10, 85, "Press L to update your database.", white)
	Graphics.debugPrint(10, 105, "Press R to completely wipe your database.", white)
	Graphics.debugPrint(10, 125, "Press Δ to exit.", white)
	Graphics.termBlend()
	
	-- Update screen (For double buffering)
	Screen.flip()
	
	-- Check controls for exiting
	if Controls.check(Controls.read(), SCE_CTRL_TRIANGLE) then
		System.exit();
	end

	--check for db update
	if Controls.check(Controls.read(), SCE_CTRL_LTRIGGER) then
		updateDB()
	end

	--check for db wipe
	if Controls.check(Controls.read(), SCE_CTRL_RTRIGGER) then
		wipeDB()
	end

	-- Check controls for backup
	if Controls.check(Controls.read(), SCE_CTRL_CROSS) then
			if System.doesFileExist("ux0:/iconlayout.ini") and System.doesFileExist("ur0:/shell/db/app.db") then

				if System.doesFileExist("ux0:/data/iconsbak/iconlayout.ini") or System.doesFileExist("ur0:/shell/db/app.db") then

					flag = confirm("Your previous backup will be overwritten!!\nDo you wanna continue?")

						if flag then
							copy("ux0:/iconlayout.ini", "ux0:/data/iconsbak/iconlayout.ini")
							copy("ur0:/shell/db/app.db", "ux0:/data/iconsbak/app.db")
							printText("Backup completed", 5, white, "Exiting in ", 45)
						else
							printText("Backup canceled", 5, white, "Exiting in ", 45)	
						end	
				else		
					copy("ux0:/iconlayout.ini", "ux0:/data/iconsbak/iconlayout.ini")
					copy("ur0:/shell/db/app.db", "ux0:/data/iconsbak/app.db")
					printText("Backup completed", 5, white, "Exiting in ", 45)
				end
			else

				flag = confirm("No icons file in your system!\nDo you wanna wipe the database to create the files?")
				if flag then
					wipeDB()
				else
					printText("Operation canceled", 5, white, "Exiting in ", 45)
				end		
				
			end	
		System.exit()	
	end
	-- Check controls for restore
	if Controls.check(Controls.read(), SCE_CTRL_CIRCLE) then
		if System.doesFileExist("ux0:/data/iconsbak/iconlayout.ini") then
			--no need to check..icon.ini will be created or overwritten!
			flag = confirm("Your current icon layout will be lost!\nProceed with restoring your saved layout?")
			if flag then 
				copy("ux0:/data/iconsbak/iconlayout.ini", "ux0:/iconlayout.ini")
				copy("ux0:/data/iconsbak/app.db", "ur0:/shell/db/app.db")
				updateDB()
			else
				printText("Operation canceled", 5, white, "Exiting in ", 45)
			end		

		else
			printText("No file to restore!\nUse the backup option of this app to create one.", 5, white, "Exiting in ", 45)
		end	
		System.exit()
	end		
end	--main loop end