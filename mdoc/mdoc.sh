#!/bin/bash

# mdoc.sh - display important information about modular documentation files
# Copyright (C) 2019 Jaromir Hradilek <jhradilek@gmail.com>

# This program is  free software:  you can redistribute it and/or modify it
# under  the terms  of the  GNU General Public License  as published by the
# Free Software Foundation, version 3 of the License.
#
# This program  is  distributed  in the hope  that it will  be useful,  but
# WITHOUT  ANY WARRANTY;  without  even the implied  warranty of MERCHANTA-
# BILITY  or  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public
# License for more details.
#
# You should have received a copy of the  GNU General Public License  along
# with this program. If not, see <http://www.gnu.org/licenses/>.

# -------------------------------------------------------------------------
#                            GLOBAL VARIABLES
# -------------------------------------------------------------------------

# General information about the script:
declare -r NAME=${0##*/}
declare -r VERSION='0.0.1'


# -------------------------------------------------------------------------
#                            GENERIC FUNCTIONS
# -------------------------------------------------------------------------


# Prints usage information to standard output:
#
# Usage: print_usage
function print_usage {
  # Print usage:
  echo "Usage: $NAME [-hV]"
  echo "       $NAME children FILE"
  echo "       $NAME parents FILE"
  echo -e "       $NAME orphans\n"
  echo '  -h           display this help and exit'
  echo '  -V           display version and exit'
}

# Print version information to standard output:
#
# Usage: print_version
function print_version {
  # Print version:
  echo "$NAME $VERSION"
}

# Prints an error message to standard error output and terminates the
# script with a selected exit status.
#
# Usage: exit_with_error ERROR_MESSAGE [EXIT_STATUS]
function exit_with_error {
  local -r error_message=${1:-'An unexpected error has occurred.'}
  local -r exit_status=${2:-1}

  # Print the supplied message to standard error output:
  echo -e "$NAME: $error_message" >&2

  # Terminate the script with the selected exit status:
  exit $exit_status
}

# Prints a warning message to standard error output.
#
# Usage: warn WARNING_MESSAGE
function warn {
  local -r warning_message="$1"

  # Print the supplied message to standard error output:
  echo -e "$NAME: $warning_message" >&2
}


# -------------------------------------------------------------------------
#                            SCRIPT FUNCTIONS
# -------------------------------------------------------------------------

# Determines whether the supplied path is located in a Git repository and
# prints the absolute path to the top-level directory of that repository.
# If the path is not part of a Git repository, the function does not print
# anything.
#
# Usage: print_git_root PATH
function print_git_root {
  local -r path="$1"

  # Determine the full path:
  local -r fullpath=$(realpath "$path")

  # Determine the directory the supplied file is in:
  local dirname
  if [[ -d "$fullpath" ]]; then
    dirname="$fullpath"
  else
    dirname=$(dirname "$fullpath")
  fi

  # Print the absolute path to the top-level directory of the Git
  # repository if there is any:
  bash -c "cd '$dirname' && git rev-parse --show-toplevel" 2>/dev/null
}

# FIXME
#
# Usage: print_results LIST HEADER FOOTER
function print_results {
  local -r path="$1"
  local -r results="$2"
  local -r header="${3:-Displaying results for: $1}"

  # Count the number of processed lines:
  local count=$(echo "$results" | wc -l)

  # Print header:
  echo -e "$header\n"

  # Get the absolute path to the top-level directory of the Git repository:
  local -r toplevel=$(print_git_root "$path")

  if [[ -z "$results" ]]; then
    echo "  No results found."
    count=0
  else
    echo "$results" | while read file; do
      [[ ! -z "$toplevel" ]] \
        && echo "  ${file#$toplevel/}" \
        || echo "  ${file#$PWD/}"
    done
  fi

  # Print footer:
  echo -e "\nFound $count results."
}

# Reads an AsciiDoc file and prints a list of all included files to
# standard output.
#
# Usage: print_includes FILE
function print_includes {
  local -r filename="$1"

  # Parse the AsciiDoc file, get a complete list of included files, and
  # print their full paths to standard output:
  ruby <<-EOF 2>/dev/null
#!/usr/bin/env ruby

require 'asciidoctor'

document = Asciidoctor.load_file("$filename", doctype: :book, safe: :safe)
document.reader.includes.each { |filename|
  dirname  = File.dirname("$filename")
  fullpath = File.join(dirname, "#{filename}.adoc")
  puts File.realpath(fullpath)
}
EOF
}

# FIXME
#
# Usage: list_children FILE
function list_children {
  local -r filename="$1"

  # Verify that the supplied file exists and is readable:
  [[ -e "$filename" ]] || exit_with_error "$filename: No such file or directory" 2
  [[ -r "$filename" ]] || exit_with_error "$filename: Permission denied" 13
  [[ -f "$filename" ]] || exit_with_error "$filename: Not a file" 21

  local -r children=$(print_includes "$filename")

  print_results "$filename" "$children"
}

# FIXME
#
# Usage: list_parents FILE
function list_parents {
  local -r filename="$1"

  # Verify that the supplied file exists and is readable:
  [[ -e "$filename" ]] || exit_with_error "$filename: No such file or directory" 2
  [[ -r "$filename" ]] || exit_with_error "$filename: Permission denied" 13
  [[ -f "$filename" ]] || exit_with_error "$filename: Not a file" 21

  local -r toplevel=$(print_git_root "$filename")

  [[ -z "$toplevel" ]] && exit_with_error "$filename: Not in a Git repository" 1

  local -r titles=$(find -P "$toplevel" -type f -name 'master.adoc')
  local -r assemblies=$(find -P "$toplevel" -type f -name 'assembly_*.adoc')

  export -f print_includes
  export NAME
  local -r parents=$(echo -e "$titles\n$assemblies" | xargs -n 1 -P 0 -I % bash -c 'print_includes "%" | grep -q '"$filename"' && echo "%"' --)

  print_results "$filename" "$parents"
}

# FIXME
#
# Usage: list_orphans
function list_orphans {
  local toplevel=$(print_git_root "$PWD")

  if [[ -z "$toplevel" ]]; then
    warn "Not in a Git repository, searching in PWD instead"
    toplevel="$PWD"
  fi

  local -r parents=$(find -P "$toplevel" -type f -regextype sed -regex '.*/\(master\|assembly_[^/]\+\)\.adoc')

  export -f print_includes
  export NAME
  local -r children=$(echo -e "$parents" | xargs -n 1 -P 0 -I % bash -c 'print_includes "%"' | sort -u)

  local -r files=$(find -P "$toplevel" -type f -name '*.adoc' -exec realpath {} \; | grep -v 'master.adoc' | sort -u)

  local -r orphans=$(comm -13 <(echo "$children") <(echo "$files"))

  print_results "$toplevel" "$orphans"
}


# -------------------------------------------------------------------------
#                               MAIN SCRIPT
# -------------------------------------------------------------------------

# Process command-line options:
while getopts ':hV' OPTION; do
  case "$OPTION" in
    h)
      # Print usage information to standard output:
      print_usage

      # Terminate the script:
      exit 0
      ;;
    V)
      # Print version information to standard output:
      print_version

      # Terminate the script:
      exit 0
      ;;
    *)
      # Report an invalid option and terminate the script:
      exit_with_error "Invalid option -- '$OPTARG'" 22
      ;;
  esac
