  int k,*ind,ij,ijk;
  double lvl;
  float hyb;
  int kind;
  
  if( my_alloc_int(&ind, nk,"cannot allocate ind of int of size\n") == VGD_ERROR )
    return(VGD_ERROR);
  
  // Find ip1 indexes
  for( k = 0; k < nk; ++k ){
    if( ( ind[k] = VGD_FindIp1Idx(ip1_list[k],self->ip1_m,self->nl_m)) == -1 ) {
      Lib_Log(APP_LIBVGRID,APP_ERROR,"%s: cannot find ip1 %d in vgrid descriptor\n",__func__,ip1_list[k]);
      free(ind);
      return(VGD_ERROR);
    }
  }  
  if( dpidpis ){
    if(in_log){
      Lib_Log(APP_LIBVGRID,APP_ERROR,"%s: option in_log not allowed with option dpidpis\n",__func__);
      return(VGD_ERROR);
    }
    for( k = 0, ijk=0; k < nk; ++k ){
      for( ij = 0; ij < ni*nj; ++ij, ++ijk ){
#if defined(REAL_8)
	levels[ijk] = self->b_m_8[ind[k]];
#else
	levels[ijk] = (float) self->b_m_8[ind[k]];
#endif	
      }
    }    
    free(ind);
    return(VGD_OK);
  }
  // Compute pressure
  for( k = 0, ijk=0; k < nk; ++k ){
    for( ij = 0; ij < ni*nj; ++ij, ++ijk ){
      lvl = self->a_m_8[ind[k]] + self->b_m_8[ind[k]] * sfc_field[ij];
#if defined(REAL_8)
      levels[ijk] = in_log ? log(lvl) : lvl;
#else
      levels[ijk] = (float) (in_log ? log(lvl) : lvl);
#endif
    }
  }

  //Force surface pressure to be equal to sfc_field
  //Needed by CMDW. 
  if(! in_log) {
    for(k=0; k < nk; k++){
      hyb = c_convip_IP2Level(ip1_list[k],&kind);
      if(fabs(hyb-1.0) < 0.000001 && kind==1){
        ijk=k*ni*nj;
        for(ij=0; ij < ni*nj; ij++, ijk++){
          levels[ijk] = sfc_field[ij];
        }
      }
    }
  }
 
  free(ind);
  
  return(VGD_OK);
