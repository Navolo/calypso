!> @file  cal_diff_adv_src_explicit.f90
!!      module cal_diff_adv_src_explicit
!!
!! @author  H. Matsui
!! @date Programmed in Oct. 2009
!
!> @brief Evaluate time evolution explicitly
!!
!!@verbatim
!!      subroutine sel_scalar_diff_adv_src_adams(kr_st, kr_ed,          &
!!     &          ipol_diffuse, ipol_advect, ipol_source, ipol_scalar,  &
!!     &          ipol_pre, coef_exp, coef_src)
!!      subroutine sel_scalar_diff_adv_src_euler(kr_st, kr_ed,          &
!!     &          ipol_diffuse, ipol_advect, ipol_source, ipol_scalar,  &
!!     &          coef_exp, coef_src)
!!
!!      subroutine sel_ini_adams_scalar_w_src(kr_st, kr_ed,             &
!!     &          ipol_advect, ipol_source, ipol_pre, coef_src)
!!@endverbatim
!!
!!@param kr_st         Radial address for inner boundary
!!@param kr_ed         Radial address for outer boundary
!!@param ipol_diffuse  address for diffusion term
!!@param ipol_advect   address for advection term
!!@param ipol_source   address for source term
!!@param ipol_scalar   address for scalar field to update
!!@param ipol_pre      address for storeing previous evolution
!!@param coef_exp      coeefient for expilict evolution for diffusion
!!@param coef_src      coefficient for source term
!
      module cal_diff_adv_src_explicit
!
      use m_precision
      use m_constants
!
      use m_spheric_parameter
      use m_sph_spectr_data
      use m_t_int_parameter
!
      implicit  none
!
! ----------------------------------------------------------------------
!
      contains
!
! ----------------------------------------------------------------------
!
      subroutine sel_scalar_diff_adv_src_adams(kr_st, kr_ed,            &
     &          ipol_diffuse, ipol_advect, ipol_source, ipol_scalar,    &
     &          ipol_pre, coef_exp, coef_src)
!
      integer(kind = kint), intent(in) :: kr_st, kr_ed
      integer(kind = kint), intent(in) :: ipol_diffuse, ipol_advect
      integer(kind = kint), intent(in) :: ipol_source
      integer(kind = kint), intent(in) :: ipol_scalar, ipol_pre
      real(kind = kreal), intent(in) :: coef_exp, coef_src
!
!
      if(ipol_source .gt. izero) then
        call scalar_diff_adv_src_adams(kr_st, kr_ed,                    &
     &          ipol_diffuse, ipol_advect, ipol_source, ipol_scalar,    &
     &          ipol_pre, coef_exp, coef_src)
      else
        call scalar_diff_advect_adams(kr_st, kr_ed,                     &
     &          ipol_diffuse, ipol_advect, ipol_scalar, ipol_pre,       &
     &          coef_exp)
      end if
!
      end subroutine sel_scalar_diff_adv_src_adams
!
! ----------------------------------------------------------------------
!
      subroutine sel_scalar_diff_adv_src_euler(kr_st, kr_ed,            &
     &          ipol_diffuse, ipol_advect, ipol_source, ipol_scalar,    &
     &          coef_exp, coef_src)
!
      integer(kind = kint), intent(in) :: kr_st, kr_ed
      integer(kind = kint), intent(in) :: ipol_diffuse, ipol_advect
      integer(kind = kint), intent(in) :: ipol_source
      integer(kind = kint), intent(in) :: ipol_scalar
      real(kind = kreal), intent(in) :: coef_exp, coef_src
!
!
      if(ipol_source .gt. izero) then
        call scalar_diff_adv_src_euler(kr_st, kr_ed,                    &
     &          ipol_diffuse, ipol_advect, ipol_source, ipol_scalar,    &
     &          coef_exp, coef_src)
      else
        call scalar_diff_advect_euler(kr_st, kr_ed,                     &
     &          ipol_diffuse, ipol_advect, ipol_scalar, coef_exp)
      end if
