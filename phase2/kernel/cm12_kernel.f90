module cm12_kernel
    use, intrinsic :: iso_fortran_env, only: real32
    implicit none
    private

    integer, parameter, public :: cm12_real_kind = real32
    integer, parameter, public :: cm12_ok = 0
    integer, parameter, public :: cm12_invalid_argument = 1
    integer, parameter, public :: cm12_io_error = 2
    integer, parameter, public :: cm12_invalid_dataset = 3
    integer, parameter, public :: cm12_unsupported_wave = 4

    integer, parameter :: wave_count = 14
    integer, parameter :: grid_count = 275
    integer, parameter :: matrix_count = 10
    integer, parameter :: channel_count = 4

    character(len=3), parameter :: wave_names(wave_count) = [ &
        character(len=3) :: &
        'S11', 'S31', 'P11', 'P31', 'P13', 'P33', 'D13', &
        'D33', 'D15', 'D35', 'F15', 'F17', 'F35', 'F37' ]
    integer, parameter :: wave_channels(wave_count) = [ &
        4, 3, 3, 2, 3, 3, 4, 3, 3, 3, 3, 2, 3, 3 ]

    type, public :: cm12_dataset
        private
        logical :: loaded = .false.
        character(len=1024) :: root = ''
        real(real32) :: energy(grid_count, wave_count) = 0.0_real32
        real(real32) :: cmm_real(grid_count, matrix_count, wave_count) = &
            0.0_real32
        real(real32) :: cmm_imag(grid_count, matrix_count, wave_count) = &
            0.0_real32
        real(real32) :: cmf_real(grid_count, channel_count, wave_count) = &
            0.0_real32
        real(real32) :: cmf_imag(grid_count, channel_count, wave_count) = &
            0.0_real32
        real(real32) :: kcm(grid_count, matrix_count, wave_count) = &
            0.0_real32
    end type cm12_dataset

    public :: load_cm12_dataset
    public :: cm12_dataset_is_loaded
    public :: cm12_dataset_summary
    public :: cm12_evaluate_multipole

