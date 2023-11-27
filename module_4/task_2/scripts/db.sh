#! /bin/bash

db_name="users.db"
db_path="../data/$db_name"

function validate_input() {
	local input="$1"
	
	while : ; do
		if [[ ! $1 =~ ^[a-zA-Z]+$ ]]; then
			read -p "Invalid input: only Latin letters should be used." input
		else
			break
		fi
	done

	echo "${input}"
}

function add() {
	read -p $"Enter username for the new entity: " new_username
	new_username=$(validate_input "$new_username")
	
	read -p $"Enter the role for '${new_username}': " new_role
	new_role=$(validate_input "$new_role")
	
	echo "$new_username, $new_role" >> "$db_path"
	echo "Entity added to $db_name: $new_username, $new_role"
}

function help() {
	echo "This is a shell script for users database management."
	echo
	echo "You can use the following commands:"
	echo
	echo " add			Adds new user to the database.
				This command prompts to enter username and role."
	echo
	echo " find			Finds user in database by their username.
				This command prompts to enter username."
	echo
	echo " list [--inverse]	Displays list of all users in database, including their username and role.
				Users are dislayed in the order they were added.
				Use --inverse to display the list of users in reversed order."
	echo
	echo " backup			Creates the database backup, including full date of backup creation in its name."
	echo
	echo " restore		Restores database from the latest backup file."
	echo " help			Displays information about available functions."
}

function backup() {
	backup_file=$(date +'%Y-%m-%d-%H-%M-%S')-${db_name}.backup

	cp "${db_path}" "../data/${backup_file}"

	echo "Backup created: ${backup_file}"
}

function restore() {
	latest_backup=$(find "../data" -type f -name "*-${db_name}.backup" | sort | tail -n 1)

	if [ -n "$latest_backup" ]; then
		cat "${latest_backup}" > "${db_path}"
		echo "${db_name} was restored from the latest backup: $latest_backup"
	else
		echo "No backup file found."
	fi
}

function _find() {
	read -p $"Enter username: " query
	query=$(validate_input "${query}")

	local count=0
	local width=10
	while IFS="," read -re username role || [[ -n "${username}" ]]; do

	if [[ "${username}" == "${query}" ]]; then
		if [[ $count -eq 0 ]]; then
			echo -e "\nRecords found:"
			printf "%-${width}s\n" "$(printf '%0.s=' {1..23})"
			printf "%-${width}.${width}s | %s\n" "USERNAME" "ROLE"
			printf "%-${width}.${width}s | %s\n" "$(printf '%0.s=' {1..10})" "$(printf '%0.s=' {1..10})"
		fi

		printf "%-${width}.${width}s |%s\n" "${username}" "${role}"
		count=$((count+1))
	fi

	done < $db_path

	if [[ $count -eq 0 ]]; then
		echo -e "\nNo records found."
	else
		printf "%-${width}s\n\n" "$(printf '%0.s=' {1..23})"
		echo "Total records found: ${count}"
	fi
}

inverse=$2
function list() {
	if [[ "${inverse}" == "--inverse" ]]; then
		tail -r "${db_path}" | nl
	else
		cat "${db_path}" | nl
	fi
}

if [[ "$1" != "" && "$1" != "help" && ! -f "${db_path}" ]]; then
	read -p "${db_name} file not found. Create it? (y/n): " create_file

	if [[ "${create_file}" == "y" ]]; then
		touch "${db_path}"
		echo "File ${db_name} was created."
	else
		exit 1
	fi
fi

case $1 in
add)		add;;
help)		help;;
backup)		backup;;
restore) 	restore;;
find) 		_find;;
list) 		list;;
esac


