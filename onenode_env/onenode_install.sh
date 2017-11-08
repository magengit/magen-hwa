#!/bin/bash
set -u

#--------------------------------------------------------------------------
# ONENODE CONFIG VALUES: BEGIN
#--------------------------------------------------------------------------

# Before start making sure some required paths exist
mkdir -p ~/magen_data/

docker_registry=magendocker

magen_root=~/magen_onenode
magen_root_printable="~/magen_onenode"
magen_data=$magen_root/magen_data
magen_source=$magen_root/magen_source
onenode_scripts=$magen_root/onenode_scripts

# Docker specifics
docker_network=magen_onenode_net

#--------------------------------------------------------------------------
# ONENODE UTILITY FUNCTIONS: BEGIN
#--------------------------------------------------------------------------

#
# opt_arg_reqd_no_override
#
#
# opt_arg_reqd
#
opt_arg_reqd()
{
    if [ $# = 1 ] ; then
	echo "$progname: $1 requires an argument" >&2
	${progname}_usage 1 >&2
    else
	case $2 in
	-*)
	    echo "$progname: ERROR: option $1 requires an argument, was followed by another option ($2)" >&2
	    ${progname}_usage 1 >&2
	    ;;
	esac
    fi
}

#
# opt_arg_reqd_no_override
#
opt_arg_reqd_no_override()
{
    if [ $# -lt 2 ]; then
	echo "$progname: option processing internal error" >&2
	exit 1
    fi
    if [ ! -z "$1" ]; then
	echo "$progname: ERROR: multiple values for $1" >&2
	${progname}_usage 1 >&2
    fi
    shift
    opt_arg_reqd $*
}

main_opt_process()
{
    _prog_=$1; shift

    _opt_=$1

    case $_opt_ in
    -h*)
        ${_prog_}_usage 0
        ;;
    -d)
        set -x
        ;;
    -*)
	echo "$_prog_: unknown argument $_opt_"
	${_prog_}_usage 1
	;;
    esac
}

#
# Return random alpha-numeric string of supplied length
#
random_string()
{
    len=$1
    secret_str=$(LC_CTYPE=C tr -dc '[:alnum:]' < /dev/urandom  | dd bs=$len count=1 2> /dev/null)
    echo $secret_str
}

pkg_subcodes_filter()
{
    case $prog_base in
    $pkg_dist)    # filter start
	filter='(start|stop|uninstall)'
	;;
    *)            # passthrough
	filter='(install)'
	;;
    esac
    # - filter install must not filter uninstall
    # - allow only spaces or tab before filter
    egrep -v "^[ 	]*$filter"
}

#
# helper scripts to be installed as part of onenode package
#
onenode_helper_scripts()
{
    cat <<ONENODE_HELPER_SCRIPTS_EOF
aws_login.sh
docker_clean.sh
docker_compose_check.sh
docker_compose_runall.sh
docker_images_download.sh
docker_images_remove_matching.sh
docker_registry_login.sh
docker_registry_type.sh
ONENODE_HELPER_SCRIPTS_EOF
}

#
# If requested, update docker images as needed. (Downloading images
# can be slow with poor connectivity so do not do it every time.)
# Currently only has effect when building from downloaded docker images,
# not when building from source.
#
docker_image_update()
{
    src="$(grep $docker_registry $magen_data/id/Dockerfile)"
    if [ -n "$src" ]; then
	$onenode_scripts/docker_images_download.sh $docker_registry || exit 1
	docker-compose -f docker-compose-runall.yml build
    fi
}

#
# Generate a Dockerfile to generate a docker image to run a docker container
# for onenode.
# Add a dummy file to force an extra layer so that the onenode docker
# image differs from the base image (e.g. images with these tags
# are slightly different
#   - magen_ks:onenode
#   - $docker_image_registry/magen-ks:latest
# That allows onenode to manage and uninstall its own images.
wrapper_dockerfile()
{
    image_server=$1
    tag=$2
    version=$3

    case $image_server in
    local)
	full_tag=$tag
	;;
    *)
	full_tag=$image_server/$tag
	;;
    esac
    cat <<DOCKERFILE
FROM $full_tag:$version
RUN touch /magen-onenode-$tag-built-from-$image_server
DOCKERFILE
}

id_clt_secret_file()
{
    svc=$1
    clt_id=$2
    clt_secret=$3

    cat <<ID_CLT_SECRET_FILE
{
    "${svc}_idsclt_client_id": "$clt_id",
    "${svc}_idsclt_client_secret": "$clt_secret"
}
ID_CLT_SECRET_FILE
}

