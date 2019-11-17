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
#                               MAIN SCRIPT
# -------------------------------------------------------------------------

# Process command-line options:
while getopts ':hV' OPTION; do
  case "$OPTION" in
    h)
      # Print usage information to standard output:
      echo -e "Usage: $NAME [-hV]\n"
      echo '  -h           display this help and exit'
      echo '  -V           display version and exit'

      # Terminate the script:
      exit 0
      ;;
    V)
      # Print version information to standard output:
      echo "$NAME $VERSION"

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
[[ "$#" -eq 0 ]] || exit_with_error 'Invalid number of arguments' 22

# Report success:
echo 'Done.'

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
