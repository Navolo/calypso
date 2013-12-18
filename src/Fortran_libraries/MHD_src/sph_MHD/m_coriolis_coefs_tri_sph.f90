!>@file   m_coriolis_coefs_tri_sph.f90
!!@brief  module m_coriolis_coefs_tri_sph
!!
!!@author H. Matsui
!!@date Programmed in 1994
!!@n Modified in 2010
!
!>@brief  Coefficients for Coriolis force in spectrum space
!!
!!@verbatim
!!      subroutine alloc_g0
!!      subroutine alloc_g0_xy
!!
!!      subroutine dealloc_g0
!!      subroutine dealloc_g0_xy
!!
!!*************************************************
!!*
!!*  Rotation of the Coriolos term
!!*     (wss) = wss(jc,1,j3)*w*dyb/r**2
!!*            + wss(jc,2,j3)*dw*yb/r**2
!!*
!!*     (wts) = wts(j3)*w*yb/r**2
!!*
!!*     (wst) = wst(1,j3)*( dw*dyb/r**2 + w*d2yb/r**2 - 2*w*dyb/r**3 )
!!*            + wst(2,j3)*( d2w/r**2 - 2*dw/r**3 )*yb
!!*
!!*     (wtt) = wtt(jc,1,j3)*dw*yb/r**2
!!*            + wtt(jc,2,j3)*w*( dyb/r**2 - 2*yb/r**3 )
!!*
!!*   Divergence of the Coriolis term
!!*     (wsd) = wsd(jc,1,j3)*w*wsb/r**4
!!*            + wsd(jc,2,j3)*dw*dwsb/r**2
!!*     (wtd) = wtd(j3)*dw*dwtb/r**2
!!*
!!*  Radial componenet of the Coriolis term
!!*     (wsr) = wsr(jc,1,j3)*dw*dusb/r**2
!!*     (wtr) = wtr(j3)*dw*wtb/r**2
!!
!!*************************************************
!!*
!!*************************************************
!!*
!!*     wss(jc,1,j3) = sw_rj(jc,1,j3)
!!*     wss(jc,2,j3) = sw_rj(jc,2,j3)
!!*     wts(jc,j3)   = sw_rj(jc,3,j3)
!!*     wst(jc,1,j3) = tw_rj(jc,1,j3)
!!*     wst(jc,2,j3) = tw_rj(jc,2,j3)
!!*     wtt(jc,1,j3) = tw_rj(jc,3,j3)
!!*     wtt(jc,2,j3) = tw_rj(jc,4,j3)
!!*
!!*     wsd(jc,1,j3) = sd_rj(jc,1,j3)
!!*     wsd(jc,2,j3) = sd_rj(jc,2,j3)
!!*     wtd(jc,j3)   = td_rj(jc,j3)
!!*
!!*     wsr(jc,j3) =   sr_rj(jc,j3)
!!*     wtr(jc,j3) =   tr_rj(jc,j3)
!!*
!!*************************************************
!!*
!!*************************************************************
!!*
!!*      gk_cor(j3,jk,2) : gaunt integral for Coriolis term
!!*              jgl_kcor(j3,1,2) : index for gk_cor(j3,1,2)
!!*              jgl_kcor(j3,2,2) : index for gk_cor(j3,2,2)
!!*      el_cor(j3,1,2) : elsasser integral for Coriolis term
!!*              jgl_lcor(j3,1,2) : index for el_cor(j3,1,2)
!!*
!!*************************************************************
!!*
!!*******************************************************************
!!*                                                                 *
!!*  Adams - Gaunt integrals                                        *
!!*                                                                 *
!!*  (m1,m2,m3)  //  (m1)   (m2)   (m3)                             *
!!* Ki         = || Y    * Y    * Y     sin(theta) d(theta)d(phi)   *
!!*  (l1,l2,l3)  //  (l1)   (l2)   (l3)                             *
!!*                                                                 *
!!*                            (m2)        (m3)                     *
!!*  (m1,m2,m3)  //  (m1)    dy(l2)      dy(l3)                     *
!!* Li         = || Y    *[ -------- * ----------                   *
!!*  (l1,l2,l3)  //  (l1)   d(theta)    d(phi)                      *
!!*                                                                 *
!!*                    (m2)        (m3)                             *
!!*                  dy(l2)      dy(l3)                             *
!!*              - ---------- * -------- ] d(theta)d(phi)           *
!!*                  d(phi)     d(theta)                            *
!!*                                                                 *
!!*  where                                                          *
!!*                   (m)   (m)  | sin(m*phi) |                     *
!!*                  Y   = P   * |   1        |                     *
!!*                   (l)   (l)  | cos(m*phi) |                     *
!!*                                                                 *
!!*                         (m)     2(l-m)!     1                   *
!!*                        P   = [----------]**--- * P(l,m)         *
!!*                         (l)      (l+m)!     2                   *
!!*                         (0)                                     *
!!*                        P   =           P(l,0)                   *
!!*                         (l)                                     *
!!*                                                                 *
!!*******************************************************************
!!
!!@endverbatim
!!
      module m_coriolis_coefs_tri_sph
!*
      use m_precision
!
      use m_constants
      use m_spherical_harmonics
!
      implicit none
!
!>      Coefficients for curl of Coriolis force for poloidal vorticity
      real(kind = kreal), allocatable :: sw_rj(:,:,:)
!>      Coefficients for curl of Coriolis force for toroidal vorticity
      real(kind = kreal), allocatable :: tw_rj(:,:,:)
!>      Coefficients for divergence of Coriolis force 
!!       for poloidal vorticity by poloidal velocity
      real(kind = kreal), allocatable :: sd_rj(:,:,:)