host_cfg_file()
{
    svc=$1
    host=$2
    cat <<HOST_CFG_FILE
{
    "hostname": "$host"
}
HOST_CFG_FILE
}

###########################################################################
# ONENODE OPERATIONS: BEGIN
###########################################################################

#--------------------------------------------------------------------------
# ONENODE_INSTALL
#---------------------------------------------------------------------------
host_default=localhost # hwa app access limited to local browsing (e.g. on Mac)

onenode_install_usage()
{
    cat <<ONENODE_INSTALL_USAGE
Usage:
    $prog_base $prog_opcode --build-from { dockerimage | source | source_latest } [-host <host>]
        --build-from: start with docker images (from image repo), source
                      from git tagged repo) or source_latest
        --host:       specify global ip name or address to allow remote
                      browsing of hwa app
                      (default:localhost, allowing only local browsing)

Description:
    Install one-node magen instance in newly created directory tree
    under $magen_root_printable
    [Cleanup operation: "$pkg uninstall"]

Examples:
         bash$ $prog_base $prog_opcode --build-from dockerimage
         bash$ $prog_base $prog_opcode --build-from dockerimage --host <hostname>
         bash$ $prog_base $prog_opcode --build-from source
         bash$ $prog_base $prog_opcode --build-from source_latest

ONENODE_INSTALL_USAGE

    exit $1
}

onenode_install()
{
#    gitkeys=deploy
    host=
    id_client_id=$(random_string 32)
    id_client_secret=$(random_string 32)

    buildfrom=

    while [ $# != 0 ] ; do
	case $1 in
	-help)
      ${progname}_usage 0
	    ;;
  --build-from)
      opt_arg_reqd_no_override "$buildfrom" $*
      shift
      buildfrom=$1
	    ;;
	--host)
      opt_arg_reqd_no_override "$host" $*
      shift
      host=$1
	    ;;
	-*)
	    echo "$progname: ERROR: unrecognized option $1" >&2
            ${progname}_usage 1
	    ;;
        *)
            ${progname}_usage 1
	    ;;
	esac
	shift
    done

    case $buildfrom in
    source|source_latest|dockerimage)
        # legal choices
	;;
    "")
	echo "$progname: FATAL: must specify build-from" >&2
        ${progname}_usage 1
	;;
    *)
	echo "$progname: FATAL: unknown build-from ($buildfrom)" >&2
        ${progname}_usage 1
	;;
    esac

    if [ -z "$host" ]; then
        host=$host_default
    fi

    echo "$progname: Creating sandbox under $magen_root"
    if [ -d $magen_root ]; then
	echo "$progname: FATAL: $magen_root already exists" >&2
	exit 1
    fi
    mkdir $magen_root

    cd $prog_dir  # $prog_dir is repo dir (onenode_env) that is root of content
    echo "$progname: Creating sandbox director skeleton"
    cp -p onenode_install.sh $magen_root/onenode.sh

    dc_file=docker-compose-runall
    cp -p magen_cfgfile.templates/${dc_file}.yml-dist $magen_root/$dc_file.yml
    cp -p magen_cfgfile.templates/${dc_file}-source.yml $magen_root
    tar -c \
        --exclude onenode_install.sh \
        --exclude magen_cfgfile.templates \
	--exclude .keep -f \
	- . | \
	(cd $magen_root; tar xf -)
    mkdir -p $onenode_scripts
    for file in $(onenode_helper_scripts | grep -v ^#); do
	cp -p ../lib/magen_helper/helper_scripts/$file $onenode_scripts
    done
    mv $magen_root/magen_data.template $magen_root/magen_data

    echo -n "$progname: Creating sandbox magen config/secrets files for ... "

    # id secrets (could be configured by hwa)
    echo -n "id, "
    id_data_dir=$magen_data/id/data
    id_secrets_dir=$id_data_dir/secrets
    cat magen_cfgfile.templates/id-bootstrap.json-dist | sed -e "s/<host>/$host/" -e "s/<client_id>/$id_client_id/" -e "s/<client_secret>/$id_client_secret/" > $id_data_dir/bootstrap.json

    # policy secrets
    echo -n "policy, "
    ps_secrets_dir=$magen_data/ps/data/secrets
    id_clt_secret_file policy $id_client_id $id_client_secret > $ps_secrets_dir/policy_idsvc_secrets.json

    # hwa secrets
    echo -n "hwa app"
    hwa_secrets_dir=$magen_data/hwa/data/secrets

    host_cfg_file hwa $host >  $hwa_secrets_dir/hwa_config.json
    id_clt_secret_file hwa $id_client_id $id_client_secret > $hwa_secrets_dir/hwa_idsvc_secrets.json
    echo " ...config/secrets files created"

    usvc_list=(id ks ingestion ps hwa)
    repo_list=(core ${usvc_list[@]})
    case $buildfrom in
    dockerimage)
	build_list=${usvc_list[@]}
	echo "$progname: Creating Dockerfiles for local magen docker images that pull pre-built magen service docker images from image repo ($docker_registry)"
	for module in ${build_list[@]}; do
	    tag=magen-$module
	    if [ $module = ingestion ]; then
		tag=magen-in
	    fi
	    wrapper_dockerfile $docker_registry $tag latest > $magen_data/$module/Dockerfile
	done
	;;
    source)
    bash build_from_source.sh
        ;;
    source_latest)
    bash build_from_source.sh --latest
    esac
    cat <<INSTALL_COMPLETE
