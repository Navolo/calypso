!>@file   legendre_transform_lgloop.f90
!!@brief  module legendre_transform_lgloop
!!
!!@author H. Matsui
!!@date Programmed in Aug., 2007
!!@n    Modified in Apr. 2013
!
!>@brief  Legendre transforms
!!       (longest loop version)
!!
!!
!!@verbatim
!!      subroutine leg_backward_trans_long                              &
!!     &         (ncomp, nvector, nscalar, n_WR, n_WS, WR, WS)
!!        Input:  sp_rlm   (Order: poloidal,diff_poloidal,toroidal)
!!        Output: vr_rtm   (Order: radius,theta,phi)
!!
!!    Forward transforms
!!      subroutine leg_forward_trans_long(ncomp, nvector, nscalar)
!!        Input:  vr_rtm   (Order: radius,theta,phi)
!!        Output: sp_rlm   (Order: poloidal,diff_poloidal,toroidal)
!!@endverbatim
!!
!!@param   ncomp    Total number of components for spherical transform
!!@param   nvector  Number of vector for spherical transform
!!@param   nscalar  Number of scalar (including tensor components)
!!                  for spherical transform
!
      module legendre_transform_lgloop
!
      use m_precision
!
      implicit none
!
! -----------------------------------------------------------------------
!
      contains
!
! -----------------------------------------------------------------------
!
      subroutine leg_backward_trans_long                                &
     &         (ncomp, nvector, nscalar, n_WR, n_WS, WR, WS)
!
      use m_work_4_sph_trans_spin
      use legendre_bwd_trans_lgloop
      use spherical_SRs_N
!
      integer(kind = kint), intent(in) :: ncomp, nvector, nscalar
      integer(kind = kint), intent(in) :: n_WR, n_WS
      real (kind=kreal), intent(inout):: WR(n_WR)
      real (kind=kreal), intent(inout):: WS(n_WS)
!
!
      call calypso_rlm_from_recv_N(ncomp, n_WR, WR, sp_rlm_wk(1))
      call clear_bwd_legendre_work(ncomp)
!
      call legendre_b_trans_vector_long                                 &
     &     (ncomp, nvector, sp_rlm_wk(1), vr_rtm_wk(1))
      call legendre_b_trans_scalar_long                                 &
     &     (ncomp, nvector, nscalar, sp_rlm_wk(1), vr_rtm_wk(1))
!
      call finish_send_recv_rj_2_rlm
      call calypso_rtm_to_send_N(ncomp, n_WS, vr_rtm_wk(1), WS)
!
      end subroutine leg_backward_trans_long
!
! -----------------------------------------------------------------------
!
      subroutine leg_forward_trans_long                                 &
     &         (ncomp, nvector, nscalar, n_WR, n_WS, WR, WS)
!
      use m_work_4_sph_trans_spin
      use legendre_fwd_trans_lgloop
      use spherical_SRs_N
!
      integer(kind = kint), intent(in) :: ncomp, nvector, nscalar
      integer(kind = kint), intent(in) :: n_WR, n_WS
      real (kind=kreal), intent(inout):: WR(n_WR)
      real (kind=kreal), intent(inout):: WS(n_WS)
!
!
      call calypso_rtm_from_recv_N(ncomp, n_WR, WR, vr_rtm_wk(1))
!
      call legendre_f_trans_vector_long                                 &
     &    (ncomp, nvector, vr_rtm_wk(1), sp_rlm_wk(1))
      call legendre_f_trans_scalar_long                                 &
     &    (ncomp, nvector, nscalar, vr_rtm_wk(1), sp_rlm_wk(1))
!
      call finish_send_recv_rtp_2_rtm
      call calypso_rlm_to_send_N(ncomp, n_WS, sp_rlm_wk(1), WS)
!
      end subroutine leg_forward_trans_long
!
! -----------------------------------------------------------------------
!
      end module legendre_transform_lgloop

