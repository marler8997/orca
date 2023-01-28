/************************************************************//**
*
*	@file: milepost.h
*	@author: Martin Fouilleul
*	@date: 13/02/2021
*	@revision:
*
*****************************************************************/
#ifndef __MILEPOST_H_
#define __MILEPOST_H_

//----------------------------------------------------------------
// utility layer
//----------------------------------------------------------------
#include"platform.h"
#include"typedefs.h"
#include"macro_helpers.h"
#include"debug_log.h"
#include"lists.h"
#include"memory.h"
#include"strings.h"
#include"utf8.h"
#include"hash.h"

//----------------------------------------------------------------
// platform layer
//----------------------------------------------------------------
#include"platform_clock.h"
/*
#include"platform_rng.h"
#include"platform_socket.h"
#include"platform_thread.h"
*/

//----------------------------------------------------------------
// application layer
//----------------------------------------------------------------
#include"mp_app.h"

#if defined(OS_WIN64) || defined(OS_WIN32)
	#define WIN32_GL_LOADER_API
	#include"win32_gl_loader.h"
#endif

//----------------------------------------------------------------
// graphics/ui layer
//----------------------------------------------------------------
#include"graphics.h"
//#include"ui.h"

#endif //__MILEPOST_H_
