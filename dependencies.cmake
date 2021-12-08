function(install_dependency git_repo)

    execute_process(COMMAND basename ${git_repo}
            OUTPUT_VARIABLE repo_name )

    string(REPLACE "\n" "" repo_name ${repo_name})

    message(STATUS "\nConfiguring dependency ${repo_name}")

    set(dependencies_folder "${CMAKE_CURRENT_SOURCE_DIR}/dependencies")

    execute_process(COMMAND mkdir ${dependencies_folder} -p)

    set(dependency_folder "${dependencies_folder}/${repo_name}")

    execute_process(COMMAND bash -c "[ -d ${repo_name} ]"
            WORKING_DIRECTORY ${dependencies_folder}
            RESULT_VARIABLE  folder_exists)

    if (${folder_exists} EQUAL 0)
        execute_process(COMMAND git pull
                WORKING_DIRECTORY ${dependency_folder})
    else()
        execute_process(COMMAND git -C ${dependencies_folder} clone ${git_repo})
    endif()

    execute_process(COMMAND bash -c "[ -f include ]"
            WORKING_DIRECTORY ${dependency_folder}
            RESULT_VARIABLE  include_folder_exists)

    if (${include_folder_exists} EQUAL 0)
        include_directories(${dependency_folder}/include)
    endif()

    set(destination_folder ${CMAKE_CURRENT_BINARY_DIR}/${repo_name})

    execute_process(COMMAND mkdir ${repo_name} -p
            WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR} )

    execute_process(COMMAND cmake ${dependency_folder}
            WORKING_DIRECTORY ${destination_folder})

    execute_process(COMMAND make -j
            WORKING_DIRECTORY ${destination_folder})

    set (repo_targets "${destination_folder}/${repo_name}Targets.cmake")

    set (variadic_args ${ARGN})
    list(LENGTH variadic_args variadic_count)
    if (${variadic_count} GREATER 0)
        list(GET variadic_args 0 package_name)
        set (${package_name}_DIR ${destination_folder})
        message("CONFIGURING PACKAGE ${package_name}")
        find_package (${package_name} REQUIRED)
    endif ()

endfunction()