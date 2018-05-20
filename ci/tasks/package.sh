#!/bin/bash

set -e -u -x

timestamp=`date "+%Y%m%d%H%M%S"`

cd source-code/
  ./mvnw -Dmaven.repo.local=./.m2/repository build-helper:parse-version versions:set -DnewVersion=\${parsedVersion.majorVersion}.\${parsedVersion.minorVersion}.\${parsedVersion.incrementalVersion}-${timestamp} versions:commit
  ./mvnw -Dmaven.repo.local=./.m2/repository clean package deploy --settings .settings.xml
  version=$(grep -E -m 1 -o "<version>(.*)</version>" pom.xml | sed 's/<version>//' | sed 's/<\/version>//')
  group=$(grep -E -m 1 -o "<groupId>(.*)</groupId>" pom.xml | sed 's/<groupId>//' | sed 's/<\/groupId>//')
  artifact=$(grep -E -m 1 -o "<artifactId>(.*)</artifactId>" pom.xml | sed 's/<artifactId>//' | sed 's/<\/artifactId>//')
cd ..

echo { \"artifact\": [{ \"group\": \"$group\", \"artifact\": \"$artifact\", \"version\": \"$version\", \"repositoryUrl\": \"$REPO_URL\" }] } > build-output/gav
cp source-code/target/${artifact}-${version}.jar  build-output/.
