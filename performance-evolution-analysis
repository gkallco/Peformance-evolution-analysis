#!/bin/bash

# $1--> location of all projects
# $2--> where to save all cost-reports
# $3--> how many commits to check for each file

cd $1 
touch failed_projects.txt

for project in $( find . -maxdepth 1 -mindepth 1 -type d )
do
    cd $2

    project_costs_folder=$2/${project}-costs
    project_outputs_folder=$2/outputs/${project}-outputs

    mkdir ${project_costs_folder}
    mkdir -p ${project_outputs_folder}

    counter=0
    cd $1/$project

    flag=true

    for commit in $(git rev-list master)
    do
        cd $1/$project
        counter=$((counter+1))
        counter_in_filename=`printf %06d $counter`

        echo $counter 

        git checkout -f $commit
        timeout 120 infer run --cost-only -- mvn clean package -DskipTests &> ${project_outputs_folder}/${counter_in_filename}-$commit.txt

        cd infer-out

        if [[ -e costs-report.json ]]
        then
            cp costs-report.json ${project_costs_folder}/${counter_in_filename}-$commit.json
        else
            echo "Cost report for ${project} in commit ${commit} could not be generated"
        fi

        if [ $counter -gt $3 ]
        then 
            break
        fi

        if [ $counter -gt 5 ] && [ $flag = true ];then
            flag=false
            if ! [[ $(ls -A "${project_costs_folder}") ]] ; then
                echo $project---maven-does-not-compile >> $1/failed_projects.txt
                rm -rf ${project_costs_folder}
                break

            elif ! [[ -s ${project_costs_folder}/${counter_in_filename}-$commit.json ]] ; then
                echo $project---cost-report-empty >> $1/failed_projects.txt
                rm -rf ${project_costs_folder}
                break
            fi
        fi
    done
done

# read -p 'Enter where are your projects: ' location
# read -p 'Enter where do you want to save the information: ' reports
# read -p 'Enter how many commits you want to consider: ' commits
# costs_of_each_commit $location $reports $commits
