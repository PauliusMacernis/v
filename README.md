# About

This repository contains a Proof of Concept for a versioning system hosted on Github.

## Building Blocks of the Solution

The primary component of this system is:

- `.github/workflows/versioning.yml`: A Github Action workflow that is triggered when a pull request is closed.

Other notable components include:

- `.github/pull_request_template.md`: A template that is automatically applied when creating a new pull request.
- `helpers/commit-message-by-ai.sh`: A script that suggests a commit message based on the git diff. It's designed for macOS; Linux compatibility hasn't been tested.
- `helpers/pr-message-by-ai.sh`: A script that suggests a pull request message based on the git diff. Like the previous script, it's tailored for macOS, with Linux compatibility untested.

## Workflow Overview

1. Start with a main branch (e.g., `master`). When creating a new branch, use a prefix like `bug/`, `task/`, or `feat/`.
2. After coding, consider using the commit message suggestion script: `./helpers/commit-message-by-ai.sh "YOUR_OPENAI_API_KEY"`. If the suggested message isn't satisfactory, run the script again or craft your own message.
3. Once you've committed your changes, open a pull request on github.com, e.g., merging `bug/TASK-123_Exchanging_x_with_y` into `master`. The pull request template will be applied automatically.
4. If you wish to modify the pull request message, use the script: `./pr-message-by-ai.sh "master" "bug/TASK-123_Exchanging_x_with_y" "YOUR_OPENAI_API_KEY"`. This will suggest you the message which you may use or not.
5. Upon closing the pull request, the `.github/workflows/versioning.yml` is triggered, leading to:
    - The latest version is determined based on the branch prefix:
      - **major**: major/, release/
      - **minor**: minor/, feature/, feat/, task/, refactor/, poc/, innovation/
      - **patch**: patch/, bug/, doc/, tools/, hotfix/, **any other**
    - An update to `version.txt` with the latest version, adhering to Semantic Versioning rules.
    - An update to `CHANGELOG.md` with the latest changes. Version number and Initial pull request title goes as a content.
    - An update to `database` directory - moving `database\update.sql` and `database\rollback.sql` files to appropriate version dir and appending one extra query to each.
    - Creation of a git tag corresponding to the new version.
    - Pushing `version.txt`, `CHANGELOG.md`, and the new tag to the remote git repository.

## Important Notes

- Ensure "Read and write permissions" are enabled for Github Actions in your repository (Settings > Actions > General > Workflow permissions).
- Generate a Personal Access Token with `repo` scope (Settings > Developer settings > Personal access tokens).
- Add the token as a secret in your repository settings with the key "GH_PAT" (Settings > Secrets and variables > Actions > Secrets > Repository secrets).
- Ensure your OpenAI account has sufficient funds for API calls. Note that a Plus subscription to ChatGPT isn't equivalent. Generate a valid OpenAI API key in your OpenAI account settings (https://platform.openai.com/account/api-keys).

## Disclaimer

The helper scripts ([commit-message-by-ai.sh](helpers%2Fcommit-message-by-ai.sh) and [pr-message-by-ai.sh](helpers%2Fpr-message-by-ai.sh)) utilize OpenAI for suggestions. Be cautious: sharing code with the OpenAI API might pose a security risk, especially if proprietary information is involved. Use these scripts at your discretion and risk.