done

# Shift positional parameters:
shift $(($OPTIND - 1))

# Verify the number of command-line arguments:
[[ "$#" -gt 0 ]] || exit_with_error 'Invalid number of arguments' 22

# Verify that all required utilities are present in the system:
for dependency in asciidoctor git ruby; do
  if ! type "$dependency" &>/dev/null; then
    exit_with_error "Missing dependency -- '$dependency'" 1
  fi
done


# Process the commands:
case "$1" in
  children)
    # Verify the number of command-line arguments:
    [[ "$#" -eq 2 ]] || exit_with_error 'Invalid number of arguments' 22

    # List all files included in the AsciiDoc file:
    list_children "$2"
    ;;
  parents)
    # Verify the number of command-line arguments:
    [[ "$#" -eq 2 ]] || exit_with_error 'Invalid number of arguments' 22

    # List all files included in the AsciiDoc file:
    list_parents "$2"
    ;;
  orphans)
    # Verify the number of command-line arguments:
    [[ "$#" -eq 1 ]] || exit_with_error 'Invalid number of arguments' 22

    list_orphans
    ;;
  debug)
    [[ "$#" -eq 2 ]] || exit_with_error 'Invalid number of arguments' 22

    print_git_root "$2"
    ;;
  help)
    # Print usage information to standard output:
    print_usage
    ;;
  version)
    # Print version information to standard output:
    print_version
    ;;
  *)
    # Report an invalid command and terminate the script:
    exit_with_error "Invalid command -- '$1'" 22
    ;;
esac

# Terminate the script:
exit 0


# -------------------------------------------------------------------------
#                              DOCUMENTATION
# -------------------------------------------------------------------------

:<<-=cut

=head1 NAME

mdoc - display important information about modular documentation files

=head1 SYNOPSIS

B<mdoc> [B<-hV>]

B<mdoc> B<children> I<file>

B<mdoc> B<parents> I<file>

B<mdoc> B<orphans> I<file>

=head1 DESCRIPTION

FIXME

=head1 OPTIONS

=over

=item B<-h>

Displays usage information and terminates the script.

=item B<-V>

Displays the script version and terminates the script.

=back

=head1 SEE ALSO

B<asciidoctor>(1), B<git>(1)

=head1 COPYRIGHT

Copyright (C) 2019 Jaromir Hradilek E<lt>jhradilek@gmail.comE<gt>

This program is free software; see the source for copying conditions. It is
distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.

=cut
