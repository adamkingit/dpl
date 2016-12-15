#!/bin/bash

echo "print some environment variables for debugging"
echo "TRAVIS_TAG == $TRAVIS_TAG"
echo "TRAVIS_BRANCH == $TRAVIS_BRANCH"
echo "TRAVIS_COMMIT == $TRAVIS_COMMIT"

echo "test1 "
if [[ $TRAVIS_TAG == 'beta' ]];then
  echo "tag is == beta"
else
  echo "tag is not beta"
fi

echo "test2 "
if [[ $TRAVIS_TAG != 'beta' ]];then
  echo "tag is != beta"
else
  echo "tag is beta"
fi