${progname}: Install step complete (${magen_root_printable} created).
${progname}: NEXT STEP: "bash$ ${magen_root_printable}/onenode.sh start".
INSTALL_COMPLETE
}

#--------------------------------------------------------------------------
# ONENODE_UNINSTALL
#---------------------------------------------------------------------------
onenode_uninstall_usage()
{
    cat <<ONENODE_UNINSTALL_USAGE
Usage: $prog_base $prog_opcode

Description:
    Uninstall directory tree for one-node magen_instance.
    (Delete directory tree under ${magen_root})
    Prior to that, shut down instance (${prog_location} stop).
    [Opposite operation: "${pkg} install"]

Example:
         bash$ ${magen_root_printable}/${prog_base} ${prog_opcode}

ONENODE_UNINSTALL_USAGE

    exit $1
}

onenode_uninstall()
{
    while [ $# != 0 ] ; do
	case $1 in
	-h*)
            ${progname}_usage 0
	    ;;
	-*)
	    echo "$progname: ERROR: unrecognized option $1" >&2
            ${progname}_usage 1
	    ;;
        *)
            ${progname}_usage 1
	    ;;
	esac
	shift
    done

    if [ ! -d ${magen_data} ]; then
	echo "${progname}: ${magen_data} does not exist. No cleanup required"
	exit 0
    fi

    if [ -f ${onenode_scripts}/docker_clean.sh ]; then
	# only try shutdown if tools are still present
	${prog_location} stop
    else
	echo "$progname: $magen_root tree incomplete. Skipping \"$prog_location stop\": "
    fi
    echo "$progname: removing onenode docker images and network (but not dependent docker images)"
    ${onenode_scripts}/docker_images_remove_matching.sh -images onenode -net magen_onenode_net

    echo "$progname: removing $magen_root_printable"
    if [ "$EUID" != 0 ]; then
	cat <<EUID_WARNING
${progname}:     [WARNING: current_euid=${EUID} (non-root).
${progname}:      1. Any permission errors from removal may indicate need
${progname}:         to run ${progname} as root.
${progname}:      2. If no permission errors are reported, running ${progname}
${progname}          as non-root was not a problem]
EUID_WARNING
    fi
    rm -rf $magen_root
    cat <<UNINSTALL_COMPLETE
$progname: Uninstall step complete.
UNINSTALL_COMPLETE
}

#--------------------------------------------------------------------------
# ONENODE_START
#---------------------------------------------------------------------------
onenode_start_usage()
{
    cat <<ONENODE_START_USAGE
Usage: ${prog_base} ${prog_opcode} [--update]
        --update: update docker images (from image repo) or
                  [NOT YET IMPLEMENTED] source from git repo)
                  [Default:false]

Description:
    Start the docker containers for the one-node magen instance's services.
    Prior to that, shut down instance (${prog_location} stop).
    [Cleanup operation: "${pkg} stop"]

    If images from the docker-repo are not present, they will be downloaded.
    If images are present, use them unless --update is given. (Downloading
    images can be slow and can hang.)

Example:
         bash$ ${magen_root_printable}/${prog_base} ${prog_opcode}

ONENODE_START_USAGE

    exit $1
}

