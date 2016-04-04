#include <signal.h>
#include <neko.h>

static value *cback;

static void gen_handler(int signum)
{
	if (cback == NULL) return;
	val_call1(*cback, alloc_int(signum));
}

value flare_init(value val)
{
	struct sigaction act;
	int signum;

	val_check_function(val, 1);
	cback = alloc_root(1);
	*cback = val;

	act.sa_sigaction = NULL;
	act.sa_handler = gen_handler;
	act.sa_flags = 0;
	sigemptyset(&act.sa_mask);

	for (signum=0; signum<256; signum++) {
		if (signum == SIGKILL || signum == SIGSTOP) continue;
		sigaction(signum, &act, NULL);
	}
}
DEFINE_PRIM(flare_init, 1);

