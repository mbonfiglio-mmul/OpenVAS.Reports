#!/bin/bash

# This is only an helper script
# Launch openvasreporting to create a single report of each format from all the file # found in XML directory.

# Register local path, to make XML and REPORTS relative to this
current_dir="$( readlink -e "$( dirname "${0}" )" )"
xml_dir="${current_dir}/input_xml"
reports_dir="${current_dir}/output_reports"
openvasreporting_dir="${current_dir}/openvasreporting"
virtualenv_dir="${current_dir}/virtualenv"

# First: if not in virtualenv, but aviable, activate it
if ! env | grep -q VIRTUAL_ENV && [[ -f "${virtualenv_dir}/bin/activate" ]]
then
# shellcheck source=virtualenv/bin/activate
	source "${virtualenv_dir}/bin/activate"
fi
# Enter the directory for openvasreporting
cd "${openvasreporting_dir}" || exit 1
# launch
python -m openvasreporting -i "${xml_dir}"/*.xml -o "${reports_dir}/report" -f 'csv'  "$@"
python -m openvasreporting -i "${xml_dir}"/*.xml -o "${reports_dir}/report" -f 'xlsx' "$@"
python -m openvasreporting -i "${xml_dir}"/*.xml -o "${reports_dir}/report" -f 'docx' "$@"
