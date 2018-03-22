#!/bin/bash
rm -rf _site
git clone git@github.com:security-onigiri/security-onigiri.github.io.git _site
JEKYLL_ENV=production bundle exec jekyll build
cd _site
git add .
git commit --allow-empty -m "Update"
git push
