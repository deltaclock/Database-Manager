local white = Color.new(255,255,255) -- Create a new color
--add file size check
System.createDirectory("ux0:/data/iconsbak")

function wipeDB()
	System.setMessage("Your database will be wipped!\nYour system will reboot!\nProceed?", false, BUTTON_YES_NO)
				while true do
					Graphics.initBlend()
					Screen.clear()
					 state = System.getMessageState()
						if state == CANCELED then
							Graphics.debugPrint(5, 5, "Wipe canceled", Color.new(255,51,51))
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
				end			
end

function updateDB()
	System.deleteFile("ux0:/id.dat")
	System.setMessage("Do you wanna reboot now?", false, BUTTON_YES_NO)
			while true do
				Graphics.initBlend()
				Screen.clear()
				 state = System.getMessageState()
					if state == CANCELED then
							Graphics.debugPrint(5, 5, "Reboot canceled", Color.new(255,51,51))
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
			end	
end

function copy(file1, file2)
	System.deleteFile(file2)
	System.rename(file1, file2)--moving files
	file = System.openFile(file2, FREAD)
	size = System.sizeFile(file)
	text = System.readFile(file, size)
	newfile = System.openFile(file1, FCREATE)
	System.writeFile(newfile, text, size)
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

					System.setMessage("Your previous backup will be overwritten!!\nDo you wanna continue?", false, BUTTON_YES_NO)

						while true do
							Graphics.initBlend()
							Screen.clear()
							state = System.getMessageState()

								if state == FINISHED then
									copy("ux0:/iconlayout.ini", "ux0:/data/iconsbak/iconlayout.ini")
									Graphics.debugPrint(5, 5, "Backup completed", white)
									Graphics.termBlend()
									Screen.flip()
									break
								elseif state == CANCELED then
									Graphics.debugPrint(5, 5, "Backup canceled", white)
									Graphics.termBlend()
									Screen.flip()
									break
								end	
							Graphics.termBlend()
							Screen.flip()	
						end	
				else		
					copy("ux0:/iconlayout.ini", "ux0:/data/iconsbak/iconlayout.ini")
					Graphics.initBlend()
					Screen.clear()
					Graphics.debugPrint(5, 5, "Backup completed", white)
					Graphics.termBlend()
					Screen.flip()
				end
			else
				System.setMessage("No icons file in your system!\nDo you wanna wipe the database to create the file?", false, BUTTON_YES_NO)
				while true do
					state = System.getMessageState()
						if state == CANCELED then
							Graphics.initBlend()
							Screen.clear()
							Graphics.debugPrint(5, 5, "Operation canceled", Color.new(255,51,51))
							Graphics.termBlend()
							Screen.flip()
							break
						elseif state == FINISHED then
							wipeDB()
						end
				end			
			end	
		Graphics.initBlend()
		Screen.clear()	
		Graphics.debugPrint(5, 45, "Exiting in 5 sec", white)
		Graphics.termBlend()
		Screen.flip()
		System.wait(5000000)
		System.exit()
	end
	-- Check controls for restore
	if Controls.check(Controls.read(), SCE_CTRL_CIRCLE) then

		if System.doesFileExist("ux0:/data/iconsbak/iconlayout.ini") then
			System.setMessage("Your current icon layout will be lost!\nProceed with restoring your saved layout?", false, BUTTON_YES_NO)
				while true do
					Graphics.initBlend()
					Screen.clear()
					state = System.getMessageState()
						if state == CANCELED then
							Graphics.initBlend()
							Screen.clear()
							Graphics.debugPrint(5, 5, "Operation canceled", Color.new(255,51,51))
							Graphics.termBlend()
							Screen.flip()
							break
						elseif state == FINISHED then
							copy("ux0:/data/iconsbak/iconlayout.ini", "ux0:/iconlayout.ini")
							updateDB()
						end
					Graphics.termBlend()
					Screen.flip()	
				end
			Graphics.initBlend()
			Screen.clear()	
			Graphics.debugPrint(5, 45, "Exiting in 5 sec", white)
			Graphics.termBlend()
			Screen.flip()
			System.wait(5000000)
			System.exit()
		else
			Graphics.initBlend()
			Screen.clear()
			Graphics.debugPrint(5, 5, "No file to restore\nUse the backup option of this app to create one", white)
			Graphics.termBlend()
			Screen.flip()
		end	
	end		
end	--main loop end