local white = Color.new(255,255,255)
local red =  Color.new(255,51,51)-- Create a new color
--[[TODO 
*add file size check
*Themeing options
]]
System.createDirectory("ux0:/data/iconsbak")
System.createDirectory("ux0:/data/iconsbak/vitashell/")

function confirm(msg, scrText)
	System.setMessage(msg, false, BUTTON_YES_NO)
	while true do
		Graphics.initBlend()
		Screen.clear()
		Graphics.debugPrint(10, 10, scrText, white)
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
	local flag = confirm("Your database will be wipped!\nYour system will reboot!\nProceed?", "")
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
	local flag = confirm("Do you wanna reboot now?", "")
	if flag then 
		printText("", 45, white, "Rebooting in ", 5)
		System.reboot()
	else
		printText("Reboot canceled", 5, red, "Exiting in ", 45)
		System.exit()
	end		
end

--[[function copy(file1, file2)--copy file1 to file2
	System.deleteFile(file2)
	file = System.openFile(file1, FREAD)
	size = System.sizeFile(file)
	data = System.readFile(file, size)
	System.closeFile(file)
	newfile = System.openFile(file2, FCREATE)
	System.writeFile(newfile, data, size)
	System.closeFile(newfile)
end]]

max_ram = 4194304--4mb

function copyFile(file1, file2)--copy file1 to file2
	if System.doesFileExist(file2) then
		System.deleteFile(file2)
	end
	oldfile = System.openFile(file1, FREAD)
	newfile = System.openFile(file2, FCREATE)
	size = System.sizeFile(oldfile)
	totalCopiedBytes = 0 
	while (totalCopiedBytes + max_ram/2) < size do
		data = System.readFile(oldfile, max_ram/2)
		System.writeFile(newfile, data, max_ram/2)
		totalCopiedBytes = totalCopiedBytes + max_ram/2
	end	
	if totalCopiedBytes < size then
		data = System.readFile(oldfile, size-totalCopiedBytes)
		System.writeFile(newfile, data, size-totalCopiedBytes)	
	end	
	System.closeFile(oldfile)
	System.closeFile(newfile)
end


function copyDir(dir1, dir2)--recursive for test
	if System.doesDirExist(dir2) then
		System.deleteDirectory(dir2)--del destination
	end
	System.createDirectory(dir2)
	files = System.listDirectory(dir1)
	for i,dirfile in pairs(files) do

		if dirfile.directory then

           	copyDir(dir1..dirfile.name.."/" , dir2..dirfile.name.."/")
		else
			copyFile(dir1..dirfile.name, dir2..dirfile.name)
		end
	end	
end

--[[function copyDir(dir1, dir2)
	System.deleteDirectory(dir2)--del destination
	System.createDirectory(dir2)
	files = System.listDirectory(dir1)
	for i,dirfile in pairs(files) do

		if dirfile.directory then

			local cur_dir = dirfile.name.."/"
			tbl = System.listDirectory(dir1..cur_dir)
			System.createDirectory(dir2..cur_dir)
			for j,fl in pairs(tbl) do
				if dir1..cur_dir..fl.name ~= dir1.."Electron/bg_texteditor.png" then
					--printText(i..j..dir1..cur_dir..fl.name, 20, white, dir2..cur_dir..fl.name, 45)--debug prints
					copy(dir1..cur_dir..fl.name, dir2..cur_dir..fl.name)
				end	
			end
		else
			--printText(i..dir1..dirfile.name, 20, white, dir2..dirfile.name, 45)--debug prints
			copy(dir1..dirfile.name, dir2..dirfile.name)
		end
	end	
end]]

while true do
	-- Draw a string on the screen
	Graphics.initBlend()
	Screen.clear()
	Graphics.debugPrint(10, 5, "Database Manager by Deltaclock", white)
	Graphics.debugPrint(10, 45, "Press X to backup your icon layout.", white)
	Graphics.debugPrint(10, 75, "Press O to restore your icon layout.", white)
	Graphics.debugPrint(10, 105, "Press < to backup VitaShell theme(s).", white)
	Graphics.debugPrint(10, 135, "Press > to restore VitaShell theme(s).", white)
	Graphics.debugPrint(10, 165, "Press L to update your database.", white)
	Graphics.debugPrint(10, 195, "Press R to completely wipe your database.", white)
	Graphics.debugPrint(10, 225, "Press Δ to exit.", white)
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

					flag = confirm("Your previous backup will be overwritten!!\nDo you wanna continue?", "")

						if flag then
							copyFile("ux0:/iconlayout.ini", "ux0:/data/iconsbak/iconlayout.ini")
							copyFile("ur0:/shell/db/app.db", "ux0:/data/iconsbak/app.db")
							printText("Backup completed", 5, white, "Exiting in ", 45)
						else
							printText("Backup canceled", 5, white, "Exiting in ", 45)	
						end	
				else		
					copyFile("ux0:/iconlayout.ini", "ux0:/data/iconsbak/iconlayout.ini")
					copyFile("ur0:/shell/db/app.db", "ux0:/data/iconsbak/app.db")
					printText("Backup completed", 5, white, "Exiting in ", 45)
				end
			else

				flag = confirm("No icons file in your system!\nDo you wanna wipe the database to create the files?", "")
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
		if System.doesFileExist("ux0:/data/iconsbak/iconlayout.ini") and System.doesFileExist("ux0:/data/iconsbak/app.db") then
			--no need to check..icon.ini will be created or overwritten!
			flag = confirm("Your current icon layout will be lost!\nYou will need to reboot to apply changes!\nProceed with restoring your saved layout?", "")
			if flag then 
				copyFile("ux0:/data/iconsbak/iconlayout.ini", "ux0:/iconlayout.ini")
				copyFile("ux0:/data/iconsbak/app.db", "ur0:/shell/db/app.db")
				updateDB()
			else
				printText("Operation canceled", 5, white, "Exiting in ", 45)
			end		

		else
			printText("No files to restore!\nUse the backup option of this app to create them.", 5, white, "Exiting in ", 45)
		end	
		System.exit()
	end	
	--viashell backup
	if Controls.check(Controls.read(), SCE_CTRL_LEFT) then
		if System.doesDirExist("ux0:/app/VITASHELL") then 
			flag = confirm("This might take a while depending on number of themes\nContinue?", "Backing up the files..")
			
			copyDir("ux0:/VitaShell/theme/", "ux0:/data/iconsbak/vitashell/theme/")
			copyFile("ux0:/VitaShell/settings.txt", "ux0:/data/iconsbak/vitashell/settings.txt")
			printText("Backup completed", 5, white, "Exiting in ", 45)
		else
			printText("VitaShell is not installed!", 5, red, "Exiting in ", 45)	
		end
		System.exit()
	end
	--vitashell restore
	if Controls.check(Controls.read(), SCE_CTRL_RIGHT) then
		if System.doesDirExist("ux0:/VitaShell") then
			if System.doesDirExist("ux0:/data/iconsbak/vitashell") then
				copyDir("ux0:/data/iconsbak/vitashell/theme/", "ux0:/VitaShell/theme/")
				copyFile("ux0:/data/iconsbak/vitashell/settings.txt", "ux0:/VitaShell/settings.txt")
				printText("Restore completed", 5, white, "Exiting in ", 45)
			else
				printText("No files to restore!\nUse the backup option of this app to create them.", 5, white, "Exiting in ", 45)
			end

		else
			printText("Unable to locate VitaShell files!", 5, red, "Exiting in ", 45)	
		end
		System.exit()
	end	

end	--main loop end