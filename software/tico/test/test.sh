#! /bin/sh

NB_SUCCESS=0
NB_ERROR=0

GREEN="\\033[1;32m"
NORMAL="\\033[0;39m"
RED="\\033[1;31m"
PINK="\\033[1;35m"
BLUE="\\033[1;34m"
WHITE="\\033[0;02m"
YELLOW="\\033[1;33m"
CYAN="\\033[1;36m"

test_parser () {

    fileName=$(basename $1)
    dirName=$(dirname $1)
    resultFile=$dirName"/"${fileName%.*}".exp"

    echo -e "$BLUE Test: $fileName"

    ./test-parser "$1" > $dirName"/"${fileName%.*}".result"

    diff -q $dirName"/"${fileName%.*}".result" "$resultFile" 1>/dev/null 2>&1; resultat=$?

    if [ $resultat -eq 0 ]
    then
        echo -e "$GREEN OK: result is as expected."
        NB_SUCCESS=$((NB_SUCCESS+1))
    elif [ $resultat -eq 1 ]
    then echo -e "$RED Problem: result is NOT as expected."
        NB_ERROR=$((NB_ERROR+1))
    else
        echo -e "$RED Could not access file ou expected result file."
        NB_ERROR=$((NB_ERROR+1))
    fi

}

test_comparison () {

    fileName=$(basename $1)
    dirName=$(dirname $1)
    resultFile=$dirName"/"${fileName%.*}".exp"

    echo -e "$BLUE Test: $fileName"

    ./test-comparison "$1" > $dirName"/"${fileName%.*}".result"

    diff -q $dirName"/"${fileName%.*}".result" "$resultFile" 1>/dev/null 2>&1; resultat=$?

    if [ $resultat -eq 0 ]
    then
        echo -e "$GREEN OK: result is as expected."
        NB_SUCCESS=$((NB_SUCCESS+1))
    elif [ $resultat -eq 1 ]
    then echo -e "$RED Problem: result is NOT as expected."
        NB_ERROR=$((NB_ERROR+1))
    else
        echo -e "$RED Could not access file ou expected result file."
        NB_ERROR=$((NB_ERROR+1))
    fi

}

echo -e "$CYAN Tests - Digital tester"

for file in inputs-parser/*.json
do
    test_parser $file
done

for file in inputs-comparison/*.json
do
    test_comparison $file
done

rm -f inputs-comparison/*.result
rm -f inputs-parser/*.result

echo -e "$CYAN ---End of tests---"
echo -e "$GREEN Success : $NB_SUCCESS"
echo -e "$RED Error : $NB_ERROR $NORMAL"
