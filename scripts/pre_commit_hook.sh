# .git/hook/pre-commit

#!/bin/sh
#
# Check for ruby style errors

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
NC='\033[0m'

echo "Running pre-commit checks"

# if git rev-parse --verify HEAD >/dev/null 2>&1
# then
# 	against=HEAD
# else
# 	# Initial commit: diff against an empty tree object
#   first_commit="$(git log master --oneline | tail -1 | cut -c1-8)"
# 	against=first-commit
# fi

# Get only the staged files
FILES="$(git diff --cached --name-only --diff-filter=AMC | grep "\.rb$" | tr '\n' ' ')"

# echo "${green}[Ruby Style][Info]: Checking Ruby Style${NC}"

if [ -n "$FILES" ]
then
	# echo "${green}[Ruby Style][Info]: ${FILES}${NC}"

	if [ ! -f '.rubocop.yml' ]; then
	  echo "${yellow}[Ruby Style][Warning]: No .rubocop.yml config file.${NC}"
	fi

	# Run rubocop on the staged files
	rubocop ${FILES}

	if [ $? -ne 0 ]; then
	  echo "${red}[Ruby Style][Error]: Fix the issues and commit again${NC}"
    echo "In exceptional circumstances to skip pre-commit check run 'git commit --no-verify'"
	  exit 1
	fi
else
	echo "${green}[Ruby Style][Info]: No files to check${NC}"
fi

exit 0
