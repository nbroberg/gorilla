# Gorilla

Simple tool for comparing and updating security groups via RightScale

## Installation

Clone from git repository:

    $ git clone git@github.com:rightscale/gorilla

And then execute:

    $ cd gorilla
    $ rake install

## Usage

Store 'example_security_group' in file 'example_file':

    gorilla --sg-digest-file=example_file digest example_security_group

Compare 'example_security_group_1' to 'example_security_group_2':

    gorilla diff example_security_group_1 example_security_group_2

Make a copy of 'example_security_group_1' and create it as 'example_security_group_2':

    gorilla copy example_security_group_1 example_security_group_2

Update 'example_security_group' using group stored in 'example_file':

    gorilla --sg-digest-file=example_file update example_security_group

Delete 'example_security_group':

    gorilla delete example_security_group
