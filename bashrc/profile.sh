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


## Default PS1 Prompts For Various Linux Distros

### Manjaro 21
# root user
# \[\033[01;31m\][\h\[\033[01;36m\] \W\[\033[01;31m\]]\$\[\033[00m\]

# standard user
# \[\033[01;32m\][\u@\h\[\033[01;37m\] \W\[\033[01;32m\]]\$\[\033[00m\]

## KDE Neon (plasmashell 5.23.4 - circa 2021)
# standard user
# \[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$

# root user
# \[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\u@\h:\w\$