onenode_start()
{
    update=false
    while [ $# != 0 ] ; do
	case $1 in
	-h*)
            ${progname}_usage 0
	    ;;
        --update)
	    update=true
	    ;;
	-*)
	    echo "$progname: ERROR: unrecognized option $1" >&2
            ${progname}_usage 1
	    ;;
        *)
            ${progname}_usage 1
	    ;;
	esac
	shift
    done
    ${onenode_scripts}/docker_clean.sh

    if [ -d ${magen_source} ]; then
        ${onenode_scripts}/docker_compose_runall.sh --path=docker-compose-runall-source.yml --network=${docker_network}
        exit 1
    fi

    cd ${magen_root}
    echo "$progname: Starting docker containers for magen services"
    ${onenode_scripts}/docker_compose_check.sh || exit 1
    if [ ${update} = true ]; then
	docker_image_update
    fi
    ${prog_location} stop
    ${onenode_scripts}/docker_compose_runall.sh --path=docker-compose-runall.yml --network=${docker_network} --account=${docker_registry}
    status=$?
    if [ ${status} != 0 ]; then
	echo "$progname: ERROR: docker_compose_runall failed ($status)" >&2
	exit ${status}
    fi
    docker ps
    hwa_secrets_dir=${magen_data}/hwa/data/secrets
    host=$(grep hostname ${hwa_secrets_dir}/hwa_config.json |
	       sed -e 's/\"//g' -e 's/.*hostname: //' )
    cat <<START_COMPLETE
${progname}: "onenode start" step complete.
${progname}: NEXT STEP: Browse to "https://$host:5002" to talk to hwa app.
${progname}:            Bypass browser warnings about unverifiable
${progname}:            (i.e. self-signed) certificates.
START_COMPLETE
}

#--------------------------------------------------------------------------
# ONENODE_STOP
#---------------------------------------------------------------------------
onenode_stop_usage()
{
    cat <<ONENODE_STOP_USAGE
Usage: $prog_base $prog_opcode

Description:
    Shut down the docker containers for the one-node magen instance's services.
    [Opposite operation: "$pkg start"]

Example:
         bash$ $magen_root_printable/$prog_base $prog_opcode

ONENODE_STOP_USAGE

    exit $1
}

onenode_stop()
{
    while [ $# != 0 ] ; do
	case $1 in
	-h*)
            ${progname}_usage 0
	    ;;
	-*)
	    echo "$progname: ERROR: unrecognized option $1" >&2
            ${progname}_usage 1
	    ;;
        *)
            ${progname}_usage 1
	    ;;
	esac
	shift
    done

    if [ ! -d ${magen_data} ]; then
	echo "$progname: FATAL: $magen_data does not exist (run \"$prog_base install\"(?)) " >&2
	exit 1
    fi
    cd ${magen_root}
    echo "$progname: Shutting down docker containers for magen services"
    if [ -d ${magen_source} ]; then
        docker-compose -f docker-compose-runall-source.yml kill
        exit 1
    fi
    docker-compose -f docker-compose-runall.yml kill
    ${onenode_scripts}/docker_clean.sh

}

#
# usage helper for all operations
#
onenode_usage()
{
    cat <<ONENODE_USAGE
Usage: $prog_location [-h] [-d] <utility> [utility-options]

Description:
    Interface to various $pkg utilities.
    [one-node magen instance bring-up step 1: "$prog_location install -h"]

${pkg} utilities supported:
ONENODE_USAGE

    egrep ${pkg}_.*_usage $prog_location | egrep -v '(egrep|sed) ' |
	sed -e "s/${pkg}_\(.*\)_usage()/	\1/" |
	sort | pkg_subcodes_filter
    exit $1
}

####
#### MAIN()
####
pkg=onenode
pkg_dist=onenode_install.sh
prog_opcode=

progname=
prog_location=$0
prog_base=$(basename ${prog_location})
prog_dir=$(dirname ${prog_location})

PATH=$onenode_scripts:$PATH

LOGNAME=${LOGNAME:-}
USER=${USER:-$LOGNAME}
export USER

ECHO=
EVAL=_u_eval

TRUE="$(which true)"
if [ "$TRUE" = "" ]; then
    echo "$progname: ERROR: Unable to find \"true\"" >&2
    exit 1
fi

while [ $# != 0 ] ; do
    case $1 in
    -*)
	main_opt_process $pkg $*
	;;
    *)
	prog_opcode=$1
	progname=${pkg}_$1
	filtered_cmd=$(echo $1 | pkg_subcodes_filter)
        if [ -z "$filtered_cmd" ]; then
            if [ $prog_base = $pkg_dist ]; then
	        echo "$progname: FATAL: must run $1 from installed package"
	    fi
	    ${pkg}_usage 1
	fi
	shift
	break
	;;
    esac
    shift
done

if [ "$progname" = "" ]; then
    ${pkg}_usage 1
fi

$progname ${1+"$@"}