!
      end subroutine sel_scalar_diff_adv_src_euler
!
! ----------------------------------------------------------------------
!
      subroutine sel_ini_adams_scalar_w_src(kr_st, kr_ed,               &
     &          ipol_advect, ipol_source, ipol_pre, coef_src)
!
      integer(kind = kint), intent(in) :: kr_st, kr_ed
      integer(kind = kint), intent(in) :: ipol_advect, ipol_source
      integer(kind = kint), intent(in) :: ipol_pre
      real(kind = kreal), intent(in) :: coef_src
!
!
      if(ipol_source .gt. izero) then
        call set_ini_adams_scalar_w_src(kr_st, kr_ed,                   &
     &          ipol_advect, ipol_source, ipol_pre, coef_src)
      else
        call set_ini_adams_scalar(kr_st, kr_ed, ipol_advect, ipol_pre)
      end if
!
      end subroutine sel_ini_adams_scalar_w_src
!
! ----------------------------------------------------------------------
! ----------------------------------------------------------------------
!
      subroutine scalar_diff_advect_adams(kr_st, kr_ed,                 &
     &          ipol_diffuse, ipol_advect, ipol_scalar, ipol_pre,       &
     &          coef_exp)
!
      integer(kind = kint), intent(in) :: kr_st, kr_ed
      integer(kind = kint), intent(in) :: ipol_diffuse, ipol_advect
      integer(kind = kint), intent(in) :: ipol_scalar, ipol_pre
      real(kind = kreal), intent(in) :: coef_exp
!
      integer(kind = kint) :: inod, ist, ied
!
!
      ist = (kr_st-1)*nidx_rj(2) + 1
      ied = kr_ed * nidx_rj(2)
!$omp do private (inod)
      do inod = ist, ied
        d_rj(inod,ipol_scalar) = d_rj(inod,ipol_scalar)                 &
     &          + dt * (coef_exp * d_rj(inod,ipol_diffuse)              &
     &              - adam_0 * d_rj(inod,ipol_advect)                   &
     &              + adam_1 * d_rj(inod,ipol_pre) )
!
         d_rj(inod,ipol_pre) = - d_rj(inod,ipol_advect)
       end do
!$omp end do
!
      end subroutine scalar_diff_advect_adams
!
! ----------------------------------------------------------------------
!
      subroutine scalar_diff_advect_euler(kr_st, kr_ed,                 &
     &          ipol_diffuse, ipol_advect, ipol_scalar, coef_exp)
!
      integer(kind = kint), intent(in) :: kr_st, kr_ed
      integer(kind = kint), intent(in) :: ipol_diffuse, ipol_advect
      integer(kind = kint), intent(in) :: ipol_scalar
      real(kind = kreal), intent(in) :: coef_exp
!
      integer(kind = kint) :: inod, ist, ied
!
!
      ist = (kr_st-1)*nidx_rj(2) + 1
      ied = kr_ed * nidx_rj(2)
!$omp do private (inod)
      do inod = ist, ied
        d_rj(inod,ipol_scalar) = d_rj(inod,ipol_scalar)                 &
     &         + dt * (coef_exp*d_rj(inod,ipol_diffuse)                 &
     &             - d_rj(inod,ipol_advect) )
       end do
!$omp end do
!
      end subroutine scalar_diff_advect_euler
!
! ----------------------------------------------------------------------
!
      subroutine set_ini_adams_scalar(kr_st, kr_ed,                     &
     &          ipol_advect, ipol_pre)
!
      integer(kind = kint), intent(in) :: kr_st, kr_ed
      integer(kind = kint), intent(in) :: ipol_advect, ipol_pre
!
      integer(kind = kint) :: inod, ist, ied
!
!
      ist = (kr_st-1)*nidx_rj(2) + 1
      ied = kr_ed * nidx_rj(2)
!$omp do private (inod)
      do inod = ist, ied
         d_rj(inod,ipol_pre) =  -d_rj(inod,ipol_advect)
      end do
