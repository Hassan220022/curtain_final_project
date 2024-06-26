# Makefile to clean up directory and keep only specific files and the .git directory

.PHONY: clean

# List of files to keep
KEEP_FILES = curtain_final_project.pdsprj bor3i.png curtain_final.c curtain_final.hex curtain_final.mcppi Makefile pic.png README.md

clean:
	# Remove all files except the specified ones
	find . -type f ! -name 'curtain_final_project.pdsprj' \
		! -name 'curtain_final.c' \
		! -name 'curtain_final.hex' \
		! -name 'curtain_final.mcppi' \
		! -name 'Makefile' \
		! -name 'bor3i.png' \
		! -name 'pic.png' \
		! -name 'README.md' \
		! -path './.git/*' \
		-delete
	# Remove all directories except the .git directory and directories containing specified files
	find . -type d ! -name '.' ! -name '.git' -exec bash -c 'shopt -s extglob; [[ ! -e "$0"/!(.git|bor3i.png|curtain_final_project.pdsprj|curtain_final.c|curtain_final.hex|curtain_final.mcppi|Makefile|pic.png|README.md) ]] && rm -rf "$0"' {} \;
	rm -rf Project\ Backups/
	clear

git:
	make clean
	git add .
	git commit -m "Update"
	git push
	clear