contains

    subroutine load_cm12_dataset(root, dataset, status, message)
        character(len=*), intent(in) :: root
        type(cm12_dataset), intent(out) :: dataset
        integer, intent(out) :: status
        character(len=*), intent(out) :: message

        integer :: wave
        real(real32) :: cmf_energy(grid_count)
        real(real32) :: kcm_energy(grid_count)

        status = cm12_ok
        message = ''
        if (len_trim(root) == 0) then
            call set_error( &
                cm12_invalid_argument, 'CM12 dataset root is empty', &
                status, message)
            return
        end if
        if (len_trim(root) > len(dataset%root)) then
            call set_error( &
                cm12_invalid_argument, 'CM12 dataset root is too long', &
                status, message)
            return
        end if

        dataset%root = trim(root)
        do wave = 1, wave_count
            call read_cmm_file( &
                trim(root), wave_names(wave), dataset%energy(:, wave), &
                dataset%cmm_real(:, :, wave), &
                dataset%cmm_imag(:, :, wave), status, message)
            if (status /= cm12_ok) return

            call read_cmf_file( &
                trim(root), wave_names(wave), cmf_energy, &
                dataset%cmf_real(:, :, wave), &
                dataset%cmf_imag(:, :, wave), status, message)
            if (status /= cm12_ok) return

            call read_kcm_file( &
                trim(root), wave_names(wave), kcm_energy, &
                dataset%kcm(:, :, wave), status, message)
            if (status /= cm12_ok) return

            call validate_energy_grid( &
                wave_names(wave), dataset%energy(:, wave), &
                cmf_energy, kcm_energy, status, message)
            if (status /= cm12_ok) return
        end do

        dataset%loaded = .true.
    end subroutine load_cm12_dataset

    pure logical function cm12_dataset_is_loaded(dataset)
        type(cm12_dataset), intent(in) :: dataset

        cm12_dataset_is_loaded = dataset%loaded
    end function cm12_dataset_is_loaded

    subroutine cm12_dataset_summary( &
        dataset, root, waves, rows, first_energy, last_energy)
        type(cm12_dataset), intent(in) :: dataset
        character(len=*), intent(out) :: root
        integer, intent(out) :: waves
        integer, intent(out) :: rows
        real(real32), intent(out) :: first_energy
        real(real32), intent(out) :: last_energy

        root = trim(dataset%root)
        if (.not. dataset%loaded) then
            waves = 0
            rows = 0
            first_energy = 0.0_real32
            last_energy = 0.0_real32
            return
        end if

        waves = wave_count
        rows = grid_count
        first_energy = dataset%energy(1, 1)
        last_energy = dataset%energy(grid_count, 1)
    end subroutine cm12_dataset_summary

    pure subroutine cm12_evaluate_multipole( &
        dataset, form_number, parameters, multipole_family, j_branch, &
        orbital_l, w_cm_mev, born_multipole, value_mfm, status, message)
        type(cm12_dataset), intent(in) :: dataset
        integer, intent(in) :: form_number
        real(real32), intent(in) :: parameters(:)
        integer, intent(in) :: multipole_family
        integer, intent(in) :: j_branch
        integer, intent(in) :: orbital_l
        real(real32), intent(in) :: w_cm_mev
        real(real32), intent(in) :: born_multipole
        complex(real32), intent(out) :: value_mfm
        integer, intent(out) :: status
        character(len=*), intent(out) :: message

        real(real32), parameter :: pion_mass_for_expansion = 135.04_real32
        real(real32), parameter :: proton_mass = 938.256_real32
        real(real32), parameter :: pion_mass = 139.58_real32
        real(real32), parameter :: rho_mass = 892.0_real32
        real(real32), parameter :: eta_mass = 547.3_real32
        real(real32), parameter :: neutron_mass = 939.65_real32
        real(real32), parameter :: delta_mass = 1212.0_real32

        character(len=3) :: wave_name
        integer :: wave
        integer :: channels
        integer :: nborn
        integer :: parameter_count
        integer :: j
        integer :: k
        integer :: ip
        integer :: packed_index
        real(real32) :: expansion
        real(real32) :: expansion_origin
        real(real32) :: power
        real(real32) :: real_sum
        real(real32) :: imag_sum
        real(real32) :: matrix_real(matrix_count)
        real(real32) :: matrix_imag(matrix_count)
        real(real32) :: production(matrix_count)
        real(real32) :: momentum(0:channel_count)
        real(real32) :: result_real(channel_count)
        real(real32) :: result_imag(channel_count)
        real(real32) :: threshold(channel_count)
        real(real32) :: mass_one(0:channel_count)
        real(real32) :: mass_two(0:channel_count)
        complex(real32) :: hadronic(channel_count, channel_count)

        status = cm12_ok
        message = ''
        value_mfm = cmplx(0.0_real32, 0.0_real32, kind=real32)

        if (.not. dataset%loaded) then
            call set_error( &
                cm12_invalid_dataset, 'CM12 dataset is not loaded', &
                status, message)
            return
        end if
        if (size(parameters) < 25) then
            call set_error( &
                cm12_invalid_argument, &
                'CM12 multipole requires 25 parameters', status, message)
            return
        end if
        if (w_cm_mev <= 0.0_real32) then
            call set_error( &
                cm12_invalid_argument, 'Wcm must be positive', &
                status, message)
            return
        end if

        call identify_wave( &
            multipole_family, j_branch, orbital_l, wave_name, &
            status, message)
        if (status /= cm12_ok) return
        wave = find_wave(wave_name)
        if (wave == 0) then
            call set_error( &
                cm12_unsupported_wave, &
                'CM12 dataset does not contain partial wave ' // wave_name, &
                status, message)
            return
        end if

        channels = wave_channels(wave)
        nborn = form_number / 10
        expansion_origin = pion_mass_for_expansion + proton_mass
        expansion = &
            (w_cm_mev - expansion_origin) / 1000.0_real32
        production = 0.0_real32

        do j = 1, channels
            if (nborn /= 13) then
                power = 1.0_real32
                do ip = 1, 4
                    production(j) = production(j) + &
                        parameters((j - 1) * 4 + ip) * power
                    power = power * expansion
                end do
            else
                if (form_number == 135) then
                    power = 1.0_real32
                    parameter_count = 5
                else
                    power = expansion
                    parameter_count = 4
                end if
                do ip = 1, parameter_count
                    production(j) = production(j) + &
                        parameters((j - 1) * parameter_count + ip) * power
                    power = power * expansion
                end do
            end if
        end do

        if (nborn == 13) production(1) = production(1) + born_multipole

        call interpolate_cmm( &
            dataset, wave, w_cm_mev, matrix_real, matrix_imag)

        hadronic = cmplx(0.0_real32, 0.0_real32, kind=real32)
        packed_index = 1
        do j = 1, channels
            do k = 1, j
                hadronic(j, k) = cmplx( &
                    matrix_real(packed_index), &
                    matrix_imag(packed_index), kind=real32)
                hadronic(k, j) = hadronic(j, k)
                packed_index = packed_index + 1
            end do
        end do

        mass_one = [ &
            0.0_real32, pion_mass, pion_mass, neutron_mass, proton_mass ]
        mass_two = [ &
            proton_mass, proton_mass, delta_mass, rho_mass, eta_mass ]
        threshold = [ &
            pion_mass_for_expansion + proton_mass, &
            2.0_real32 * pion_mass_for_expansion + proton_mass, &
            2.0_real32 * pion_mass_for_expansion + proton_mass, &
            proton_mass + eta_mass ]

        call on_shell_momentum( &
            w_cm_mev, mass_one(0), mass_two(0), momentum(0))
        do j = 1, channels
            call on_shell_momentum( &
                w_cm_mev, mass_one(j), mass_two(j), momentum(j))
        end do

        result_real = 0.0_real32
        result_imag = 0.0_real32
        do j = 1, channels
            real_sum = 0.0_real32
            imag_sum = 0.0_real32
            if (w_cm_mev > threshold(j)) then
                do k = 1, channels
                    real_sum = real_sum + &
                        real(hadronic(j, k), kind=real32) * production(k)
                    imag_sum = imag_sum + &
                        aimag(hadronic(j, k)) * production(k)
                end do
            end if
            if (nborn /= 13 .and. orbital_l /= 0) then
                real_sum = &
                    (momentum(j) / 1000.0_real32) ** orbital_l * real_sum
                imag_sum = &
                    (momentum(j) / 1000.0_real32) ** orbital_l * imag_sum
            end if
            result_real(j) = real_sum
            result_imag(j) = imag_sum
        end do

        value_mfm = cmplx(result_real(1), result_imag(1), kind=real32)
    end subroutine cm12_evaluate_multipole

    subroutine read_cmm_file( &
        root, wave, energy, values_real, values_imag, status, message)
        character(len=*), intent(in) :: root
        character(len=*), intent(in) :: wave
        real(real32), intent(out) :: energy(grid_count)
        real(real32), intent(out) :: values_real(grid_count, matrix_count)
        real(real32), intent(out) :: values_imag(grid_count, matrix_count)
        integer, intent(out) :: status
        character(len=*), intent(out) :: message

        character(len=2048) :: path
        integer :: unit
        integer :: row
        integer :: ios
        real(real32) :: extra

        path = trim(root) // '/cmm' // wave // '.dat'
        open( &
            newunit=unit, file=trim(path), status='old', action='read', &
            iostat=ios)
        if (ios /= 0) then
            call file_error('cannot open', path, ios, status, message)
            return
        end if
        do row = 1, grid_count
            read(unit, *, iostat=ios) &
                energy(row), values_real(row, :), values_imag(row, :)
            if (ios /= 0) then
                close(unit)
                call file_error( &
                    'invalid or short CMM file', path, ios, status, message)
                return
            end if
        end do
        read(unit, *, iostat=ios) extra
        close(unit)
        if (ios == 0) then
            call file_error( &
                'CMM file has more than 275 rows', path, ios, &
                status, message)
            return
        end if
        status = cm12_ok
        message = ''
    end subroutine read_cmm_file

    subroutine read_cmf_file( &
        root, wave, energy, values_real, values_imag, status, message)
        character(len=*), intent(in) :: root
        character(len=*), intent(in) :: wave
        real(real32), intent(out) :: energy(grid_count)
        real(real32), intent(out) :: values_real(grid_count, channel_count)
        real(real32), intent(out) :: values_imag(grid_count, channel_count)
        integer, intent(out) :: status
        character(len=*), intent(out) :: message

        character(len=2048) :: path
        integer :: unit
        integer :: row
        integer :: ios
        real(real32) :: extra

        path = trim(root) // '/cmf' // wave // '.dat'
        open( &
            newunit=unit, file=trim(path), status='old', action='read', &
            iostat=ios)
        if (ios /= 0) then
            call file_error('cannot open', path, ios, status, message)
            return
        end if
        do row = 1, grid_count
            read(unit, *, iostat=ios) &
                energy(row), values_real(row, :), values_imag(row, :)
            if (ios /= 0) then
                close(unit)
                call file_error( &
                    'invalid or short CMF file', path, ios, status, message)
                return
            end if
        end do
        read(unit, *, iostat=ios) extra
        close(unit)
        if (ios == 0) then
            call file_error( &
                'CMF file has more than 275 rows', path, ios, &
                status, message)
            return
        end if
        status = cm12_ok
        message = ''
    end subroutine read_cmf_file

    subroutine read_kcm_file( &
        root, wave, energy, values, status, message)
        character(len=*), intent(in) :: root
        character(len=*), intent(in) :: wave
        real(real32), intent(out) :: energy(grid_count)
        real(real32), intent(out) :: values(grid_count, matrix_count)
        integer, intent(out) :: status
        character(len=*), intent(out) :: message

        character(len=2048) :: path
        integer :: unit
        integer :: row
        integer :: ios
        real(real32) :: extra

        path = trim(root) // '/kcm' // wave // '.dat'
        open( &
            newunit=unit, file=trim(path), status='old', action='read', &
            iostat=ios)
        if (ios /= 0) then
            call file_error('cannot open', path, ios, status, message)
            return
        end if
        do row = 1, grid_count
            read(unit, *, iostat=ios) energy(row), values(row, :)
            if (ios /= 0) then
                close(unit)
                call file_error( &
                    'invalid or short KCM file', path, ios, status, message)
                return
            end if
        end do
        read(unit, *, iostat=ios) extra
        close(unit)
        if (ios == 0) then
            call file_error( &
                'KCM file has more than 275 rows', path, ios, &
                status, message)
            return
        end if
        status = cm12_ok
        message = ''
    end subroutine read_kcm_file

    subroutine validate_energy_grid( &
        wave, cmm_energy, cmf_energy, kcm_energy, status, message)
        character(len=*), intent(in) :: wave
        real(real32), intent(in) :: cmm_energy(grid_count)
        real(real32), intent(in) :: cmf_energy(grid_count)
        real(real32), intent(in) :: kcm_energy(grid_count)
        integer, intent(out) :: status
        character(len=*), intent(out) :: message

        integer :: row
        real(real32) :: expected

        do row = 1, grid_count
            expected = 1080.0_real32 + 5.0_real32 * real(row - 1, real32)
            if ( &
                abs(cmm_energy(row) - expected) > 0.001_real32 .or. &
                abs(cmf_energy(row) - cmm_energy(row)) > 0.001_real32 .or. &
                abs(kcm_energy(row) - cmm_energy(row)) > 0.001_real32) then
                write(message, '(a,a,a,i0)') &
                    'inconsistent CM12 energy grid for ', wave, &
                    ' at row ', row
                status = cm12_invalid_dataset
                return
            end if
        end do
        status = cm12_ok
        message = ''
    end subroutine validate_energy_grid

    pure subroutine identify_wave( &
        multipole_family, j_branch, orbital_l, wave, status, message)
        integer, intent(in) :: multipole_family
        integer, intent(in) :: j_branch
        integer, intent(in) :: orbital_l
        character(len=3), intent(out) :: wave
        integer, intent(out) :: status
        character(len=*), intent(out) :: message

        character(len=1), parameter :: orbital_names(0:3) = &
            [ 'S', 'P', 'D', 'F' ]
        integer :: doubled_j
        integer :: isospin

        wave = ''
        if (multipole_family < 1 .or. multipole_family > 6) then
            call set_error( &
                cm12_invalid_argument, &
                'multipole family must be in 1..6', status, message)
            return
        end if
        if (j_branch < 1 .or. j_branch > 2) then
            call set_error( &
                cm12_invalid_argument, &
                'J branch must be 1 or 2', status, message)
            return
        end if
        if (orbital_l < 0 .or. orbital_l > 3) then
            call set_error( &
                cm12_unsupported_wave, &
                'immutable CM12 dataset contains only S/P/D/F waves', &
                status, message)
            return
        end if
        if (orbital_l == 0 .and. j_branch == 1) then
            call set_error( &
                cm12_invalid_argument, 'invalid S-wave J branch', &
                status, message)
            return
        end if
        if ( &
            orbital_l == 0 .and. &
            mod(multipole_family, 2) == 0) then
            call set_error( &
                cm12_invalid_argument, 'invalid magnetic S wave', &
                status, message)
            return
        end if
        if ( &
            orbital_l == 1 .and. j_branch == 1 .and. &
            mod(multipole_family, 2) == 1) then
            call set_error( &
                cm12_invalid_argument, 'invalid electric P-minus wave', &
                status, message)
            return
        end if

        if (multipole_family <= 2) then
            isospin = 3
        else
            isospin = 1
        end if
        if (j_branch == 1) then
            doubled_j = 2 * orbital_l - 1
        else
            doubled_j = 2 * orbital_l + 1
        end if
        write(wave, '(a1,i1,i1)') &
            orbital_names(orbital_l), isospin, doubled_j
        status = cm12_ok
        message = ''
    end subroutine identify_wave

    pure integer function find_wave(wave)
        character(len=*), intent(in) :: wave

        integer :: index

        find_wave = 0
        do index = 1, wave_count
            if (wave == wave_names(index)) then
                find_wave = index
                return
            end if
        end do
    end function find_wave

    pure subroutine interpolate_cmm( &
        dataset, wave, w_cm_mev, values_real, values_imag)
        type(cm12_dataset), intent(in) :: dataset
        integer, intent(in) :: wave
        real(real32), intent(in) :: w_cm_mev
        real(real32), intent(out) :: values_real(matrix_count)
        real(real32), intent(out) :: values_imag(matrix_count)

        integer, parameter :: cusp_index = 83
        integer :: index
        integer :: component
        real(real32) :: grid_energy
        real(real32) :: fraction
        real(real32) :: center
        real(real32) :: minus_delta
        real(real32) :: plus_delta
        real(real32) :: linear_term
        real(real32) :: quadratic_term

        index = int((w_cm_mev - 1080.0_real32) / 5.0_real32 + 1.0_real32)
        if (index < 2) index = 2
        if (index > 274) index = 274
        grid_energy = 1080.0_real32 + 5.0_real32 * real(index - 1, real32)
        fraction = (w_cm_mev - grid_energy) / 5.0_real32

        do component = 1, matrix_count
            center = dataset%cmm_real(index, component, wave)
            minus_delta = &
                dataset%cmm_real(index - 1, component, wave) - center
            plus_delta = &
                dataset%cmm_real(index + 1, component, wave) - center
            if (index == cusp_index) minus_delta = -plus_delta
            linear_term = (plus_delta - minus_delta) / 2.0_real32
            quadratic_term = (plus_delta + minus_delta) / 2.0_real32
            values_real(component) = center + &
                fraction * (linear_term + fraction * quadratic_term)

            center = dataset%cmm_imag(index, component, wave)
            minus_delta = &
                dataset%cmm_imag(index - 1, component, wave) - center
            plus_delta = &
                dataset%cmm_imag(index + 1, component, wave) - center
            if (index == cusp_index) minus_delta = -plus_delta
            linear_term = (plus_delta - minus_delta) / 2.0_real32
            quadratic_term = (plus_delta + minus_delta) / 2.0_real32
            values_imag(component) = center + &
                fraction * (linear_term + fraction * quadratic_term)
        end do
    end subroutine interpolate_cmm

    pure subroutine on_shell_momentum(w, mass_one, mass_two, momentum)
        real(real32), intent(in) :: w
        real(real32), intent(in) :: mass_one
        real(real32), intent(in) :: mass_two
        real(real32), intent(out) :: momentum

        real(real32) :: plus_mass
        real(real32) :: minus_mass
        real(real32) :: above_plus
        real(real32) :: above_minus
        real(real32) :: below_plus
        real(real32) :: below_minus

        plus_mass = mass_one + mass_two
        minus_mass = mass_one - mass_two
        above_plus = w - plus_mass
        above_minus = w - minus_mass
        below_plus = w + plus_mass
        below_minus = w + minus_mass
        if (above_plus >= 0.0_real32) then
            momentum = sqrt( &
                above_plus * above_minus * below_plus * below_minus) / &
                (2.0_real32 * w)
        else
            momentum = 0.0_real32
        end if
    end subroutine on_shell_momentum

    subroutine file_error(action, path, ios, status, message)
        character(len=*), intent(in) :: action
        character(len=*), intent(in) :: path
        integer, intent(in) :: ios
        integer, intent(out) :: status
        character(len=*), intent(out) :: message

        write(message, '(a,1x,a,1x,a,1x,i0)') &
            trim(action), trim(path), 'iostat', ios
        status = cm12_io_error
    end subroutine file_error

    pure subroutine set_error(code, text, status, message)
        integer, intent(in) :: code
        character(len=*), intent(in) :: text
        integer, intent(out) :: status
        character(len=*), intent(out) :: message

        status = code
        message = text
    end subroutine set_error

end module cm12_kernel
