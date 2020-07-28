function test_command () {
	if [ -z "$1" ]; then
		printf "No command name supplied\n"
		printf "Usage: '${FUNCNAME[0]} command_to_test'"
		return 1
	else
		CMD_NAME="$1"
		CMD_PATH=$(command -v "${CMD_NAME}")
		#if [ ! $(command -v "$CMD_NAME") ];then
		if [ "${CMD_PATH}" == "" ];then
			printf "[${FUNCNAME[0]}] Command '$CMD_NAME' not resolved\n"
			return 1
		else
			printf "[${FUNCNAME[0]}] Command '${CMD_NAME}' resolved to path: '${CMD_PATH}'\n"
			return 1
		fi
	fi
}