!>      Coefficients for divergence of Coriolis force 
!!       for poloidal vorticity by Toroidal velocity
      real(kind = kreal), allocatable :: td_rj(:,:)
!>      Coefficients for radial compoonent of Coriolis force 
!!       for poloidal vorticity by poloidal velocity
      real(kind = kreal), allocatable :: sr_rj(:,:)
!>      Coefficients for radial compoennt of Coriolis force 
!!       for poloidal vorticity by Toroidal velocity
      real(kind = kreal), allocatable :: tr_rj(:,:)
!
!
!>      Coefficients for curl of Coriolis force
!!       by Y_{1}^{1s} for poloidal vorticity
      real(kind = kreal), allocatable :: sw1_rj(:,:,:)
!>      Coefficients for curl of Coriolis force
!!       by Y_{1}^{1s}for toroidal vorticity
      real(kind = kreal), allocatable :: tw1_rj(:,:,:)
!>      Coefficients for divergence of Coriolis force 
!!       by Y_{1}^{1s} for poloidal vorticity by poloidal velocity
      real(kind = kreal), allocatable :: sd1_rj(:,:,:)
!>      Coefficients for divergence of Coriolis force 
!!       by Y_{1}^{1s} for poloidal vorticity by Toroidal velocity
      real(kind = kreal), allocatable :: td1_rj(:,:)
!>      Coefficients for radial compoonent of Coriolis force 
!!       by Y_{1}^{1s} for poloidal vorticity by poloidal velocity
      real(kind = kreal), allocatable :: sr1_rj(:,:)
!>      Coefficients for radial compoennt of Coriolis force 
!!       by Y_{1}^{1s} for poloidal vorticity by Toroidal velocity
      real(kind = kreal), allocatable :: tr1_rj(:,:)
!
!>      Coefficients for curl of Coriolis force
!!        by Y_{1}^{1c} for poloidal vorticity
      real(kind = kreal), allocatable :: sw3_rj(:,:,:)
!>      Coefficients for curl of Coriolis force
!!       by Y_{1}^{1c} for toroidal vorticity
      real(kind = kreal), allocatable :: tw3_rj(:,:,:)
!>      Coefficients for divergence of Coriolis force 
!!       by Y_{1}^{1c} for poloidal vorticity by poloidal velocity
      real(kind = kreal), allocatable :: sd3_rj(:,:,:)
!>      Coefficients for divergence of Coriolis force 
!!       by Y_{1}^{1c} for poloidal vorticity by Toroidal velocity
      real(kind = kreal), allocatable :: td3_rj(:,:)
!>      Coefficients for radial compoonent of Coriolis force
!!       by Y_{1}^{1c} for poloidal vorticity by poloidal velocity
      real(kind = kreal), allocatable :: sr3_rj(:,:)
!>      Coefficients for radial compoennt of Coriolis force
!!       by Y_{1}^{1c} for poloidal vorticity by Toroidal velocity
      real(kind = kreal), allocatable :: tr3_rj(:,:)
!
!*   ------------------------------------------------------------------
!*
      contains
!*
!*   ------------------------------------------------------------------
!
      subroutine alloc_g0
!
      allocate( sw_rj(2,3,jmax_tri_sph) )
      allocate( tw_rj(2,4,jmax_tri_sph) )
!
      allocate( sd_rj(2,2,jmax_tri_sph) )
      allocate( td_rj(2,jmax_tri_sph) )
!
      allocate( sr_rj(2,jmax_tri_sph) )
      allocate( tr_rj(2,jmax_tri_sph) )
!
      sw_rj = zero
      tw_rj = zero
!
      sd_rj = zero
      td_rj = zero
!
      sr_rj = zero
      tr_rj = zero
!
      end subroutine alloc_g0
!
! ----------------------------------------------------------------------
!
      subroutine alloc_g0_xy
!
      allocate(sw1_rj(4,3,0:jmax_tri_sph), sw3_rj(4,3,0:jmax_tri_sph))
      allocate(tw1_rj(4,4,0:jmax_tri_sph), tw3_rj(4,4,0:jmax_tri_sph))
!
      allocate(sd1_rj(4,2,0:jmax_tri_sph), sd3_rj(4,2,0:jmax_tri_sph))
      allocate(td1_rj(4,0:jmax_tri_sph), td3_rj(4,0:jmax_tri_sph) )
!
      allocate(sr1_rj(4,0:jmax_tri_sph), sr3_rj(4,0:jmax_tri_sph) )
      allocate(tr1_rj(4,0:jmax_tri_sph), tr3_rj(4,0:jmax_tri_sph) )
!
      sw1_rj = zero
      tw1_rj = zero
      sw3_rj = zero
      tw3_rj = zero
!
      sd1_rj = zero
      td1_rj = zero
      sd3_rj = zero
      td3_rj = zero
!
      sr1_rj = zero
      tr1_rj = zero
      sr3_rj = zero
      tr3_rj = zero
!
      end subroutine alloc_g0_xy
!
! ----------------------------------------------------------------------
! ----------------------------------------------------------------------
!
      subroutine dealloc_g0
!
      deallocate( sw_rj, tw_rj )
      deallocate( sd_rj, td_rj )
      deallocate( sr_rj, tr_rj )
!
      end subroutine dealloc_g0
!
! ----------------------------------------------------------------------
!
      subroutine dealloc_g0_xy
!
      deallocate( sw1_rj, tw1_rj, sw3_rj, tw3_rj )
      deallocate( sd1_rj, td1_rj, sd3_rj, td3_rj )
      deallocate( sr1_rj, tr1_rj, sr3_rj, tr3_rj )
!
      end subroutine dealloc_g0_xy
!
! ----------------------------------------------------------------------
!
      end module m_coriolis_coefs_tri_sph
