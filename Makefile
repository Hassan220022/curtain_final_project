# Makefile to clean up directory and keep only specific files and .git directory

.PHONY: clean

# List of files to keep
KEEP_FILES = curtain_final_project.pdsprj curtain_final.c curtain_final.hex curtain_final.mcppi Makefile pic.png README.md

git:
	git add .
	git commit -m "Update"
	git push
	clear

clean:
	# Remove all files except the specified ones and the .git directory
	find . -type f ! -name 'curtain_final_project.pdsprj' \
		! -name 'curtain_final.c' \
		! -name 'curtain_final.hex' \
		! -name 'curtain_final.mcppi' \
		! -name 'Makefile' \
		! -name 'pic.png' \
		! -name 'README.md' \
		! -path './.git/*' \
		-delete
	# Remove all directories except the .git directory
	find . -type d ! -name '.' ! -name '.git' -exec rm -rf {} +
