#!/usr/bin/env bash

#$1 should be the BranchID
#$2 should be the repository e.g. https://github.com/MyCoRe-Travis/MIR_test_artifacts.git

git clone $2 ./autodeploy
cd ./autodeploy
git branch $1
git checkout $1
printf "Travis: https://travis-ci.org/MyCoRe-Org/mir/builds/$TRAVIS_BUILD_ID \n\nMycore-Pull: https://github.com/MyCoRe-Org/mir/pull/$TRAVIS_PULL_REQUEST \n\nCommit: https://github.com/MyCoRe-Org/mir/commit/$TRAVIS_COMMIT" > README.md
cd ../

mkdir -p autodeploy/mir-it/failsafe-reports/
cp -r mir-it/target/failsafe-reports/ autodeploy/mir-it/failsafe-reports/

cd ./autodeploy
git add .
git commit -m "adding test results"
git push -f --set-upstream origin $1

SAVE=20

FIRST=$(( TRAVIS_BUILD_NUMBER - SAVE ))
PROTECT=$(seq $FIRST $TRAVIS_BUILD_NUMBER)

eval "$(git for-each-ref --shell --format='git push origin --delete %(refname)' refs/remotes/origin|grep -v $(echo "$PROTECT" |sed -e 's|\(.*\)|refs/remotes/origin/\1|g'|xargs -I repl echo -n repl"\\|" && echo -n 'refs/remotes/origin/HEAD\|refs/remotes/origin/master')|sed -e 's|refs/remotes/origin/||')"

if [ "$TRAVIS_PULL_REQUEST" != "false" ]
then curl -H "Authorization: token $GITHUB_TOKEN" -X POST -d '{"body":"Something gone wrong on $TRAVIS_COMMIT! \n Plese Check https://github.com/MyCoRe-Travis/test_artifacts/tree/$1"}' https://api.github.com/repos/MyCoRe-Org/mir/issues/$TRAVIS_PULL_REQUEST/comments