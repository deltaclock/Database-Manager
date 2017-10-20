local white = Color.new(255,255,255)
local red =  Color.new(255,51,51)-- Create a new color
--[[TODO 
*add file size check
*add timer
]]
System.createDirectory("ux0:/data/iconsbak")

function confirm(text)
	System.setMessage(text, false, BUTTON_YES_NO)
	while true do
		Graphics.initBlend()
		Screen.clear()
		Graphics.termBlend()
		Screen.flip()
		state = System.getMessageState()
		if state == FINISHED then
			return true
		elseif state == CANCELED then
			return false
		end
	end
end

function printText(text1, color, text2)--at position 5,5
	Graphics.initBlend()
	Screen.clear()
	Graphics.debugPrint(5, 5, text1, color)
	Graphics.debugPrint(5, 45, text2, white)
	Graphics.termBlend()
	Screen.flip()
end

function wipeDB()
	flag = confirm("Your database will be wipped!\nYour system will reboot!\nProceed?")
	if flag then 
		System.deleteFile("ur0:shell/db/app.db")
		printText("Rebooting in 5 sec", white, "")
		System.wait(5000000)
		System.reboot()
	else
		printText("Wipe canceled", red, "Exiting in 5 sec")
		System.wait(5000000)
		System.exit()
	end		
	--[[System.setMessage("Your database will be wipped!\nYour system will reboot!\nProceed?", false, BUTTON_YES_NO)
				while true do
					Graphics.initBlend()
					Screen.clear()
					 state = System.getMessageState()
						if state == CANCELED then
							Graphics.debugPrint(5, 5, "Wipe canceled", red)
							Graphics.debugPrint(5, 45, "Exiting in 5 sec", white)
							Graphics.termBlend()
							Screen.flip()
							System.wait(5000000)
							System.exit()
						elseif state == FINISHED then
							System.deleteFile("ur0:shell/db/app.db")
							Graphics.debugPrint(5, 5, "Rebooting in 5 sec", white)
							Graphics.termBlend()
							Screen.flip()
							System.wait(5000000)
							System.reboot()
						end
					Graphics.termBlend()
					Screen.flip()	
				end	]]		
end

function updateDB()
	System.deleteFile("ux0:/id.dat")
	flag = confirm("Do you wanna reboot now?")
	if flag then 
		printText("Rebooting in 5 sec", white, "")
		System.wait(5000000)
		System.reboot()
	else
		printText("Reboot canceled", red, "Exiting in 5 sec")
		System.wait(5000000)
		System.exit()
	end		
	--[[System.setMessage("Do you wanna reboot now?", false, BUTTON_YES_NO)
			while true do
				Graphics.initBlend()
				Screen.clear()
				 state = System.getMessageState()
					if state == CANCELED then
							Graphics.debugPrint(5, 5, "Reboot canceled", red)
							Graphics.debugPrint(5, 45, "Exiting in 5 sec", white)
							Graphics.termBlend()
							Screen.flip()
							System.wait(5000000)
							System.exit()
					elseif state == FINISHED then
							Graphics.debugPrint(5, 5, "Rebooting in 5 sec", white)
							Graphics.termBlend()
							Screen.flip()
							System.wait(5000000)
							System.reboot()
					end	
				Graphics.termBlend()
				Screen.flip()
			end]]	
end

function copy(file1, file2)
	System.deleteFile(file2)
	System.rename(file1, file2)--moving files
	file = System.openFile(file2, FREAD)
	size = System.sizeFile(file)
	data = System.readFile(file, size)
	newfile = System.openFile(file1, FCREATE)
	System.writeFile(newfile, data, size)
end

while true do
	-- Draw a string on the screen
	Graphics.initBlend()
	Screen.clear()
	Graphics.debugPrint(5, 5, "Database Manager by deltaclock", white)
	Graphics.debugPrint(5, 45, "Press X to backup your icon layout.", white)
	Graphics.debugPrint(5, 65, "Press O to restore your icon layout.", white)
	Graphics.debugPrint(5, 85, "Press L to update your database.", white)
	Graphics.debugPrint(5, 105, "Press R to completely wipe your database.", white)
	Graphics.debugPrint(5, 125, "Press Δ to exit.", white)
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
			if System.doesFileExist("ux0:/iconlayout.ini") then

				if System.doesFileExist("ux0:/data/iconsbak/iconlayout.ini") then

					flag = confirm("Your previous backup will be overwritten!!\nDo you wanna continue?")

						if flag then
							copy("ux0:/iconlayout.ini", "ux0:/data/iconsbak/iconlayout.ini")
							printText("Backup completed", white, "Exiting in 5 sec")
						else
							printText("Backup canceled", white, "Exiting in 5 sec")	
						end	
				else		
					copy("ux0:/iconlayout.ini", "ux0:/data/iconsbak/iconlayout.ini")
					printText("Backup completed", white, "Exiting in 5 sec")
				end
			else

				flag = confirm("No icons file in your system!\nDo you wanna wipe the database to create the file?")
				if flag then
					wipeDB()
				else
					printText("Operation canceled", red, "Exiting in 5 sec")
				end		
				
			end	
		System.wait(5000000)
		System.exit()
	end
	-- Check controls for restore
	if Controls.check(Controls.read(), SCE_CTRL_CIRCLE) then
		if System.doesFileExist("ux0:/data/iconsbak/iconlayout.ini") then
			--no need to check..icon.ini will be created or overwritten!
			flag = confirm("Your current icon layout will be lost!\nProceed with restoring your saved layout?")
			if flag then 
				copy("ux0:/data/iconsbak/iconlayout.ini", "ux0:/iconlayout.ini")
				updateDB()
			else
				printText("Operation canceled", red, "Exiting in 5 sec")
			end		

		else
			printText("No file to restore!\nUse the backup option of this app to create one.", white, "Exiting in 5 sec")
		end	
		System.wait(5000000)
		System.exit()
	end		
end	--main loop end