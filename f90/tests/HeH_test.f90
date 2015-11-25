PROGRAM HF

    USE RHF
    USE UTILS
    USE CONSTANTS

    IMPLICIT NONE

    REAL*8, PARAMETER :: zeta_H = 1.24D0    ! STO coefficient correction for H
    REAL*8, PARAMETER :: zeta_He = 2.0925D0 ! STO coefficient correction for He
    REAL*8, PARAMETER :: zeta_O_1 = 7.66D0 ! STO coefficient correction for He
    REAL*8, PARAMETER :: zeta_O_2 = 2.25D0 ! STO coefficient correction for He

    ! ------------------
    ! BASIS SET FOR HeH+
    ! ------------------
    INTEGER, PARAMETER :: K = 2     ! Number of basis functions
    INTEGER, PARAMETER :: Nn = 2    ! Number of nuclei

    INTEGER, dimension(K,3) :: basis_L              ! Angular momenta of basis set Gaussians
    REAL*8, dimension(K,3) :: basis_R               ! Centers of basis set Gaussians
    REAL*8, dimension(K,c) :: basis_D, basis_A  ! Basis set coefficients

    ! -------------
    ! MOLECULE HeH+
    ! -------------

    REAL*8, dimension(Nn,3) :: Rn   ! Nuclear positions
    INTEGER, dimension(Nn) :: Zn    ! Nuclear charges

    INTEGER, PARAMETER :: Ne = 2    ! Total number of electrons

    REAL*8 :: final_E               ! Total converged energy

    Rn(1,1:3) = (/0.0D0, 0.0D0, 0.0D0/)       ! Position of first H atom
    Rn(2,1:3) = (/1.4632D0, 0.0D0, 0.0D0/)    ! Position of the second H atom

    Zn = (/1, 2/)

    basis_R(1,1:3) = Rn(1,1:3)    ! Position of the H atom
    basis_R(2,1:3) = Rn(2,1:3)    ! Position of the He atom

    basis_L(1,1:3) = (/0, 0, 0/) ! Angular momenta for the first basis function
    basis_L(2,1:3) = (/0, 0, 0/) ! Angular momenta for the second basis function

    basis_D(1,1:c) = (/0.444635D0, 0.535328D0, 0.154329D0 /)
    basis_D(2,1:c) = (/0.444635D0, 0.535328D0, 0.154329D0 /)

    basis_A(1,1:c) = (/0.109818D0 * zeta_H**2, 0.405771 * zeta_H**2, 2.22766 * zeta_H**2/)
    basis_A(2,1:c) = (/0.109818D0 * zeta_He**2, 0.405771 * zeta_He**2, 2.22766 * zeta_He**2/)

    ! ------------------------
    ! TOTAL ENERGY CALCULATION
    ! ------------------------

    CALL SCF(K,Ne,Nn,basis_D,basis_A,basis_L,basis_R,Zn,Rn,final_E,.TRUE.)

END PROGRAM HF
