#!/bin/bash

# $1--> in what folder is the project folder
# $2--> in what folder should save project-costs folder with all cost-reports
# $3--> project name
# $4--> how many commits to check

project= $3
project_costs_folder=$2/${project}-costs
project_outputs_folder=$2/outputs/${project}-outputs

cd $2
mkdir ${project_costs_folder}
mkdir -p ${project_outputs_folder}

counter=0
flag=true
cd $1/$project

for commit in $(git rev-list master)
do
    counter=$((counter+1))
    counter_in_filename=`printf %06d $counter`

    echo $counter

    git checkout -f $commit
    timeout 120 infer run --cost-only -- mvn clean package -DskipTests &> ${project_outputs_folder}/${counter_in_filename}-$commit.txt

    cd infer-out

    if [[ -e costs-report.json ]]; then
        cp costs-report.json ${project_costs_folder}/${counter_in_filename}-$commit.json
    else
        echo "Cost report for ${project} in commit ${commit} could not be generated"
    fi

    if [ $counter -gt $4 ]; then
        break
    fi

    if [ $counter -gt 5 ] && [ $flag = true ]; then
        flag=false
        if ! [[ $(ls -A "${project_costs_folder}") ]]; then
            echo $project---maven-does-not-compile >> $1/failed_projects.txt
            rm -rf ${project_costs_folder}
            break
    fi
done


# read -p 'Enter where are your projects: ' location
# read -p 'Enter where do you want to save the information: ' reports
# read -p 'Enter how many commits you want to consider: ' commits
# costs_of_each_commit $location $reports $commits
