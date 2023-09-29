# About

This is a Proof of Concept of a versioning system for a Github hosted project.


## Building blocks of the solution

Main part of the system is:

- `.github/workflows/versioning.yml` - a Github Action workflow which triggers after a pull request is closed.

Other mentionable parts of the system are:

- `.github/pull_request_template.md` - a template for a pull request which will be applied at the time of creating a pull request.
- `helpers/commit-message-by-ai.sh` - a script which suggests a _commit message_ based on the git diff. This script is meant to be run on a mac, linux is no tested.
- `helpers/pr-message-by-ai.sh` - a script which suggests a _pull request_ message based on the git diff. This script is meant to be run on a mac, linux is no tested.


## How it all works in a flow

- You have a main branch (e.g. `master`) as usual, then you branch from it by applying a prefix to the new branch name (e.g. `bug/`, `task/`, `feat/`). 
- After you are done with coding a piece, you may want to run a commit message suggestion script, e.g.: `./helpers/commit-message-by-ai.sh "YOUR_OPENAI_API_KEY_MUST_BE_PLACED_HERE"`. Run it several times to get another message if the current one is not good enough. You may copy > paste the suggested message to your own commit message or not, it's up to you. The script is suggesting only.
- After you are done with committing, you go to github.com and open a pull request, e.g. to merge your new branch `bug/TASK-123_Exchanging_x_with_y` into `master`. Pull request template (`.github/pull_request_template.md`) applies automatically and you have a prepared pull request comment.
- In case you want to modify pull request template but don't want to think by too much, then you run another script, e.g. `./pr-message-by-ai.sh "master" "bug/TASK-123_Exchanging_x_with_y" "YOUR_OPENAI_API_KEY_MUST_BE_PLACED_HERE"` which will suggest you the pull request message. You may copy > paste the suggested message to your own pull request message or not, it's up to you. The script is suggesting only.
- After the pull request is done, at some time you close it. When you close the pull request then `.github/workflows/versioning.yml` triggers on the github.com Actions side and the following happens:
  - `version.txt` is updated with the newest version following the Semantic versioning rules (major, minor or patch number increase is determinated by the name of the branch which is merging in),
  - `CHANGELOG.md` is updated with the newest changes: version number as a header of the new section and the initial pull request title as a text of the new section.
  - tag corresponding to the new version is created in the git repository.
  - `version.txt`, `CHANGELOG.md` and the tag are pushed to the remote git repository.


## Gotchas

- Make sure you have "Read and write permissions" set for the Github Actions in your repository settings (Settings > Actions > General > Workflow permissions).
- Make sure you have generated your own Personal Access Token (Settings > Developer settings > Personal access tokens. The token must have `repo` scope.
- Make sure you have set the new Personal Access Token as a secret in your repository settings (Settings > Secrets and variables > Actions > Secrets > Repository secrets > add a key "GH_PAT" and the value you have got from the general settings).
- Make sure you have some money in your OpenAI account to pay for the API calls (Plus subscription to ChatGPT is not the same thing). Also, make sure you have Open AI API key generated for legit use in your OpenAI account settings (https://platform.openai.com/account/api-keys)


## Disclaimer

Helper scripts ([commit-message-by-ai.sh](helpers%2Fcommit-message-by-ai.sh), [pr-message-by-ai.sh](helpers%2Fpr-message-by-ai.sh)) use OpenAI to get the suggestions. Be concious, sending your code to the OpenAI API may be a security risk (e.g. if you share a propriatary info this way). Use it at your own risk.

