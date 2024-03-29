/*
 * (c) 2016-2024 Alexander Schoepe
 * (c) 2016 Joerg Mehring
 *
 * See the file "license.terms" for information on usage and redistribution
 * of this file, and for a DISCLAIMER OF ALL WARRANTIES.
 */

#include "randombytes.h"

#if defined(HAVE_DEVICE_RANDOM) || defined(HAVE_DEVICE_URANDOM)
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#ifndef _WIN32
#include <err.h>
#endif
#endif

#ifdef HAVE_SECRANDOMCOPYBYTES
#include <Security/SecRandom.h>
#endif

#ifdef HAVE_GETRANDOM
/*
#include <linux/random.h>
*/
#include <sys/random.h>
#endif

#ifdef HAVE_CRYPTGENRANDOM
#include <windows.h>
#include <wincrypt.h>
#pragma comment(lib, "advapi32.lib")
#endif

static int randomSource = RANDOMBYTES_SRC_DEFAULT;
#if defined(HAVE_DEVICE_RANDOM) || defined(HAVE_DEVICE_URANDOM)
static int fd = -1;
static char randomDevice[32] = RANDOMBYTES_DEV_DEFAULT;

int rb_Device(unsigned char *ptr, unsigned long long length)
{
  unsigned int i = 0;
  if (fd == -1)
  {
    if ((fd = open(randomDevice, O_RDONLY)) == -1)
    {
#ifndef _WIN32
      err(1, "Error opening %s", randomDevice);
#endif
      return -1;
    }
  }
  while (length > 0)
  {
    i = (length > 65536) ? 65536 : length;
    i = read(fd, ptr, i);
    ptr += i;
    length -= i;
  }
  return 0;
}
#endif

#ifdef HAVE_SECRANDOMCOPYBYTES
int rb_SecRandomCopyBytes(void *buffer, int length)
{
  return (SecRandomCopyBytes(kSecRandomDefault, length, (uint8_t *)buffer) == 0) ? 0 : -1;
}
#endif

#ifdef HAVE_GETRANDOM
int rb_GetRandom(unsigned char *ptr, unsigned long long length)
{
  return (getrandom(ptr, length, GRND_RANDOM)) ? 0 : -1;
}
#endif

#ifdef HAVE_CRYPTGENRANDOM
int rb_CryptGenRandom(unsigned char *buf, size_t size)
{
  static BOOL hasCrypto;
  static HCRYPTPROV hCryptProv;

  if (hasCrypto == 0)
  {
    if (!CryptAcquireContext(&hCryptProv, NULL, NULL, PROV_RSA_FULL, CRYPT_MACHINE_KEYSET | CRYPT_VERIFYCONTEXT))
    {
      if (GetLastError() == NTE_BAD_KEYSET)
      {
        if (CryptAcquireContext(&hCryptProv, NULL, NULL, PROV_RSA_FULL, CRYPT_NEWKEYSET | CRYPT_MACHINE_KEYSET | CRYPT_VERIFYCONTEXT))
        {
          hasCrypto = 1;
        }
        else
        {
          hasCrypto = 0;
        }
      }
    }
    else
    {
      hasCrypto = 1;
    }
  }

  if (hasCrypto == 0)
    return -1;

  return (CryptGenRandom(hCryptProv, (DWORD)size, buf)) ? 0 : -1;
}
#endif

int GetRandomSource(void)
{
  return randomSource;
}

int SetRandomSource(int src)
{
#if defined(HAVE_DEVICE_RANDOM) || defined(HAVE_DEVICE_URANDOM)
  switch (randomSource)
  {
  case RANDOMBYTES_SRC_RANDOM:
  {
    strcpy(randomDevice, RANDOMBYTES_DEV_RANDOM);
    break;
  }
  case RANDOMBYTES_SRC_URANDOM:
  {
    strcpy(randomDevice, RANDOMBYTES_DEV_URANDOM);
    break;
  }
  }
  if (fd != -1)
  {
    close(fd);
    fd = -1;
  }
#endif
  randomSource = src;
  return 0;
}

