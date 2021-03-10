#!/bin/bash
# parameters: "message" "command" "path to log directory"
# like: run_questa.sh "Compiling" "vlog /dir/mymodule.sv" "${BLOG_DIR}/log.log"
msg=${1}
cmd=${2}
logfile=${3}

truecmd=$(cat <<EOF
       if GREP_COLOR="0;40;1;33" grep -P --color \
             "(Warning[ :]|^\*\* (?!Note: \(vlog-2286\)))" ${logfile}; then
           echo -e "$O No errors but please check warnings in ${logfile} $C"
           echo
       else
           true
       fi
EOF
)
falsecmd=$(cat <<EOF
       grep -E --color \
           "(^\*\* Fatal[ :]|^\*\* Error[ :]|^\*\* [^W]|UVM_FATAL[ :]@)" \
           ${logfile};
       GREP_COLOR="0;40;1;33" grep -E --color "(^\*\* Warning[ :]|^\*\* [^E])" \
           ${logfile}
EOF
)

echo -n "$0 " > ${logfile}.cmds
printf "'%s' " "$@" >> ${logfile}.cmds
echo -e "\n" >> ${logfile}.cmds


# To preserve escaped quotation marks
esc_truecmd=$(printf "%q" "$truecmd")
esc_falsecmd=$(printf "%q" "$falsecmd")

SCRIPT_PATH=$(dirname "$(readlink -f "$0")")
${SCRIPT_PATH}/../build/pretty_run.sh "${msg}" "${cmd}" "${logfile}" "${truecmd}" "${falsecmd}"
