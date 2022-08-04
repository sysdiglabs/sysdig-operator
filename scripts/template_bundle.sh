## Replace the operator image SHA and version
#!/bin/sh

usage() {
  echo "Usage: $0 -v <version> -i <operator_sha> [-t <template_path>] [-d <target_dir>]"
  exit 1
}

set -e

TEMPLATE_PATH=../rh-bundles/sysdig-certified/template
TARGET_DIR=../rh-bundles/sysdig-certified

while getopts ":t:d:i:v:" opt; do
  case "${opt}" in
    v)
      VERSION=${OPTARG}
      ;;
    i)
      SHA=${OPTARG}
      ;;
    t)
      TEMPLATE_PATH=${OPTARG}
      ;;
    d)
      TARGET_DIR=${OPTARG}
      ;;
    *)
      usage
      ;;
  esac
done
shift $((OPTIND-1))

if [[ -z "${VERSION}" || -z "${SHA}" ]]; then
  usage
fi

TARGET_PATH=${TARGET_DIR}/v${VERSION}
if [[ -d "$TARGET_PATH" ]]; then
  echo "Target path for new bundle $TARGET_PATH already exists."
  exit 1
fi

cp -r ${TEMPLATE_PATH} ${TARGET_PATH}
find ${TARGET_PATH} -type f -exec sed -i 's/SYSDIG_OPERATOR_SHA/'${SHA}'/g' {} \;
find ${TARGET_PATH} -type f -exec sed -i 's/SYSDIG_OPERATOR_VERSION/'${VERSION}'/g' {} \;