int randombytes(unsigned char *ptr, unsigned long long length)
{
  switch (randomSource)
  {
#if defined(HAVE_DEVICE_RANDOM) || defined(HAVE_DEVICE_URANDOM)
  case RANDOMBYTES_SRC_RANDOM:
  case RANDOMBYTES_SRC_URANDOM:
  {
    return rb_Device(ptr, length);
  }
#endif
#ifdef HAVE_SECRANDOMCOPYBYTES
  case RANDOMBYTES_SRC_SECRANDOMCOPYBYTES:
  {
    return rb_SecRandomCopyBytes(ptr, length);
  }
#endif
#ifdef HAVE_CRYPTGENRANDOM
  case RANDOMBYTES_SRC_CRYPTGENRANDOM:
  {
    return rb_CryptGenRandom(ptr, length);
  }
#endif
#ifdef HAVE_GETRANDOM
  case RANDOMBYTES_SRC_GETRANDOM:
  {
    return rb_GetRandom(ptr, length);
  }
#endif
  default:
  {
#ifndef _WIN32
    err(1, "Error: no random source selected");
#endif
    return -1;
  }
  }
}

/*
   web::randombytes names
   web::randombytes source ?random|urandom|secrandomcopybytes|cryptgenrandom|default?
   web::randombytes lengthValue
*/

