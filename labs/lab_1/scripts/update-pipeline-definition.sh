#!/bin/bash

if ! command -v jq &> /dev/null; then
	echo "Error: jq is not installed. Please install jq before running this script."
	exit 1
fi

if [ -z "$1" ]; then
	echo "Error: Please provide JSON definition file (e.g., pipeline.json)"
	exit 1
fi

PIPELINE_DEFINITIONS_FILE="$1"

NEW_FILENAME="pipeline-$(date +%Y-%m-%d).json"

# Exclude the JSON file from parsing arguments
shift

while [[ $# -gt 0 ]]; do
	key="$1"
	case $key in
		--configuration)
                        BUILD_CONFIGURATION="$2"
                        shift
                        ;;
		--owner)
			OWNER="$2"
			shift
			;;
		--branch)
                        BRANCH="$2"
                        shift
                        ;;
		--poll-for-source-changes)
			POLL_FOR_CHANGES="$2"
			shift
			;;
	esac
	shift
done

if ! jq -e ".metadata and .pipeline.version and .pipeline.stages[]?.actions[]?.configuration" "${PIPELINE_DEFINITIONS_FILE}" &> /dev/null; then
	echo "Error: Invalid JSON definition. Please check the JSON strusture and try again."
	exit 1
fi

jq -cM \
	--arg BRANCH "${BRANCH}" \
	--arg OWNER "${OWNER}" \
	--arg REPOSITORY "${REPOSITORY}" \
	--arg POLL_FOR_CHANGES "${POLL_FOR_CHANGES}" \
	--arg BUILD_CONFIGURATION "[{\"name\":\"BUILD_CONFIGURATION\",\"value\":\"${BUILD_CONFIGURATION}\",\"type\":\"PLAINTEXT\"}]", \
	'del(.metadata)
		| .pipeline.version |= .+1
		| (.pipeline.stages[].actions[].configuration.Branch? // "") = $BRANCH
		| (.pipeline.stages[].actions[].configuration.Owner? // "") = $OWNER
		| (.pipeline.stages[].actions[].configuration.Repo? // "") = $REPOSITORY
		| (.pipeline.stages[].actions[].configuration.PollForSourceChanges? // "") = $POLL_FOR_CHANGES
		| (.pipeline.stages[].actions[].configuration.EnvironmentVariables? // "") = ($BUILD_CONFIGURATION | tostring)
	' "${PIPELINE_DEFINITIONS_FILE}" > "${NEW_FILENAME}"

echo "Pipeline definition was updated. New file created: $NEW_FILENAME"



