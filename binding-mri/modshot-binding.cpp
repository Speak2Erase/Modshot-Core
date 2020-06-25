#include "oneshot.h"
#include "etc.h"
#include "sharedstate.h"
#include "binding-util.h"
#include "binding-types.h"
#include "eventthread.h"

#include <SDL.h>
#include <boost/crc.hpp>

RB_METHOD(bounce_up)
{
	//I don't really know C++ atm, forgive the spaghetti code, I will fix this later .W.
	int absx, absy;
	SDL_GetWindowPosition(shState->rtData().window, &absx, &absy);
	int state;
	for (int i = 0; i < 60; ++i) {
		int max = 60 - i;
		int y = 1
		int x = 0
		SDL_SetWindowPosition(shState->rtData().window, absx + x, absy + y);
		rb_eval_string_protect("sleep 0.02", &state);
	}
	for (int i = 0; i < 60; ++i) {
		int max = 60 - i;
		int y = -1
		int x = 0
		SDL_SetWindowPosition(shState->rtData().window, absx + x, absy + y);
		rb_eval_string_protect("sleep 0.02", &state);
	}
}







void oneshotBindingInit()
{
	VALUE module = rb_define_module("Modshot");
	VALUE msg = rb_define_module_under(module, "Msg");
	_rb_define_module_function(module, "bounce_up", bounce_up);


}