static int Web_RandomBytes(ClientData clientData, Tcl_Interp *interp, int objc, Tcl_Obj *const objv[])
{
  static const char *const command[] = {
      "names", "source", NULL};
  enum command
  {
    WEB_RANDOM_NAMES,
    WEB_RANDOM_SOURCE,
    WEB_RANDOM_LENGTH
  } cmd;

  static const char *const source[] = {
#ifdef HAVE_DEVICE_RANDOM
      "random",
#endif
#ifdef HAVE_DEVICE_URANDOM
      "urandom",
#endif
#ifdef HAVE_SECRANDOMCOPYBYTES
      "secrandomcopybytes",
#endif
#ifdef HAVE_CRYPTGENRANDOM
      "cryptgenrandom",
#endif
#ifdef HAVE_GETRANDOM
      "getrandom",
#endif
      "default",
      NULL};
  enum source
  {
#ifdef HAVE_DEVICE_RANDOM
    WEB_RANDOM_DEV_RANDOM,
#endif
#ifdef HAVE_DEVICE_URANDOM
    WEB_RANDOM_DEV_URANDOM,
#endif
#ifdef HAVE_SECRANDOMCOPYBYTES
    WEB_RANDOM_SECRANDOMCOPYBYTES,
#endif
#ifdef HAVE_CRYPTGENRANDOM
    WEB_RANDOM_CRYPTGENRANDOM,
#endif
#ifdef HAVE_GETRANDOM
    WEB_RANDOM_GETRANDOM,
#endif
    WEB_RANDOM_DEFAULT
  } src;

  if (objc < 2)
  {
    Tcl_WrongNumArgs(interp, 1, objv, "?command|lengthValue? ...");
    return TCL_ERROR;
  }

  int len = 0;

  if (Tcl_GetIntFromObj(interp, objv[1], &len) == TCL_OK)
  {
    cmd = WEB_RANDOM_LENGTH;
  }
  else
  {
    Tcl_ResetResult(interp);
    if (Tcl_GetIndexFromObj(interp, objv[1], command, "command", 0, (int *)&cmd) != TCL_OK)
    {
      return TCL_ERROR;
    }
  }

  Tcl_Obj *bObjPtr = Tcl_NewByteArrayObj(NULL, 0);
  unsigned char *b;
  int rc = -1;

  switch (cmd)
  {
  case WEB_RANDOM_NAMES:
  {
    Tcl_Obj *lObjPtr = Tcl_NewListObj(0, NULL);
    int i;
    for (i = 0;; i++)
    {
      if (source[i] == NULL)
        break;
      Tcl_ListObjAppendElement(interp, lObjPtr, Tcl_NewStringObj(source[i], -1));
    }
    Tcl_SetObjResult(interp, lObjPtr);
    return TCL_OK;
  }

  case WEB_RANDOM_SOURCE:
  {
    if (objc == 2)
    {
      switch (GetRandomSource())
      {
#ifdef HAVE_DEVICE_RANDOM
      case RANDOMBYTES_SRC_RANDOM:
      {
        Tcl_SetObjResult(interp, Tcl_NewStringObj(source[WEB_RANDOM_DEV_RANDOM], -1));
        break;
      }
#endif
#ifdef HAVE_DEVICE_URANDOM
      case RANDOMBYTES_SRC_URANDOM:
      {
        Tcl_SetObjResult(interp, Tcl_NewStringObj(source[WEB_RANDOM_DEV_URANDOM], -1));
        break;
      }
#endif
#ifdef HAVE_SECRANDOMCOPYBYTES
      case RANDOMBYTES_SRC_SECRANDOMCOPYBYTES:
      {
        Tcl_SetObjResult(interp, Tcl_NewStringObj(source[WEB_RANDOM_SECRANDOMCOPYBYTES], -1));
        break;
      }
#endif
#ifdef HAVE_CRYPTGENRANDOM
      case RANDOMBYTES_SRC_CRYPTGENRANDOM:
      {
        Tcl_SetObjResult(interp, Tcl_NewStringObj(source[WEB_RANDOM_CRYPTGENRANDOM], -1));
        break;
      }
#endif
#ifdef HAVE_GETRANDOM
      case RANDOMBYTES_SRC_GETRANDOM:
      {
        Tcl_SetObjResult(interp, Tcl_NewStringObj(source[WEB_RANDOM_GETRANDOM], -1));
        break;
      }
#endif
      }
      return TCL_OK;
    }
    if (objc != 3)
    {
      Tcl_WrongNumArgs(interp, 1, objv, "source ?source?");
      return TCL_ERROR;
    }
    if (Tcl_GetIndexFromObj(interp, objv[2], source, "source", 0, (int *)&src) != TCL_OK)
    {
      return TCL_ERROR;
    }
    switch (src)
    {
#ifdef HAVE_DEVICE_RANDOM
    case WEB_RANDOM_DEV_RANDOM:
    {
      SetRandomSource(RANDOMBYTES_SRC_RANDOM);
      break;
    }
#endif
#ifdef HAVE_DEVICE_URANDOM
    case WEB_RANDOM_DEV_URANDOM:
    {
      SetRandomSource(RANDOMBYTES_SRC_URANDOM);
      break;
    }
#endif
#ifdef HAVE_SECRANDOMCOPYBYTES
    case WEB_RANDOM_SECRANDOMCOPYBYTES:
    {
      SetRandomSource(RANDOMBYTES_SRC_SECRANDOMCOPYBYTES);
      break;
    }
#endif
#ifdef HAVE_CRYPTGENRANDOM
    case WEB_RANDOM_CRYPTGENRANDOM:
    {
      SetRandomSource(RANDOMBYTES_SRC_CRYPTGENRANDOM);
      break;
    }
#endif
#ifdef HAVE_GETRANDOM
    case WEB_RANDOM_GETRANDOM:
    {
      SetRandomSource(RANDOMBYTES_SRC_GETRANDOM);
      break;
    }
#endif
    case WEB_RANDOM_DEFAULT:
    {
      SetRandomSource(RANDOMBYTES_SRC_DEFAULT);
      break;
    }
    }
    return TCL_OK;
  }

  case WEB_RANDOM_LENGTH:
  {
    if (objc != 2)
    {
      Tcl_WrongNumArgs(interp, 1, objv, "lengthValue");
      return TCL_ERROR;
    }
    if (Tcl_GetIntFromObj(interp, objv[1], &len) != TCL_OK)
    {
      return TCL_ERROR;
    }
    break;
  }
  }

  if (len > 0)
  {
    b = Tcl_SetByteArrayLength(bObjPtr, len);
    rc = randombytes(b, (unsigned long long)len);
    if (rc != 0)
      Tcl_SetByteArrayLength(bObjPtr, 0);
    Tcl_SetObjResult(interp, bObjPtr);
    return TCL_OK;
  }

  return TCL_ERROR;
}


int randombytes_Init(Tcl_Interp *interp)
{
  if (interp == NULL)
    return TCL_ERROR;

  Tcl_CreateObjCommand(interp, "web::randombytes", Web_RandomBytes, (ClientData)NULL, (Tcl_CmdDeleteProc *)NULL);

  return TCL_OK;
}
