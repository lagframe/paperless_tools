#!/bin/bash

# Setting this, so the repo does not need to be given on the commandline:
export BORG_REPO=/media/backup-drive/paperless-backups

# See the section "Passphrase notes" for more infos.
export BORG_PASSPHRASE=''

# some helpers and error handling:
info() { printf "\n%s %s\n\n" "$( date )" "$*" >&2; }
trap 'echo $( date ) Backup interrupted >&2; exit 2' INT TERM

info "Starting backup"

su dockeruser -c "docker-compose --project-directory /home/dockeruser/paperless-ngx/ down"

# Backup the docker directories

borg create                         \
    --verbose                       \
    --filter AME                    \
    --list                          \
    --stats                         \
    --show-rc                       \
    --compression lz4               \
                                    \
    ::'paperless-{now}'             \
    /var/lib/docker/volumes/paperless_media   \
    /var/lib/docker/volumes/paperless_data   \
    /home/dockeruser/paperless-ngx/docker-compose.env   \
    /home/dockeruser/paperless-ngx/docker-compose.yml   \

backup_exit=$?

# only if you use PostgreSQL, add: /var/lib/docker/volumes/paperless_pgdata \

info "Pruning repository"

# Use the `prune` subcommand to maintain archives of THIS machine. The 
# 'paperless-' prefix is very important to limit prune's operation to
# this archive.

borg prune                          \
    --list                          \
    --prefix 'paperless-'          \
    --show-rc                       \
    --keep-daily    7               \
    --keep-weekly   4               \
    --keep-monthly  6               \

prune_exit=$?

# actually free repo disk space by compacting segments

info "Compacting repository"

borg compact

compact_exit=$?

# use highest exit code as global exit code
global_exit=$(( backup_exit > prune_exit ? backup_exit : prune_exit ))
global_exit=$(( compact_exit > global_exit ? compact_exit : global_exit ))

su dockeruser -c "docker-compose --project-directory /home/dockeruser/paperless-ngx/ up -d"

if [ ${global_exit} -eq 0 ]; then
    info "Backup, Prune, and Compact finished successfully"
elif [ ${global_exit} -eq 1 ]; then
    info "Backup, Prune, and/or Compact finished with warnings"
else
    info "Backup, Prune, and/or Compact finished with errors"
fi

exit ${global_exit}
