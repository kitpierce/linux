function prompt_relpath {
	if [ $UID == 0 ];then
		## Short Path - Cyan User
		MYPRO="\[\e[31m\]\u\[\e[m\]@\[\e[32m\]\h\[\e[m\] \[\e[33m\][\W]\[\e[m\] \\$ "
	else
		## Short Path - Red User
		MYPRO="\[\e[36m\]\u\[\e[m\]@\[\e[32m\]\h\[\e[m\] \[\e[33m\][\W]\[\e[m\] \\$ "
	fi
}

function prompt_fullpath {
    if [ $UID == 0 ];then
        ## Full Path - Cyan User
        MYPRO="\[\e[31m\]\u\[\e[m\]@\[\e[32m\]\h\[\e[m\] \[\e[33m\][\w]\[\e[m\] \\$ "
    else
        ## Full Path - Red User
        MYPRO="\[\e[36m\]\u\[\e[m\]@\[\e[32m\]\h\[\e[m\] \[\e[33m\][\w]\[\e[m\] \\$ "
    fi
}

function prompt_time {
	case "$1" in
	"--12hour"|"--short"|"-s")
		# 12 Hour Time
		PT='\@ '
		;;
	"--24hour"|"--long"|"-l")
		# 24 Hour Time
		PT='\A '
		;;
	"--none"|"-n")
		PT=''
		;;
	"--help"|"-h"|"-?")
		printf "Sets terminal prompt time format.  Valid options:"
		printf "\n\t'--12hour' - Time in AM/PM format"
		printf "\n\t'--24hour' - Time in 24 hour format"
		printf "\n\t'--none'   - No time in terminal\n"
		;;
	*)
		;;
	esac
}

# Set initial timestamp to 'none' for prompt
prompt_time -none
# Set initial path to 'relative' for prompt
prompt_relpath

# Set format for PROMPT_COMMAND which will refresh PS1 after every command/return
PROMPT_COMMAND='PS1="$PT$MYPRO"'

# Source various config files
for file in ~/.bashrc ~/.bash_profile ~/.bash_aliases;
do
	if [ -f $(echo $file) ];then
		printf "Sourcing file: '$file'\n"
		source $file
	fi
done

