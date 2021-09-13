#!/usr/bin/env bash

source scripts/_functions.sh

echo -e "\n Setting up git hooks\n"

chmod +x ./scripts/pre_commit_hook.sh

declare -a DIRS=("epb-register-api" "epb-frontend")
# declare -a DIRS=("epb-register-api" "epb-frontend" "epb-auth-server" "epb-data-warehouse" "epb-view-models" "epb-auth-tools" "epb-scripts")

echo -e "  Cloning EPB repositories...\n"
cd ".."
for i in "${DIRS[@]}"
do
   if [[ ! -d $i ]]; then
     echo -e "  Cloning $i"
     git clone "https://github.com/communitiesuk/$i.git"
   else
     echo -e "  Repository $i exists, continuing"
   fi
done

echo -e "  Setting up git pre-commit hooks for:"
for i in "${DIRS[@]}"
do
   cd "$i"
   echo -e "    $i"
   git_dir=$(git rev-parse --git-dir)

   rm -r $git_dir/hooks/pre-commit 2>/dev/null

   # create symlink to the pre-commit script
   ln -s ../epb-dev-tools/scripts/pre_commit_hook.sh $git_dir/hooks/pre-commit
   cd ".."
   
   # check if symlink created
   # if [ -L ${hook_path} ] && [ -e ${hook_path} ]; then
   #   echo "true"
   # else
   #   echo "false"
   # fi
done
