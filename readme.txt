plugwise-collector.pl script currently only do two things : it can reset the database ; and it can collect all the data from all recorded circles.

Reset function work properly.

Circles have to be added manualy in the database. all circles in the database are checked, and all the data history is retrieved for each circle. When retrieving data, the program store in the database the index of the last data retrieved so it can start after it next time. So data are only retrieved once.

## plugwise-collector.pl architecture :
The program is a simple perl script. Only the plugwise plugin uses objects.

All part of the program are in the same file except for the plugwise plugin. Program was initialy meant to have separated files, but ultimately all was put in the same file for simplicity.

First part is header and global variables. Global variables define the timeout for plugwise stick interrogation, and all variables related to database access.

Second part is all functions related to database interactions.

Third part is toolbox for the program.

Fourth part is program functions (only one currently).

Fifth part is command line interpreter (big if else ... calling functions of the fourth part, or so it was intended, because the the reset function is in the second part as it is a db function).


## tests :
One use cases have been tested : retrieving data from one circle through a circle+ (long addresses).

In this case, error messages appear from the plugwise plugin when initializing the perl object but don't prevent the program to run ; I think the messages come from the circle associated to the circle+.


## todo
Collect function need to be refined. There probably still hava bugs.

Program miss :
- logs ;
- all database reading functions ;
- all database manipulation functions for circle management etc.

## files and folders
- brouillons : first scripts I made to test an understand plugwise plugin
- device-plugwise-perl : patched plugwise plugin
- dbutils.pl : file initialy intended to hold database
- plugwise.txt : list of addresses used for tests
- plugwise-collector.pl : main script
- readme.txt : this file

