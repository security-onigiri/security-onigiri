#!/bin/bash
rm -rf security-onigiri.github.io/
bundle exec jekyll build --destination=security-onigiri.github.io
cd security-onigiri.github.io/
git init
git add .
git commit -m "Update"
git remote add origin git@github.com:security-onigiri/security-onigiri.github.io.git
git push -u origin master -f
