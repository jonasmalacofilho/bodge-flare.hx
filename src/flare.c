#include <errno.h>
#include <neko.h>
#include <signal.h>
#include <stdio.h>
#include <string.h>
#include <pthread.h>

static value *cback;

static void gen_handler(int signum)
{
	if (cback == NULL) return;
	printf("Received signal %d\n", signum);
	val_call1(*cback, alloc_int(signum));
}

static void efailure(const char *prefix)
{
	int e = errno;
	buffer b = alloc_buffer(prefix);
	buffer_append(b, strerror(e));
	buffer_append(b, ": ");
	bfailure(b);
}

static value val_sigaction(value signal, void *handler)
{
	val_check(signal, int);

	/* set the the desired action for the signal */
	struct sigaction act, oldact;
	int signum = val_int(signal);
	act.sa_sigaction = NULL;
	act.sa_flags = SA_NODEFER;
	act.sa_handler = handler;
	sigemptyset(&act.sa_mask);
	if (sigaction(signum, &act, &oldact))
		efailure("Could not set signal action");

	/* block or unblock signals on the calling thread depending on action */
	sigset_t set;
	sigemptyset(&set);
	sigaddset(&set, signum);
	int how = handler == SIG_DFL || handler == SIG_IGN ? SIG_BLOCK : SIG_UNBLOCK;
	if (pthread_sigmask(how, &set, NULL))
		efailure("Could not unblock signal");
	return val_null;
}

value flare_init(value handler)
{
	/* save the haxe exposed generic handler */
	val_check_function(handler, 1);
	cback = alloc_root(1);
	*cback = handler;

	/* block all signals, except those used internally by neko */
	sigset_t set;
	sigfillset(&set);
	sigdelset(&set, SIGPIPE);
	sigdelset(&set, SIGSEGV);
	if (pthread_sigmask(SIG_SETMASK, &set, NULL))
		efailure("Could not set signal mask");

	return val_null;
}
DEFINE_PRIM(flare_init, 1);

value flare_notify(value signal)
{
	return val_sigaction(signal, gen_handler);
}
DEFINE_PRIM(flare_notify, 1);

value flare_ignore(value signal)
{
	return val_sigaction(signal, SIG_IGN);
}
DEFINE_PRIM(flare_ignore, 1);

value flare_restore(value signal)
{
	return val_sigaction(signal, SIG_DFL);
}
DEFINE_PRIM(flare_restore, 1);

