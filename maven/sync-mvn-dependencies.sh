#!/usr/bin/env bash

### project home
PROJ_HOME=$(pwd)
### find pom.xml locations
POM_FILE_LOCATION_ARRAY=$(find ./ -name pom.xml)
### find maven cmd
MVN_CMD=$(find /c -name mvn | grep "maven3")
MAVEN_REPO_HOME="/c/Users/Administrator/.m2/repository"
TARGET_PATH="/c/tmp"

echo "[step2 => output dependencies into dependencies.out start ]"

touch $PROJ_HOME/dependencies.out
for location in ${POM_FILE_LOCATION_ARRAY[@]}
do
 cd ${location%/*}
 (bash "$MVN_CMD" -o dependency:list | grep ".*:.*:.*:.*:.*" | grep -v "at") >> $PROJ_HOME/dependencies.out
 cd $PROJ_HOME
done
echo "[output dependencies with maven-dependency-plugin end]"


echo "[step2 => pretreatment  start]"
sort -u dependencies.out > uniqDependencies.out
rm -rf dependencies.out
echo "[step2 => sort and generate uniqDependencies file done]"
sed -i "s/\[INFO\]\s\{4\}//g" uniqDependencies.out
echo "[step2 => remove redundant; done]"
sed '/^$/d' uniqDependencies.out
echo "[step2 => remove blank line; done]"
echo "[step2 => pretreatment end]"

echo "[step3 => cp start ]"
mkdir -p ${TARGET_PATH}
cd ${MAVEN_REPO_HOME}

while read dependency
do
  array=(${dependency//:/ })
  groupId=${array[0]}
  groupIdPath=${groupId//.//}
  artifactIdPath=${array[1]}
  versionPath=${array[3]}
  depPath=${groupIdPath}"/"${artifactIdPath}"/"${versionPath}
  cp -rf --parents ${depPath} ${TARGET_PATH}
done < ${PROJ_HOME}/uniqDependencies.out
echo "[step3 => cp end]"
