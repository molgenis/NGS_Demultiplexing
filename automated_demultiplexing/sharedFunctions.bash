#
##
### Generic BASH functions for error handling and logging.
##
#

function log4Bash() {
	#
	# Validate params.
	#
	if [ ! ${#} -eq 5 ]; then
		echo "WARN: should have passed 5 arguments to ${FUNCNAME}: log_level, LINENO, FUNCNAME, (Exit) STATUS and log_message."
	fi
	
	#
	# Determine prio.
	#
	local _log_level="${1}"
	local _log_level_prio="${l4b_log_levels[$_log_level]}"
	local _status="${4:-$?}"
	
	#
	# Log message if prio exceeds threshold.
	#
	if [ ${_log_level_prio} -ge ${l4b_log_level_prio} ]; then
		local _problematic_line="${2:-'?'}"
		local _problematic_function="${3:-'main'}"
		local _log_message="${5:-'No custom message.'}"
		
		#
		# Some signals erroneously report $LINENO = 1,
		# but that line contains the shebang and cannot be the one causing problems.
		#
		if [ "${_problematic_line}" -eq 1 ]; then
			_problematic_line='?'
		fi
		
		#
		# Format message.
		#
		local _log_timestamp=$(date "+%Y-%m-%dT%H:%M:%S") # Creates ISO 8601 compatible timestamp.
		local _log_line_prefix=$(printf "%-s %-s %-5s @ L%-s(%-s)>" "${SCRIPT_NAME}" "${_log_timestamp}" "${_log_level}" "${_problematic_line}" "${_problematic_function}")
		local _log_line="${_log_line_prefix} ${_log_message}"
		if [ ! -z "${mixed_stdouterr:-}" ]; then
			_log_line="${_log_line} STD[OUT+ERR]: ${mixed_stdouterr}"
		fi
		if [ ${_status} -ne 0 ]; then
			_log_line="${_log_line} (Exit status = ${_status})"
		fi
		
		#
		# Log to STDOUT (low prio <= 'WARN') or STDERR (high prio >= 'ERROR').
		#
		if [[ ${_log_level_prio} -ge ${l4b_log_levels['ERROR']} || ${_status} -ne 0 ]]; then
			printf '%s\n' "${_log_line}" 1>&2
		else
			printf '%s\n' "${_log_line}"
		fi
	fi
	
	#
	# Exit if this was a FATAL error.
	#
	if [ ${_log_level_prio} -ge ${l4b_log_levels['FATAL']} ]; then
		#
		# Reset trap and exit.
		#
		trap - EXIT
		if [ ${_status} -ne 0 ]; then
			exit ${_status}
		else
			exit 1
		fi
	fi
}

#
# Initialise Log4Bash logging with defaults.
#
l4b_log_level="${log_level:-INFO}"
declare -A l4b_log_levels=(
	['TRACE']='0'
	['DEBUG']='1'
	['INFO']='2'
	['WARN']='3'
	['ERROR']='4'
	['FATAL']='5'
)
l4b_log_level_prio="${l4b_log_levels[${l4b_log_level}]}"
mixed_stdouterr='' # global variable to capture output from commands for reporting in custom log messages.

