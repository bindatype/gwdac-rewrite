module cm12_legacy_context
    use cm12_kernel, only: &
        cm12_dataset, cm12_ok, load_cm12_dataset
    use cm12_solution_kernel, only: &
        cm12_solution, load_cm12_solution
    implicit none
    private

    character(len=64), parameter :: canonical_solution_sha256 = &
        'dbcaae30bbf44aca6e5482fc2b10b81cb6e1033cf41061bc089d5f6a85576522'

    type(cm12_dataset), save, target :: dataset
    type(cm12_solution), save, target :: solution
    logical, save :: initialized = .false.

    public :: legacy_cm12_objects
    public :: legacy_cm12_solution

contains

    subroutine legacy_cm12_objects(dataset_result, solution_result)
        type(cm12_dataset), pointer, intent(out) :: dataset_result
        type(cm12_solution), pointer, intent(out) :: solution_result

        call initialize_context()
        dataset_result => dataset
        solution_result => solution
    end subroutine legacy_cm12_objects

    subroutine legacy_cm12_solution(solution_result)
        type(cm12_solution), pointer, intent(out) :: solution_result

        call initialize_context()
        solution_result => solution
    end subroutine legacy_cm12_solution

    subroutine initialize_context()
        character(len=1024) :: dataset_root
        character(len=1024) :: solution_path
        character(len=512) :: message
        character(len=64) :: solution_sha256
        character(len=4) :: solution_id
        integer :: status
        integer :: length

        if (initialized) return

        dataset_root = ''
        call get_environment_variable( &
            'CM12_KCM_ROOT', dataset_root, length=length, status=status)
        if (status /= 0 .or. length == 0) dataset_root = 'KCM'

        solution_path = ''
        call get_environment_variable( &
            'CM12_SOLUTION_FILE', solution_path, &
            length=length, status=status)
        if (status /= 0 .or. length == 0) then
            solution_path = '../sdat/prsol.dat'
        end if

        solution_sha256 = ''
        call get_environment_variable( &
            'CM12_SOLUTION_SHA256', solution_sha256, &
            length=length, status=status)
        if (status /= 0 .or. length == 0) then
            solution_sha256 = canonical_solution_sha256
        end if

        solution_id = ''
        call get_environment_variable( &
            'CM12_SOLUTION_ID', solution_id, length=length, status=status)
        if (status /= 0 .or. length == 0) solution_id = 'CM12'

        call load_cm12_dataset( &
            trim(dataset_root), dataset, status, message)
        if (status /= cm12_ok) then
            write(*, '(a)') 'CM12 dataset load failed: ' // trim(message)
            error stop 2
        end if
        call load_cm12_solution( &
            trim(solution_path), trim(solution_sha256), solution_id, &
            solution, status, message)
        if (status /= cm12_ok) then
            write(*, '(a)') 'CM12 solution load failed: ' // trim(message)
            error stop 3
        end if
        initialized = .true.
    end subroutine initialize_context

end module cm12_legacy_context
