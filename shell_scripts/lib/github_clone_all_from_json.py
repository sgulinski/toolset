import json, os, subprocess, sys

json_response=json.load(sys.stdin)
repositories_num=len(json_response)
print("About to start cloning " + str(repositories_num) + " repositorie(s)\n",
    flush=True)

imported_repos_num=0
skipped_repos_num=0

for repository in json_response:
    if (not os.path.isdir("./" + repository["name"])):
        subprocess.call("git clone " + repository["ssh_url"], shell=True)
        imported_repos_num += 1
    else:
        print("Repository '" + repository["name"] + "' exists - skipping",
            flush=True)
        skipped_repos_num += 1

    print("\n", flush=True)

print("\nSkipped " + str(skipped_repos_num) + " repositories", flush=True)
print("Imported " + str(imported_repos_num) + " repositories\n", flush=True)
