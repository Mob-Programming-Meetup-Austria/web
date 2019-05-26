#!/bin/bash
set -e

if [ ! -f /.dockerenv ]; then
  echo 'FAILED: test_wrapper.sh is being executed outside of docker-container.'
  exit 1
fi

# Fakes/Mocks save to Dir.tmpdir
rm -rf /tmp/cyber-dojo

modules=(
  lib
  app_helpers
  app_lib
  app_models
  app_services
  app_controllers
)

for module in ${modules[*]}
do
  if [ "${module}" == "${1}" ]; then
    modules=("${1}")
    shift
    break
  fi
done

for module in ${modules[*]}
do
    echo
    echo "======${module}======"
    # clear out old coverage stats
    coverage_dir=/tmp/cyber-dojo/coverage/${module}
    mkdir -p "${coverage_dir}"
    rm -rf "${coverage_dir}/.resultset.json"
    test_log="${coverage_dir}/test.log"
    export COVERAGE_DIR=${coverage_dir}

    # set defaults for externals
    export CYBER_DOJO_CUSTOM_CLASS=CustomService
    export CYBER_DOJO_EXERCISES_CLASS=ExercisesService
    export CYBER_DOJO_LANGUAGES_CLASS=LanguagesService
    export CYBER_DOJO_SAVER_CLASS=SaverService
    export CYBER_DOJO_RUNNER_CLASS=RunnerStub
    export CYBER_DOJO_DIFFER_CLASS=DifferService
    export CYBER_DOJO_ZIPPER_CLASS=ZipperService
    export CYBER_DOJO_MAPPER_CLASS=MapperService
    export CYBER_DOJO_HTTP_CLASS=Http

    # run-the-tests!
    cd "${module}"
    testFiles=(*_test.rb)
    ruby -e "%w( ${testFiles[*]} ).shuffle.map{ |file| require './'+file }" \
      "${module}" "$@" 2>&1 | tee "${test_log}"
    ruby ../print_coverage_percent.rb \
      "${module}"           | tee -a "${test_log}"
    cd ..
done

ruby ./print_coverage_summary.rb ${modules[*]}
exit $?
