# Makefile to clean up directory and keep only specific files and remove the Project backups folder

.PHONY: clean

# List of files to keep
KEEP_FILES = curtain_final.mcpi curtain_final.mcppi pic.png readme.md *.c *.pdsprj

git:
	git add .
	git commit -m "Update"
	git push
	clear

clean:
	# Remove all files except the specified ones
	find . -type f ! -name 'curtain_final.mcpi' \
		! -name 'curtain_final.mcppi' \
		! -name 'pic.png' \
		! -name 'readme.md' \
		! -name '*.c' \
		! -name '*.pdsprj' \
		-delete
	# Remove the "Project backups" folder
	rm -rf "Project backups"
