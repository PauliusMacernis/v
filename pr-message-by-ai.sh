#!/bin/sh


OPENAI_ENGINE="gpt-3.5-turbo-instruct-0914"

# Get the target and destination branch names from the script parameters
SCRIPT_NAME=$(basename "$0")
TARGET_BRANCH="$1"
DESTINATION_BRANCH="$2"
OPENAI_API_KEY="$3"

# Check if both branches are provided
if [ -z "$TARGET_BRANCH" ] || [ -z "$DESTINATION_BRANCH" ]; then
    echo "Available branches:"
    git branch -a
    echo "----------------------------------------"
    echo "Usage: ./${SCRIPT_NAME} <target_branch> <destination_branch>"
    exit 1
fi

set -e

echo "Versions check (script stops if any of these fail):"
git --version
curl --version
jq --version

# Print the branch names (or do whatever you want with them)
echo "Comparing target branch: $TARGET_BRANCH with destination branch: $DESTINATION_BRANCH"

# Generate git diff
git diff "${TARGET_BRANCH}" "${DESTINATION_BRANCH}" > temp/git_diff_pr_output.txt

# Check if diff_output.txt is empty
if [[ ! -s temp/git_diff_pr_output.txt ]]; then
    echo "No differences found."
    exit 0
fi

if [[ -z "$OPENAI_API_KEY" ]]; then
    echo "Error: OpenAI API key not set."
    exit 1
fi

# Create a JSON payload using jq
PAYLOAD=$(jq -n \
            --arg diff "$(cat temp/git_diff_pr_output.txt)" \
            '{prompt: ("Describe the main action and purpose of the following code change in a clear and concise manner, limit the response to 200 characters:" + $diff), max_tokens: 150}')

# Send to AI and get summary using the /completions endpoint
RESPONSE=$(curl -s -X POST -H "Authorization: Bearer $OPENAI_API_KEY" \
               -H "Content-Type: application/json" \
               -d "$PAYLOAD" \
               https://api.openai.com/v1/engines/$OPENAI_ENGINE/completions)

echo "API Response:"
echo "$RESPONSE"

# Remove newline characters from the API response using sed (macOS compatible version)
CLEANED_RESPONSE=$(echo "$RESPONSE" | sed -e ':a' -e 'N' -e '$!ba' -e 's/\n//g')

# Extract the summary using jq
SUMMARY=$(echo "$CLEANED_RESPONSE" | jq -r '.choices[0].text')

# Check if SUMMARY is valid
if [[ "$SUMMARY" == "null" || -z "$SUMMARY" ]]; then
    echo "Error: Unable to get a valid summary."
    exit 1
fi

echo "Summary of Git Diff:"
echo "$SUMMARY"