!$omp end do
!
      end subroutine set_ini_adams_scalar
!
! ----------------------------------------------------------------------
! ----------------------------------------------------------------------
!
      subroutine scalar_diff_adv_src_adams(kr_st, kr_ed,                &
     &          ipol_diffuse, ipol_advect, ipol_source, ipol_scalar,    &
     &          ipol_pre, coef_exp, coef_src)
!
      integer(kind = kint), intent(in) :: kr_st, kr_ed
      integer(kind = kint), intent(in) :: ipol_diffuse, ipol_advect
      integer(kind = kint), intent(in) :: ipol_source
      integer(kind = kint), intent(in) :: ipol_scalar, ipol_pre
      real(kind = kreal), intent(in) :: coef_exp, coef_src
!
      integer(kind = kint) :: inod, ist, ied
!
!
      ist = (kr_st-1)*nidx_rj(2) + 1
      ied = kr_ed * nidx_rj(2)
!$omp do private (inod)
      do inod = ist, ied
        d_rj(inod,ipol_scalar) = d_rj(inod,ipol_scalar)                 &
     &          + dt * (coef_exp * d_rj(inod,ipol_diffuse)              &
     &              + adam_0 * ( -d_rj(inod,ipol_advect)                &
     &                 + coef_src * d_rj(inod,ipol_source) )            &
     &              + adam_1 * d_rj(inod,ipol_pre) )
!
         d_rj(inod,ipol_pre) = - d_rj(inod,ipol_advect)                 &
     &               + coef_src * d_rj(inod,ipol_source)
       end do
!$omp end do
!
      end subroutine scalar_diff_adv_src_adams
!
! ----------------------------------------------------------------------
!
      subroutine scalar_diff_adv_src_euler(kr_st, kr_ed,                &
     &          ipol_diffuse, ipol_advect, ipol_source, ipol_scalar,    &
     &          coef_exp, coef_src)
!
      integer(kind = kint), intent(in) :: kr_st, kr_ed
      integer(kind = kint), intent(in) :: ipol_diffuse, ipol_advect
      integer(kind = kint), intent(in) :: ipol_source
      integer(kind = kint), intent(in) :: ipol_scalar
      real(kind = kreal), intent(in) :: coef_exp, coef_src
!
      integer(kind = kint) :: inod, ist, ied
!
!
      ist = (kr_st-1)*nidx_rj(2) + 1
      ied = kr_ed * nidx_rj(2)
!$omp do private (inod)
      do inod = ist, ied
        d_rj(inod,ipol_scalar) = d_rj(inod,ipol_scalar)                 &
     &         + dt * (coef_exp*d_rj(inod,ipol_diffuse)                 &
     &             - d_rj(inod,ipol_advect)                             &
     &              + coef_src * d_rj(inod,ipol_source) )
       end do
!$omp end do
!
      end subroutine scalar_diff_adv_src_euler
!
! ----------------------------------------------------------------------
!
      subroutine set_ini_adams_scalar_w_src(kr_st, kr_ed,               &
     &          ipol_advect, ipol_source, ipol_pre, coef_src)
!
      integer(kind = kint), intent(in) :: kr_st, kr_ed
      integer(kind = kint), intent(in) :: ipol_advect, ipol_source
      integer(kind = kint), intent(in) :: ipol_pre
      real(kind = kreal), intent(in) :: coef_src
!
      integer(kind = kint) :: inod, ist, ied
!
!
      ist = (kr_st-1)*nidx_rj(2) + 1
      ied = kr_ed * nidx_rj(2)
!$omp do private (inod)
      do inod = ist, ied
         d_rj(inod,ipol_pre) =  -d_rj(inod,ipol_advect)                 &
     &                        + coef_src * d_rj(inod,ipol_source)
      end do
!$omp end do
!
      end subroutine set_ini_adams_scalar_w_src
!
! ----------------------------------------------------------------------
!
      end module cal_diff_adv_src_explicit