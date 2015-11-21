MODULE OVERLAP

    USE CONSTANTS
    USE FACT
    USE GAUSSIAN

    CONTAINS

        FUNCTION Si(a,b,aa,bb,Rai,Rbi,Ri)
            ! ------------------------------------------------------------------------------------------------
            ! Compute overlap integral between two unnormalized Cartesian Gaussian functions along direction i
            ! ------------------------------------------------------------------------------------------------

            IMPLICIT NONE

            ! INPUT
            INTEGER, intent(in) :: a,b ! Angular momentum coefficients of the Gaussians along direction i
            REAL*8, intent(in) :: aa, bb ! Exponential coefficients of the Gaussians
            REAL*8, intent(in) :: Rai, Rbi ! Centers of the Gaussians
            REAL*8, intent(in) :: Ri ! Center of the Gaussians product

            ! INTERMEDIATE VARIABLE
            REAL*8 :: tmp
            INTEGER :: i ! Loop index
            INTEGER :: j ! Loop index

            ! OUTPUT
            REAL*8 :: Si

            Si = 0.0D0

            DO i = 0, a
                DO j = 0, b
                    IF (MOD(i+j,2) == 0) THEN
                        tmp = binom(a,i) * binom(b,j) * factorial2(i + j - 1)
                        tmp = tmp * (Ri-Rai)**(a-i)
                        tmp = tmp * (Ri-Rbi)**(b-j)
                        tmp = tmp / (2.0D0 * (aa + bb))**((i + j) / 2.0D0)

                        Si = Si + tmp
                    END IF
                END DO
            END DO
        END FUNCTION Si



        FUNCTION overlap_coeff(ax,ay,az,bx,by,bz,aa,bb,Ra,Rb) result(S)
            ! -----------------------------------------------------------------
            ! Compute overlap integral between two Cartesian Gaussian functions
            ! -----------------------------------------------------------------
            !
            ! Source:
            !   The Mathematica Journal
            !   Evaluation of Gaussian Molecular Integrals
            !   I. Overlap Integrals
            !   Minhhuy Hô and Julio Manuel Hernández-Pérez
            !
            ! -----------------------------------------------------------------

            IMPLICIT NONE

            ! INPUT
            INTEGER, intent(in) :: ax, ay, az, bx, by, bz ! Angular momentum coefficients
            REAL*8, intent(in) :: aa, bb ! Exponential Gaussian coefficients
            REAL*8, dimension(3), intent(in) :: Ra, Rb ! Gaussian centers

            ! INTERMEDIATE VARIABLES
            REAL*8 :: pp ! Gaussian produc exponential coefficient
            REAL*8, dimension(3) :: Rp ! Gaussian produc center
            REAL*8 :: cp ! Gaussian product multiplicative constant

            ! OUTPUT
            REAL*8 :: S

            CALL gaussian_product(aa,bb,Ra,Rb,pp,Rp,cp) ! Compute PP, RP and CP

            S = 1
            S = S * Si(ax,bx,aa,bb,Ra(1),Rb(1),Rp(1))       ! Overlap along x
            S = S * Si(ay,by,aa,bb,Ra(2),Rb(2),Rp(2))       ! Overlap along y
            S = S * Si(az,bz,aa,bb,Ra(3),Rb(3),Rp(3))       ! Overlap along z
            S = S * norm(ax,ay,az,aa) * norm(bx,by,bz,bb)   ! Normalization of Gaussian functions
            S = S * cp                                      ! Gaussian product factor
            S = S * (PI / pp)**(3./2.)                      ! Solution of Gaussian integral

        END FUNCTION overlap_coeff



        ! -------------
        ! OVERLAP MARIX
        ! -------------
        SUBROUTINE S_overlap(Kf,basis_D,basis_A,basis_L,basis_R,S)
            ! ----------------------------------------------
            ! Compute overlap matrix between basis function.
            ! ----------------------------------------------

            IMPLICIT NONE

            ! TODO Allow flexibility for basis sets other than STO-3G
            ! HARD CODED
            INTEGER, PARAMETER :: c = 3 ! Number of contractions per basis function

            ! INPUT
            INTEGER, intent(in) :: Kf ! Number of basis functions
            REAL*8, dimension(Kf,3), intent(in) :: basis_R ! Basis set niclear positions
            INTEGER, dimension(Kf,3), intent(in) :: basis_L ! Basis set angular momenta
            REAL*8, dimension(Kf,3), intent(in) :: basis_D ! Basis set contraction coefficients
            REAL*8, dimension(Kf,3), intent(in) :: basis_A ! Basis set exponential contraction coefficients

            ! INTERMEDIATE VARIABLES
            INTEGER :: i,j,k,l
            REAL*8 :: tmp

            ! OUTPUT
            REAL*8, dimension(Kf,Kf), intent(out) :: S

            S(:,:) = 0.0D0

            DO i = 1,Kf
                DO j = 1,Kf
                    DO k = 1,c
                        DO l = 1,c
                            tmp = basis_D(i,k) * basis_D(j,l)
                            tmp = tmp * overlap_coeff(  basis_L(i,1),&  ! lx for basis function i
                                                        basis_L(i,2),&  ! ly for basis function i
                                                        basis_L(i,3),&  ! lz for basis function i
                                                        basis_L(j,1),&  ! lx for basis function j
                                                        basis_L(j,2),&  ! ly for basis function j
                                                        basis_L(j,3),&  ! lz for basis function j
                                                        basis_A(i,k),&  ! Exponential coefficient for basis function i, contraction k
                                                        basis_A(j,l),&  ! Exponential coefficient for basis function j, contraction l
                                                        basis_R(i,:),&  ! Center of basis function i
                                                        basis_R(j,:))   ! Center of basis function j

                            S(i,j) = S(i,j) + tmp
                        END DO ! l
                    END DO ! k
                END DO ! j
            END DO ! i

        END SUBROUTINE S_overlap

END MODULE OVERLAP
