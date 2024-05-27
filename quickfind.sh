fs() {

	help_msg="
        Usage: fs [FILE_TYPE] [PATTERN]

        FILE_TYPE - Specify file type to filter by (e.g., py for Python files).
        PATTERN   - The pattern to search for within files.

        Examples:
        fs           - Search all files in the current directory.
        fs py        - Search Python files in the current directory.
        Use 'fs -h' to display this help message.
        "
	if [[ "$1" == "-h" ]]; then
		echo "$help_msg"
		return 0
	fi

	echo $1
	if [ $# -eq 0 ]; then
		rg --color=always --line-number --no-heading --smart-case "${*:-}" --follow |
			fzf --ansi \
				--color "hl:-1:underline,hl+:-1:underline:reverse" \
				--delimiter : \
				--preview-window 'right:50%:wrap' \
				--bind 'change:reload:rg --color=always --line-number --no-heading --smart-case {q} --follow'

	fi

	file_type="$1"
	pattern="$2"
	fd -t f -e "$file_type" '' | xargs rg --type-add "$file_type":".$file_type" --type "$file_type" --color=always --line-number --no-heading --smart-case "${*:-}" |
		fzf --ansi \
			--header 'Searching' \
			--color "hl:-1:underline,hl+:-1:underline:reverse" \
			--delimiter : \
			--preview 'bat --color=always {1} --highlight-line {2}' \
			--preview-window 'right,50%,border-bottom,+{2}+3/3,~3' \
			--bind "change:reload:rg --type-add \"$file_type\":\".$file_type\" --type \"$file_type\" --color=always --line-number --no-heading --smart-case {q} --"

}

ff() {
	echo "EXCUTING"
	# Use FF_BASE_PATH if set, otherwise default to $HOME/Documents
	local FF_BASE_PATH=
	local base_path="${FF_BASE_PATH:-$HOME/Documents}"

	# Declare associative arrays for language patterns
	typeset -A patterns
	patterns=(
		go "*.go"
		python "*.py"
		js "*.js"
		html "*.html"
		css "*.css"
		java "*.java"
		cpp "*.cpp"
		c "*.c"
		sh "*.sh"
	)

	# Usage message
	local help_msg="
    Usage: ff [c] [language] [depth]
    c        - Search within 'Documents/Code'.
    language - Specify programming language to filter by (e.g., python, js).
    depth    - Specify the number of directory levels to display in results.

    Examples:
    ff         - Search all files under 'Documents'.
    ff c       - Search coding files under 'Documents/Code'.
    ff c js 1  - Search JavaScript files in 'Documents/Code' showing filename and one parent directory.

    Use 'ff -h' to display this help message.
    Use 'ff -l' to list all language patterns.
    "

	# Display help or patterns
	if [[ "$1" == "-h" ]]; then
		echo "$help_msg"
		return 0
	elif [[ "$1" == "-l" ]]; then
		echo "Supported Languages and File Patterns:"
		for lang in "${!patterns[@]}"; do
			echo "$lang - ${patterns[$lang]}"
		done
		return 0
	fi

	local dir="$base_path"
	local pattern="*"
	local depth=1 # Default to just the filename

	# Adjust directory and pattern based on arguments
	if [[ "$1" == "c" ]]; then
		dir="$base_path/Code"
		if [[ -n "${patterns[$2]}" ]]; then
			pattern="${patterns[$2]}"
			depth="${3:-0}"
		elif [[ -n "$2" ]]; then
			# Assume $2 is the depth if it's not a recognized language
			depth="$2"
		fi
	elif [[ "$1" == "ic" ]]; then
		dir=~/Library/Mobile\ Documents/com~apple~CloudDocs
		if [[ -n "${patterns[$2]}" ]]; then
			pattern="${patterns[$2]}"
			depth="${3:-0}"
		elif [[ -n "$2" ]]; then
			# Assume $2 is the depth if it's not a recognized language
			depth="$2"
		fi
	elif [[ -n "$1" ]]; then
		dir=$(pwd)
		depth="$1"
		pattern="*"
	fi

	# Ensure the directory exists
	if [[ ! -d "$dir" ]]; then
		echo "Directory does not exist: $dir"
		return 1
	fi

	# Run ripgrep to list files, filtered by the optional pattern
	file_list=$(rg --files "$dir" -g "$pattern" | awk -v depth="$depth" -F'/' '{
    path="";
    for (i=NF-depth; i<=NF; i++) path=(path (i==NF-depth?"":"/") $i);
    print path "\t" $0
    }')
	local selected=$(rg --files -g "$pattern" | fzf --layout=reverse \
		--header 'CTRL-T: Switch between Files/Directories' \
		--bind 'ctrl-t:transform:[[ ! $FZF_PROMPT =~ Files ]] && 
              echo "change-prompt(Files> )+reload(rg --files -g \""$pattern"\")" ||
              echo "change-prompt(Directories> )+reload(fd --type directory)"' \
		--preview '[[ $FZF_PROMPT =~ Files ]] && bat --color=always {} || tree -C {}' \
		--prompt "Search Files> " \
		--preview-window right:50%:wrap \
		--with-nth 1 \
		--delimiter '\t')

	# Extract the directory part of the selected file path
	local directory=$(dirname "$(echo "$selected" | cut -d$'\t' -f2)")

	# Change to the directory containing the selected file
	cd "$directory"
}