import json
import logging
import os
import shutil
import mcp.types as types
from typing import List

logger = logging.getLogger(__name__)

async def sca_fix_vulnerability(pkg_name: str, target_version: str, project_dir: str) -> List[types.TextContent]:
    """
    Attempt to fix a specific package vulnerability by upgrading the package to a target version
    in recognized dependency manifest files. Supported manifests include `requirements.txt`,
    `package.json`, `Gemfile`, and `go.mod`. This function searches these files within the
    provided project directory, creates backups for safety, and updates the relevant dependency
    to the specified target version if found.

    :param pkg_name: Name of the package to upgrade.
    :type pkg_name: str
    :param target_version: Target version to which the package should be upgraded.
    :type target_version: str
    :param project_dir: Path to the directory containing the project's dependency manifests.
    :type project_dir: str
    :return: A list of messages detailing the updates performed or any errors encountered.
    :rtype: List[types.TextContent]
    """
    logger.debug(f"sca_fix_vulnerability tool called with pkg_name={pkg_name}, target_version={target_version}")
    logger.info(f"\nAttempting to fix vulnerability in package: {pkg_name}")

    package_files = []
    for root, _, files in os.walk(project_dir):
        for file in files:
            if file in ["requirements.txt", "package.json", "Gemfile", "go.mod"]:
                package_files.append(os.path.join(root, file))

    if not package_files:
        return "No package manifest files found in the project"

    results = []
    for file_path in package_files:
        file_name = os.path.basename(file_path)
        backup_path = file_path + ".bak"
        shutil.copy2(file_path, backup_path)

        try:
            if file_name == "requirements.txt":
                with open(file_path, 'r') as f:
                    lines = f.readlines()
                with open(file_path, 'w') as f:
                    for line in lines:
                        if line.strip().startswith(pkg_name):
                            f.write(f"{pkg_name}=={target_version}\n")
                        else:
                            f.write(line)
                results.append(f"Updated {pkg_name} to version {target_version} in {file_path}")

            elif file_name == "package.json":
                with open(file_path, 'r') as f:
                    package_json = json.load(f)

                updated = False
                for dep_type in ["dependencies", "devDependencies"]:
                    if dep_type in package_json and pkg_name in package_json[dep_type]:
                        package_json[dep_type][pkg_name] = target_version
                        updated = True

                if updated:
                    with open(file_path, 'w') as f:
                        json.dump(package_json, f, indent=2)
                    results.append(f"Updated {pkg_name} to version {target_version} in {file_path}")

            elif file_name == "Gemfile":
                with open(file_path, 'r') as f:
                    lines = f.readlines()

                with open(file_path, 'w') as f:
                    for line in lines:
                        if f"gem '{pkg_name}'" in line or f'gem "{pkg_name}"' in line:
                            f.write(f"gem '{pkg_name}', '~> {target_version}'\n")
                        else:
                            f.write(line)
                results.append(f"Updated {pkg_name} to version {target_version} in {file_path}")

            elif file_name == "go.mod":
                with open(file_path, 'r') as f:
                    lines = f.readlines()

                with open(file_path, 'w') as f:
                    for line in lines:
                        if line.strip().startswith(pkg_name):
                            f.write(f"{pkg_name} v{target_version}\n")
                        else:
                            f.write(line)
                results.append(f"Updated {pkg_name} to version {target_version} in {file_path}")

        except Exception as e:
            shutil.copy2(backup_path, file_path)
            error_msg = f"Error updating {file_path}: {str(e)}"
            logger.error(error_msg)
            results.append(error_msg)
        finally:
            if os.path.exists(backup_path):
                os.remove(backup_path)

    if not results:
        return [types.TextContent(type="text", text=f"Could not find {pkg_name} in any package manifest files")]

    return [types.TextContent(type="text", text="\n".join(results))]