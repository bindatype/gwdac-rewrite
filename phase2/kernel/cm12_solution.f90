module cm12_solution_kernel
    use, intrinsic :: iso_fortran_env, only: int8, int64, real32
    use, intrinsic :: ieee_arithmetic, only: ieee_is_finite
    use cm12_kernel, only: &
        cm12_invalid_argument, cm12_io_error, cm12_ok
    implicit none
    private

    integer, parameter, public :: cm12_hash_mismatch = 5
    integer, parameter, public :: cm12_invalid_solution = 6
    integer, parameter, public :: cm12_domain_error = 7

    integer, parameter :: family_count = 6
    integer, parameter :: branch_count = 2
    integer, parameter :: partial_wave_count = 6
    integer, parameter :: parameter_count = 25
    integer, parameter :: amplitude_count = 4
    integer, parameter :: explicit_cm12_records = 54

    real(real32), parameter :: proton_mass = 938.256_real32
    real(real32), parameter :: neutron_mass = 939.65_real32
    real(real32), parameter :: neutral_pion_mass = 135.04_real32
    real(real32), parameter :: charged_pion_mass = 139.65_real32

    type, public :: cm12_background_constants
        real(real32) :: pion_coupling = 13.75_real32
        real(real32) :: omega_vector = 22.5_real32
        real(real32) :: omega_tensor = 0.0_real32
        real(real32) :: omega_model = 27.0_real32
        real(real32) :: rho_vector = 0.0_real32
        real(real32) :: rho_tensor = 0.0_real32
        integer :: reaction_control = 0
        real(real32) :: cutoff_mev = 0.0_real32
    end type cm12_background_constants

    type, public :: cm12_solution
        private
        logical :: loaded = .false.
        character(len=4) :: identifier = ''
        character(len=72) :: title = ''
        character(len=1024) :: source_path = ''
        character(len=64) :: source_sha256 = ''
        integer :: form_selector( &
            family_count, branch_count, partial_wave_count) = 0
        real(real32) :: parameters( &
            parameter_count, family_count, branch_count, &
            partial_wave_count) = 0.0_real32
        logical :: record_seen( &
            family_count, branch_count, partial_wave_count) = .false.
        real(real32) :: isospin(6, 2) = 0.0_real32
        real(real32) :: helicity( &
            amplitude_count, amplitude_count, partial_wave_count) = &
            0.0_real32
        integer :: max_partial_wave = partial_wave_count
        integer :: explicit_records = 0
        type(cm12_background_constants) :: background
    end type cm12_solution

    type, public :: cm12_kinematics
        real(real32) :: photon_lab_energy_mev = 0.0_real32
        real(real32) :: w_cm_mev = 0.0_real32
        real(real32) :: photon_cm_momentum_mev = 0.0_real32
        real(real32) :: meson_cm_momentum_mev = 0.0_real32
        real(real32) :: final_meson_energy_mev = 0.0_real32
        real(real32) :: threshold_lab_energy_mev = 0.0_real32
    end type cm12_kinematics

    public :: load_cm12_solution
    public :: cm12_solution_is_loaded
    public :: cm12_solution_summary
    public :: cm12_solution_multipole
    public :: cm12_solution_background
    public :: cm12_calculate_kinematics
    public :: cm12_accumulate_multipole
    public :: cm12_evaluate_dsg

