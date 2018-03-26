#!/bin/bash

print_manual(){
    echo "First argument needs to be a path to your R5RS file with an implementation of homework."
    echo "Second argument shall be a path to a folder containing ONLY examples named *01.in *01.out etc."
    echo ""
    exit 1
}




if [[ $EUID -ne 0 ]];
then
    echo "This script must be run as root" 
    exit 1
fi


if [ "$#" -ne 2 ];
then
    print_manual
fi

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

for entry in $2/*.in
do
    echo "Testing file $entry"
    cat $1 >> merged.ss
    echo "" >> merged.ss
    cat $entry >> merged.ss

    plt-r5rs merged.ss 2> toCompare1 | tr -d '\n' > toCompare1
    cat ${entry%.*}.out | tr -d '\n' > toCompare2

    diff toCompare1 toCompare2 > /dev/null?
    result=$?
    
    if [ $result -ne 0 ]
    then
        echo -e "${RED}Wrong...${NC}"
        echo "Your output is:"
        cat toCompare1
        echo ""
        echo "It should be:"
        cat toCompare2
        echo ""
    else
        echo -e "${GREEN}Output is ok.${NC}"
    fi
    rm merged.ss
    rm toCompare1
    rm toCompare2
    echo ""

done
