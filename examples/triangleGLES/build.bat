set INCLUDES=/I ..\..\src /I ..\..\src\util /I ..\..\src\platform /I ../../ext
cl /we4013 /Zi /Zc:preprocessor /std:c11 %INCLUDES% main.c /link /LIBPATH:../../bin milepost.lib user32.lib opengl32.lib gdi32.lib /out:test.exe