contains

    subroutine load_cm12_solution( &
        path, expected_sha256, identifier, solution, status, message)
        character(len=*), intent(in) :: path
        character(len=*), intent(in) :: expected_sha256
        character(len=*), intent(in) :: identifier
        type(cm12_solution), intent(out) :: solution
        integer, intent(out) :: status
        character(len=*), intent(out) :: message

        character(len=64) :: actual_sha256
        character(len=64) :: normalized_expected

        solution = cm12_solution()
        status = cm12_ok
        message = ''

        if (len_trim(path) == 0) then
            call set_error( &
                cm12_invalid_argument, 'CM12 solution path is empty', &
                status, message)
            return
        end if
        if (len_trim(identifier) /= 4) then
            call set_error( &
                cm12_invalid_argument, &
                'CM12 solution identifier must contain four characters', &
                status, message)
            return
        end if
        if (.not. is_sha256(expected_sha256)) then
            call set_error( &
                cm12_invalid_argument, &
                'expected CM12 solution SHA-256 is invalid', &
                status, message)
            return
        end if

        call sha256_file(path, actual_sha256, status, message)
        if (status /= cm12_ok) return
        normalized_expected = lowercase(expected_sha256(1:64))
        if (actual_sha256 /= normalized_expected) then
            call set_error( &
                cm12_hash_mismatch, &
                'CM12 solution SHA-256 does not match expected provenance', &
                status, message)
            return
        end if

        call parse_solution_record( &
            path, identifier, solution, status, message)
        if (status /= cm12_ok) return

        solution%source_path = trim(path)
        solution%source_sha256 = actual_sha256
        solution%loaded = .true.
    end subroutine load_cm12_solution

    pure logical function cm12_solution_is_loaded(solution)
        type(cm12_solution), intent(in) :: solution

        cm12_solution_is_loaded = solution%loaded
    end function cm12_solution_is_loaded

    pure subroutine cm12_solution_summary( &
        solution, identifier, title, source_path, source_sha256, &
        explicit_records, max_partial_wave)
        type(cm12_solution), intent(in) :: solution
        character(len=*), intent(out) :: identifier
        character(len=*), intent(out) :: title
        character(len=*), intent(out) :: source_path
        character(len=*), intent(out) :: source_sha256
        integer, intent(out) :: explicit_records
        integer, intent(out) :: max_partial_wave

        identifier = solution%identifier
        title = trim(solution%title)
        source_path = trim(solution%source_path)
        source_sha256 = solution%source_sha256
        explicit_records = solution%explicit_records
        max_partial_wave = solution%max_partial_wave
    end subroutine cm12_solution_summary

    pure subroutine cm12_solution_multipole( &
        solution, family, j_branch, orbital_l, form_selector, &
        parameters, status, message)
        type(cm12_solution), intent(in) :: solution
        integer, intent(in) :: family
        integer, intent(in) :: j_branch
        integer, intent(in) :: orbital_l
        integer, intent(out) :: form_selector
        real(real32), intent(out) :: parameters(parameter_count)
        integer, intent(out) :: status
        character(len=*), intent(out) :: message

        form_selector = 0
        parameters = 0.0_real32
        if (.not. solution%loaded) then
            call set_error( &
                cm12_invalid_solution, 'CM12 solution is not loaded', &
                status, message)
            return
        end if
        if ( &
            family < 1 .or. family > family_count .or. &
            j_branch < 1 .or. j_branch > branch_count .or. &
            orbital_l < 0 .or. orbital_l >= partial_wave_count) then
            call set_error( &
                cm12_invalid_argument, 'invalid CM12 multipole identity', &
                status, message)
            return
        end if

        form_selector = &
            solution%form_selector(family, j_branch, orbital_l + 1)
        parameters = &
            solution%parameters(:, family, j_branch, orbital_l + 1)
        status = cm12_ok
        message = ''
    end subroutine cm12_solution_multipole

    pure subroutine cm12_solution_background( &
        solution, background, status, message)
        type(cm12_solution), intent(in) :: solution
        type(cm12_background_constants), intent(out) :: background
        integer, intent(out) :: status
        character(len=*), intent(out) :: message

        background = cm12_background_constants()
        if (.not. solution%loaded) then
            call set_error( &
                cm12_invalid_solution, 'CM12 solution is not loaded', &
                status, message)
            return
        end if
        background = solution%background
        status = cm12_ok
        message = ''
    end subroutine cm12_solution_background

    pure subroutine cm12_calculate_kinematics( &
        reaction, photon_lab_energy_mev, result, status, message)
        integer, intent(in) :: reaction
        real(real32), intent(in) :: photon_lab_energy_mev
        type(cm12_kinematics), intent(out) :: result
        integer, intent(out) :: status
        character(len=*), intent(out) :: message

        real(real32) :: target_mass
        real(real32) :: recoil_mass
        real(real32) :: pion_mass
        real(real32) :: s
        real(real32) :: threshold_s
        real(real32) :: shared_pion_s
        real(real32) :: stretch_s
        real(real32) :: stretch

        result = cm12_kinematics()
        if (reaction < 1 .or. reaction > 4) then
            status = cm12_invalid_argument
            message = 'pion reaction must be in 1..4'
            return
        end if
        if ( &
            .not. ieee_is_finite(photon_lab_energy_mev) .or. &
            photon_lab_energy_mev <= 0.0_real32) then
            status = cm12_invalid_argument
            message = 'photon laboratory energy must be finite and positive'
            return
        end if

        target_mass = proton_mass
        if (reaction > 2) target_mass = neutron_mass
        recoil_mass = proton_mass
        if (reaction == 2 .or. reaction == 4) recoil_mass = neutron_mass
        pion_mass = neutral_pion_mass
        if (reaction == 2 .or. reaction == 3) pion_mass = charged_pion_mass

        result%photon_lab_energy_mev = photon_lab_energy_mev
        result%threshold_lab_energy_mev = &
            ((recoil_mass + pion_mass) ** 2 - target_mass ** 2) / &
            (2.0_real32 * target_mass)

        ! cmmwp/ysKCM use the proton convention for Wcm for every channel.
        result%w_cm_mev = sqrt( &
            proton_mass ** 2 + &
            2.0_real32 * proton_mass * photon_lab_energy_mev)
        result%photon_cm_momentum_mev = &
            photon_lab_energy_mev / sqrt( &
                1.0_real32 + &
                2.0_real32 * photon_lab_energy_mev / target_mass)

        s = target_mass * ( &
            target_mass + 2.0_real32 * photon_lab_energy_mev)
        threshold_s = (pion_mass + recoil_mass) ** 2
        if (s <= threshold_s) then
            status = cm12_ok
            message = ''
            return
        end if

        result%meson_cm_momentum_mev = sqrt( &
            (s - threshold_s) * &
            (s - (pion_mass - recoil_mass) ** 2) / &
            (4.0_real32 * s))

        shared_pion_s = (proton_mass + charged_pion_mass) ** 2
        result%final_meson_energy_mev = &
            (s - shared_pion_s) / (2.0_real32 * proton_mass)
        if (result%final_meson_energy_mev < 10.0_real32) then
            stretch_s = shared_pion_s + 20.0_real32 * proton_mass
            stretch = (s - threshold_s) / (stretch_s - threshold_s)
            result%final_meson_energy_mev = 10.0_real32 * stretch ** 2
        end if

        status = cm12_ok
        message = ''
    end subroutine cm12_calculate_kinematics

    pure subroutine cm12_accumulate_multipole( &
        solution, reaction, angle_cm_deg, family, j_branch, orbital_l, &
        multipole, initial_amplitudes, amplitudes, status, message)
        type(cm12_solution), intent(in) :: solution
        integer, intent(in) :: reaction
        real(real32), intent(in) :: angle_cm_deg
        integer, intent(in) :: family
        integer, intent(in) :: j_branch
        integer, intent(in) :: orbital_l
        complex(real32), intent(in) :: multipole
        complex(real32), intent(in) :: initial_amplitudes(amplitude_count)
        complex(real32), intent(out) :: amplitudes(amplitude_count)
        integer, intent(out) :: status
        character(len=*), intent(out) :: message

        real(real32) :: basis(amplitude_count, partial_wave_count)
        real(real32) :: coefficient
        integer :: electric_magnetic
        integer :: isospin_column
        integer :: helicity_column
        integer :: basis_index
        integer :: k

        amplitudes = initial_amplitudes
        if (.not. solution%loaded) then
            status = cm12_invalid_solution
            message = 'CM12 solution is not loaded'
            return
        end if
        if (reaction < 1 .or. reaction > 4) then
            status = cm12_invalid_argument
            message = 'pion reaction must be in 1..4'
            return
        end if
        if ( &
            .not. ieee_is_finite(angle_cm_deg) .or. &
            angle_cm_deg < 0.0_real32 .or. angle_cm_deg > 180.0_real32) then
            status = cm12_invalid_argument
            message = 'center-of-mass angle must be in 0..180 degrees'
            return
        end if
        if ( &
            family < 1 .or. family > family_count .or. &
            j_branch < 1 .or. j_branch > branch_count .or. &
            orbital_l < 0 .or. orbital_l >= partial_wave_count) then
            status = cm12_invalid_argument
            message = 'invalid CM12 multipole identity'
            return
        end if
        if ( &
            .not. ieee_is_finite(real(multipole, kind=real32)) .or. &
            .not. ieee_is_finite(aimag(multipole))) then
            status = cm12_invalid_argument
            message = 'multipole must be finite'
            return
        end if
        if (reaction < 3 .and. family > 4) then
            status = cm12_ok
            message = ''
            return
        end if
        if (reaction > 2 .and. (family == 3 .or. family == 4)) then
            status = cm12_ok
            message = ''
            return
        end if
        if ( &
            real(multipole, kind=real32) == 0.0_real32 .and. &
            aimag(multipole) == 0.0_real32) then
            status = cm12_ok
            message = ''
            return
        end if

        electric_magnetic = family / 2
        electric_magnetic = 1 - family + 2 * electric_magnetic
        isospin_column = 1
        if (family < 3) isospin_column = 2
        basis_index = orbital_l - 1 + j_branch
        helicity_column = 2 * j_branch + electric_magnetic - 1
        if (basis_index < 1) then
            status = cm12_ok
            message = ''
            return
        end if

        call calculate_helicity_basis(angle_cm_deg, basis)
        coefficient = solution%isospin(reaction, isospin_column)
        do k = 1, amplitude_count
            amplitudes(k) = amplitudes(k) + &
                coefficient * &
                solution%helicity(k, helicity_column, basis_index) * &
                basis(k, basis_index) * multipole
        end do
        status = cm12_ok
        message = ''
    end subroutine cm12_accumulate_multipole

    pure subroutine cm12_evaluate_dsg( &
        photon_lab_energy_mev, threshold_lab_energy_mev, &
        photon_cm_momentum_mev, meson_cm_momentum_mev, amplitudes, &
        dsg, status, message)
        real(real32), intent(in) :: photon_lab_energy_mev
        real(real32), intent(in) :: threshold_lab_energy_mev
        real(real32), intent(in) :: photon_cm_momentum_mev
        real(real32), intent(in) :: meson_cm_momentum_mev
        complex(real32), intent(in) :: amplitudes(amplitude_count)
        real(real32), intent(out) :: dsg
        integer, intent(out) :: status
        character(len=*), intent(out) :: message

        real(real32) :: amplitude_sum
        integer :: k

        dsg = 0.0_real32
        if ( &
            .not. ieee_is_finite(photon_lab_energy_mev) .or. &
            .not. ieee_is_finite(threshold_lab_energy_mev) .or. &
            .not. ieee_is_finite(photon_cm_momentum_mev) .or. &
            .not. ieee_is_finite(meson_cm_momentum_mev)) then
            status = cm12_invalid_argument
            message = 'DSG kinematics must be finite'
            return
        end if
        do k = 1, amplitude_count
            if ( &
                .not. ieee_is_finite(real(amplitudes(k), kind=real32)) .or. &
                .not. ieee_is_finite(aimag(amplitudes(k)))) then
                status = cm12_invalid_argument
                message = 'DSG amplitudes must be finite'
                return
            end if
        end do
        if (photon_lab_energy_mev <= threshold_lab_energy_mev) then
            status = cm12_domain_error
            message = 'DSG request is at or below the reaction threshold'
            return
        end if
        if (photon_cm_momentum_mev <= 0.0_real32) then
            status = cm12_domain_error
            message = 'photon center-of-mass momentum must be positive'
            return
        end if

        amplitude_sum = 0.0_real32
        do k = 1, amplitude_count
            amplitude_sum = amplitude_sum + &
                real(amplitudes(k), kind=real32) ** 2 + &
                aimag(amplitudes(k)) ** 2
        end do
        if (amplitude_sum <= 0.0_real32) then
            status = cm12_ok
            message = ''
            return
        end if

        dsg = &
            meson_cm_momentum_mev / photon_cm_momentum_mev * &
            amplitude_sum / 200.0_real32
        status = cm12_ok
        message = ''
    end subroutine cm12_evaluate_dsg

    subroutine parse_solution_record(path, identifier, solution, status, message)
        character(len=*), intent(in) :: path
        character(len=*), intent(in) :: identifier
        type(cm12_solution), intent(inout) :: solution
        integer, intent(out) :: status
        character(len=*), intent(out) :: message

        character(len=4096) :: record
        character(len=1024) :: line
        character(len=1024) :: title_line
        character(len=1024) :: adjusted
        integer :: unit
        integer :: ios
        logical :: found
        logical :: coupling_seen

        call initialize_solution_defaults(solution)
        record = ''
        found = .false.
        coupling_seen = .false.
        open( &
            newunit=unit, file=trim(path), status='old', action='read', &
            form='formatted', iostat=ios)
        if (ios /= 0) then
            call set_error( &
                cm12_io_error, 'cannot open CM12 solution file', &
                status, message)
            return
        end if

        do
            read(unit, '(a)', iostat=ios) line
            if (ios /= 0) exit
            if (len_trim(line) == 0) cycle
            if (line(1:1) /= 'V') cycle
            read(unit, '(a)', iostat=ios) title_line
            if (ios /= 0) exit
            adjusted = adjustl(title_line)
            if (adjusted(1:4) == identifier(1:4)) then
                found = .true.
                solution%identifier = identifier(1:4)
                solution%title = title_line(1:min(72, len(title_line)))
                exit
            end if
        end do
        if (.not. found) then
            close(unit)
            call set_error( &
                cm12_invalid_solution, &
                'requested solution identifier is absent from source file', &
                status, message)
            return
        end if

        do
            read(unit, '(a)', iostat=ios) line
            if (ios /= 0) then
                close(unit)
                call set_error( &
                    cm12_invalid_solution, &
                    'CM12 solution record is truncated', status, message)
                return
            end if
            if (len_trim(line) == 0) cycle
            if (line(1:1) == 'Q') then
                if (len_trim(record) /= 0) then
                    close(unit)
                    call set_error( &
                        cm12_invalid_solution, &
                        'unterminated CM12 solution parameter record', &
                        status, message)
                    return
                end if
                exit
            end if
            if (len_trim(record) + len_trim(line) + 1 > len(record)) then
                close(unit)
                call set_error( &
                    cm12_invalid_solution, &
                    'CM12 solution parameter record is too long', &
                    status, message)
                return
            end if
            record = trim(record) // ' ' // trim(line)
            if (index(record, 'ZQZ') == 0) cycle
            call consume_solution_record( &
                record, solution, coupling_seen, status, message)
            if (status /= cm12_ok) then
                close(unit)
                return
            end if
            record = ''
        end do
        close(unit)

        if (.not. coupling_seen) then
            call set_error( &
                cm12_invalid_solution, &
                'CM12 solution has no background coupling record', &
                status, message)
            return
        end if
        if (solution%explicit_records /= explicit_cm12_records) then
            call set_error( &
                cm12_invalid_solution, &
                'CM12 solution must contain exactly 54 multipole records', &
                status, message)
            return
        end if

        call initialize_fixed_coefficients(solution)
        status = cm12_ok
        message = ''
    end subroutine parse_solution_record

    subroutine initialize_solution_defaults(solution)
        type(cm12_solution), intent(inout) :: solution

        integer :: family
        integer :: branch
        integer :: orbital_l

        solution%form_selector = 3
        solution%parameters = 0.0_real32
        solution%record_seen = .false.
        solution%explicit_records = 0
        do orbital_l = 0, partial_wave_count - 1
            do branch = 1, branch_count
                do family = 1, family_count
                    if (orbital_l == 0 .and. branch == 1) then
                        solution%form_selector( &
                            family, branch, orbital_l + 1) = 0
                    end if
                    if (orbital_l == 0 .and. mod(family, 2) == 0) then
                        solution%form_selector( &
                            family, branch, orbital_l + 1) = 0
                    end if
                    if ( &
                        orbital_l == 1 .and. branch == 1 .and. &
                        mod(family, 2) == 1) then
                        solution%form_selector( &
                            family, branch, orbital_l + 1) = 0
                    end if
                end do
            end do
        end do
    end subroutine initialize_solution_defaults

    subroutine consume_solution_record( &
        record, solution, coupling_seen, status, message)
        character(len=*), intent(in) :: record
        type(cm12_solution), intent(inout) :: solution
        logical, intent(inout) :: coupling_seen
        integer, intent(out) :: status
        character(len=*), intent(out) :: message

        real(real32) :: values(27)
        integer :: value_count
        integer :: code
        integer :: family
        integer :: branch
        integer :: orbital_l
        integer :: form_selector

        call parse_numeric_tokens( &
            record, values, value_count, status, message)
        if (status /= cm12_ok) return
        if (value_count < 1) then
            call set_error( &
                cm12_invalid_solution, 'empty CM12 solution record', &
                status, message)
            return
        end if

        code = nint(values(1))
        if (code == 1) then
            if (coupling_seen .or. value_count /= 7) then
                call set_error( &
                    cm12_invalid_solution, &
                    'invalid CM12 background coupling record', &
                    status, message)
                return
            end if
            solution%background%pion_coupling = values(2)
            solution%background%omega_vector = values(3)
            solution%background%omega_tensor = values(4)
            solution%background%rho_vector = values(5)
            solution%background%rho_tensor = values(6)
            solution%background%cutoff_mev = values(7)
            solution%background%omega_model = 27.0_real32
            solution%background%reaction_control = 0
            coupling_seen = .true.
            status = cm12_ok
            message = ''
            return
        end if

        if (value_count < 2 .or. value_count > 27) then
            call set_error( &
                cm12_invalid_solution, &
                'invalid CM12 multipole parameter record width', &
                status, message)
            return
        end if
        family = code / 100
        branch = mod(code, 100) / 10
        orbital_l = mod(code, 10)
        form_selector = nint(values(2))
        if ( &
            family < 1 .or. family > family_count .or. &
            branch < 1 .or. branch > branch_count .or. &
            orbital_l < 0 .or. orbital_l >= partial_wave_count) then
            call set_error( &
                cm12_invalid_solution, &
                'invalid CM12 multipole code in solution record', &
                status, message)
            return
        end if
        if (solution%record_seen(family, branch, orbital_l + 1)) then
            call set_error( &
                cm12_invalid_solution, &
                'duplicate CM12 multipole solution record', status, message)
            return
        end if

        solution%form_selector(family, branch, orbital_l + 1) = form_selector
        solution%record_seen(family, branch, orbital_l + 1) = .true.
        solution%parameters(:, family, branch, orbital_l + 1) = 0.0_real32
        if (value_count > 2) then
            solution%parameters( &
                1:value_count - 2, family, branch, orbital_l + 1) = &
                values(3:value_count)
        end if
        solution%explicit_records = solution%explicit_records + 1
        status = cm12_ok
        message = ''
    end subroutine consume_solution_record

    subroutine parse_numeric_tokens(record, values, count, status, message)
        character(len=*), intent(in) :: record
        real(real32), intent(out) :: values(:)
        integer, intent(out) :: count
        integer, intent(out) :: status
        character(len=*), intent(out) :: message

        character(len=64) :: token
        integer :: cursor
        integer :: finish
        integer :: ios
        integer :: length

        values = 0.0_real32
        count = 0
        cursor = 1
        length = len_trim(record)
        do while (cursor <= length)
            do while (cursor <= length .and. record(cursor:cursor) == ' ')
                cursor = cursor + 1
            end do
            if (cursor > length) exit
            finish = cursor
            do while (finish <= length .and. record(finish:finish) /= ' ')
                finish = finish + 1
            end do
            if (finish - cursor > len(token)) then
                call set_error( &
                    cm12_invalid_solution, &
                    'CM12 solution token is too long', status, message)
                return
            end if
            token = ''
            token = record(cursor:finish - 1)
            if (token(1:3) == 'ZQZ') exit
            if (count == size(values)) then
                call set_error( &
                    cm12_invalid_solution, &
                    'too many values in CM12 solution record', &
                    status, message)
                return
            end if
            read(token, *, iostat=ios) values(count + 1)
            if (ios /= 0) then
                call set_error( &
                    cm12_invalid_solution, &
                    'non-numeric value in CM12 solution record', &
                    status, message)
                return
            end if
            count = count + 1
            cursor = finish + 1
        end do
        status = cm12_ok
        message = ''
    end subroutine parse_numeric_tokens

    subroutine initialize_fixed_coefficients(solution)
        type(cm12_solution), intent(inout) :: solution

        real(real32) :: sqrt_two
        real(real32) :: orbital
        integer :: l

        sqrt_two = sqrt(2.0_real32)
        solution%isospin = 0.0_real32
        solution%isospin(1, :) = [ 1.0_real32, 2.0_real32 / 3.0_real32 ]
        solution%isospin(2, :) = [ sqrt_two, -sqrt_two / 3.0_real32 ]
        solution%isospin(3, :) = [ sqrt_two, sqrt_two / 3.0_real32 ]
        solution%isospin(4, :) = [ -1.0_real32, 2.0_real32 / 3.0_real32 ]

        do l = 1, partial_wave_count
            orbital = real(l - 1, real32)
            solution%helicity(1, :, l) = [ &
                -1.0_real32, -1.0_real32, 1.0_real32, -1.0_real32 ]
            solution%helicity(2, :, l) = [ &
                orbital, -orbital - 2.0_real32, &
                orbital + 2.0_real32, orbital ]
            solution%helicity(3, :, l) = [ &
                1.0_real32, 1.0_real32, 1.0_real32, -1.0_real32 ]
            solution%helicity(4, :, l) = [ &
                -orbital, orbital + 2.0_real32, &
                orbital + 2.0_real32, orbital ]
        end do
    end subroutine initialize_fixed_coefficients

    pure subroutine calculate_helicity_basis(angle_cm_deg, basis)
        real(real32), intent(in) :: angle_cm_deg
        real(real32), intent(out) :: basis( &
            amplitude_count, partial_wave_count)

        real(real32) :: radians
        real(real32) :: sine
        real(real32) :: cosine
        real(real32) :: half_sine
        real(real32) :: half_cosine
        real(real32) :: previous_legendre
        real(real32) :: legendre
        real(real32) :: first_derivative
        real(real32) :: second_derivative
        real(real32) :: orbital
        real(real32) :: temporary
        integer :: l

        basis = 0.0_real32
        radians = 0.0174532_real32 * angle_cm_deg
        sine = sin(radians)
        cosine = cos(radians)
        half_sine = sin(radians / 2.0_real32) / sqrt(2.0_real32)
        half_cosine = cos(radians / 2.0_real32) / sqrt(2.0_real32)
        previous_legendre = 1.0_real32
        legendre = cosine
        basis(1, 1) = 0.0_real32
        basis(2, 1) = -half_cosine
        basis(3, 1) = 0.0_real32
        basis(4, 1) = half_sine
        first_derivative = 0.0_real32
        second_derivative = 0.0_real32
        orbital = 0.0_real32

        do l = 2, partial_wave_count
            second_derivative = &
                cosine * second_derivative + &
                (orbital + 2.0_real32) * first_derivative
            first_derivative = &
                cosine * first_derivative + &
                (orbital + 1.0_real32) * previous_legendre
            orbital = orbital + 1.0_real32
            basis(1, l) = ( &
                (1.0_real32 - cosine) * second_derivative - &
                (orbital + 2.0_real32) * first_derivative) * &
                sine * half_cosine
            basis(2, l) = ( &
                (1.0_real32 - cosine) * first_derivative - &
                (orbital + 1.0_real32) * legendre) * half_cosine
            basis(3, l) = ( &
                (1.0_real32 + cosine) * second_derivative + &
                (orbital + 2.0_real32) * first_derivative) * &
                sine * half_sine
            basis(4, l) = ( &
                (1.0_real32 + cosine) * first_derivative + &
                (orbital + 1.0_real32) * legendre) * half_sine
            temporary = legendre
            legendre = ( &
                (2.0_real32 * orbital + 1.0_real32) * cosine * legendre - &
                orbital * previous_legendre) / (orbital + 1.0_real32)
            previous_legendre = temporary
        end do
    end subroutine calculate_helicity_basis

    subroutine sha256_file(path, digest, status, message)
        character(len=*), intent(in) :: path
        character(len=64), intent(out) :: digest
        integer, intent(out) :: status
        character(len=*), intent(out) :: message

        integer(int8), allocatable :: bytes(:)
        integer :: file_size
        integer :: padded_size
        integer :: unit
        integer :: ios
        integer :: byte_index
        integer :: word_index
        integer :: round
        integer :: block
        integer :: digest_index
        integer(int64) :: bit_length
        integer(int64) :: byte_value
        integer(int64) :: schedule(64)
        integer(int64) :: hash(8)
        integer(int64) :: a
        integer(int64) :: b
        integer(int64) :: c
        integer(int64) :: d
        integer(int64) :: e
        integer(int64) :: f
        integer(int64) :: g
        integer(int64) :: h
        integer(int64) :: sigma_zero
        integer(int64) :: sigma_one
        integer(int64) :: choice
        integer(int64) :: majority
        integer(int64) :: temporary_one
        integer(int64) :: temporary_two
        character(len=8) :: piece

        integer(int64), parameter :: mask32 = int(z'FFFFFFFF', int64)
        integer(int64), parameter :: constants(64) = [ &
            int(z'428A2F98', int64), int(z'71374491', int64), &
            int(z'B5C0FBCF', int64), int(z'E9B5DBA5', int64), &
            int(z'3956C25B', int64), int(z'59F111F1', int64), &
            int(z'923F82A4', int64), int(z'AB1C5ED5', int64), &
            int(z'D807AA98', int64), int(z'12835B01', int64), &
            int(z'243185BE', int64), int(z'550C7DC3', int64), &
            int(z'72BE5D74', int64), int(z'80DEB1FE', int64), &
            int(z'9BDC06A7', int64), int(z'C19BF174', int64), &
            int(z'E49B69C1', int64), int(z'EFBE4786', int64), &
            int(z'0FC19DC6', int64), int(z'240CA1CC', int64), &
            int(z'2DE92C6F', int64), int(z'4A7484AA', int64), &
            int(z'5CB0A9DC', int64), int(z'76F988DA', int64), &
            int(z'983E5152', int64), int(z'A831C66D', int64), &
            int(z'B00327C8', int64), int(z'BF597FC7', int64), &
            int(z'C6E00BF3', int64), int(z'D5A79147', int64), &
            int(z'06CA6351', int64), int(z'14292967', int64), &
            int(z'27B70A85', int64), int(z'2E1B2138', int64), &
            int(z'4D2C6DFC', int64), int(z'53380D13', int64), &
            int(z'650A7354', int64), int(z'766A0ABB', int64), &
            int(z'81C2C92E', int64), int(z'92722C85', int64), &
            int(z'A2BFE8A1', int64), int(z'A81A664B', int64), &
            int(z'C24B8B70', int64), int(z'C76C51A3', int64), &
            int(z'D192E819', int64), int(z'D6990624', int64), &
            int(z'F40E3585', int64), int(z'106AA070', int64), &
            int(z'19A4C116', int64), int(z'1E376C08', int64), &
            int(z'2748774C', int64), int(z'34B0BCB5', int64), &
            int(z'391C0CB3', int64), int(z'4ED8AA4A', int64), &
            int(z'5B9CCA4F', int64), int(z'682E6FF3', int64), &
            int(z'748F82EE', int64), int(z'78A5636F', int64), &
            int(z'84C87814', int64), int(z'8CC70208', int64), &
            int(z'90BEFFFA', int64), int(z'A4506CEB', int64), &
            int(z'BEF9A3F7', int64), int(z'C67178F2', int64) ]

        digest = ''
        inquire(file=trim(path), size=file_size, iostat=ios)
        if (ios /= 0 .or. file_size < 0) then
            call set_error( &
                cm12_io_error, 'cannot inspect CM12 solution file', &
                status, message)
            return
        end if
        padded_size = ((file_size + 9 + 63) / 64) * 64
        allocate(bytes(padded_size), stat=ios)
        if (ios /= 0) then
            call set_error( &
                cm12_io_error, 'cannot allocate CM12 hash buffer', &
                status, message)
            return
        end if
        bytes = 0_int8
        open( &
            newunit=unit, file=trim(path), status='old', action='read', &
            access='stream', form='unformatted', iostat=ios)
        if (ios /= 0) then
            deallocate(bytes)
            call set_error( &
                cm12_io_error, 'cannot open CM12 solution file for hashing', &
                status, message)
            return
        end if
        if (file_size > 0) read(unit, iostat=ios) bytes(1:file_size)
        close(unit)
        if (ios /= 0) then
            deallocate(bytes)
            call set_error( &
                cm12_io_error, 'cannot read CM12 solution file for hashing', &
                status, message)
            return
        end if

        bytes(file_size + 1) = int(-128, int8)
        bit_length = int(file_size, int64) * 8_int64
        do byte_index = 0, 7
            byte_value = iand(shiftr(bit_length, 8 * byte_index), 255_int64)
            if (byte_value > 127_int64) byte_value = byte_value - 256_int64
            bytes(padded_size - byte_index) = int(byte_value, int8)
        end do

        hash = [ &
            int(z'6A09E667', int64), int(z'BB67AE85', int64), &
            int(z'3C6EF372', int64), int(z'A54FF53A', int64), &
            int(z'510E527F', int64), int(z'9B05688C', int64), &
            int(z'1F83D9AB', int64), int(z'5BE0CD19', int64) ]

        do block = 1, padded_size, 64
            schedule = 0_int64
            do word_index = 1, 16
                byte_index = block + (word_index - 1) * 4
                schedule(word_index) = &
                    shiftl(unsigned_byte(bytes(byte_index)), 24) + &
                    shiftl(unsigned_byte(bytes(byte_index + 1)), 16) + &
                    shiftl(unsigned_byte(bytes(byte_index + 2)), 8) + &
                    unsigned_byte(bytes(byte_index + 3))
            end do
            do word_index = 17, 64
                sigma_zero = ieor( &
                    ieor( &
                        rotate_right32(schedule(word_index - 15), 7), &
                        rotate_right32(schedule(word_index - 15), 18)), &
                    shiftr(schedule(word_index - 15), 3))
                sigma_one = ieor( &
                    ieor( &
                        rotate_right32(schedule(word_index - 2), 17), &
                        rotate_right32(schedule(word_index - 2), 19)), &
                    shiftr(schedule(word_index - 2), 10))
                schedule(word_index) = iand( &
                    schedule(word_index - 16) + sigma_zero + &
                    schedule(word_index - 7) + sigma_one, mask32)
            end do

            a = hash(1)
            b = hash(2)
            c = hash(3)
            d = hash(4)
            e = hash(5)
            f = hash(6)
            g = hash(7)
            h = hash(8)
            do round = 1, 64
                sigma_one = ieor( &
                    ieor(rotate_right32(e, 6), rotate_right32(e, 11)), &
                    rotate_right32(e, 25))
                choice = ieor(iand(e, f), iand(not(e), g))
                temporary_one = iand( &
                    h + sigma_one + iand(choice, mask32) + &
                    constants(round) + schedule(round), mask32)
                sigma_zero = ieor( &
                    ieor(rotate_right32(a, 2), rotate_right32(a, 13)), &
                    rotate_right32(a, 22))
                majority = ieor( &
                    ieor(iand(a, b), iand(a, c)), iand(b, c))
                temporary_two = iand( &
                    sigma_zero + iand(majority, mask32), mask32)
                h = g
                g = f
                f = e
                e = iand(d + temporary_one, mask32)
                d = c
                c = b
                b = a
                a = iand(temporary_one + temporary_two, mask32)
            end do
            hash(1) = iand(hash(1) + a, mask32)
            hash(2) = iand(hash(2) + b, mask32)
            hash(3) = iand(hash(3) + c, mask32)
            hash(4) = iand(hash(4) + d, mask32)
            hash(5) = iand(hash(5) + e, mask32)
            hash(6) = iand(hash(6) + f, mask32)
            hash(7) = iand(hash(7) + g, mask32)
            hash(8) = iand(hash(8) + h, mask32)
        end do
        deallocate(bytes)

        do digest_index = 1, 8
            write(piece, '(z8.8)') hash(digest_index)
            digest( &
                (digest_index - 1) * 8 + 1:digest_index * 8) = &
                lowercase(piece)
        end do
        status = cm12_ok
        message = ''
    end subroutine sha256_file

    pure integer(int64) function unsigned_byte(value)
        integer(int8), intent(in) :: value

        unsigned_byte = iand(int(value, int64), 255_int64)
    end function unsigned_byte

    pure integer(int64) function rotate_right32(value, count)
        integer(int64), intent(in) :: value
        integer, intent(in) :: count
        integer(int64), parameter :: mask32 = int(z'FFFFFFFF', int64)

        rotate_right32 = iand( &
            ior(shiftr(value, count), shiftl(value, 32 - count)), mask32)
    end function rotate_right32

    logical function is_sha256(value)
        character(len=*), intent(in) :: value

        integer :: position
        character(len=1) :: digit

        is_sha256 = .false.
        if (len_trim(value) /= 64) return
        do position = 1, 64
            digit = lowercase(value(position:position))
            if (index('0123456789abcdef', digit) == 0) return
        end do
        is_sha256 = .true.
    end function is_sha256

    elemental character(len=len(value)) function lowercase(value)
        character(len=*), intent(in) :: value

        integer :: code
        integer :: position

        lowercase = value
        do position = 1, len(value)
            code = iachar(value(position:position))
            if (code >= iachar('A') .and. code <= iachar('Z')) then
                lowercase(position:position) = achar(code + 32)
            end if
        end do
    end function lowercase

    pure subroutine set_error(code, text, status, message)
        integer, intent(in) :: code
        character(len=*), intent(in) :: text
        integer, intent(out) :: status
        character(len=*), intent(out) :: message

        status = code
        message = text
    end subroutine set_error

end module cm12_solution_kernel
