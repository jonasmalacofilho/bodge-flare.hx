package bodge;

@:enum abstract SignalNumber(Int) to Int {
	// signals with unique representations
	var SIGHUP = 1;    // (Term) Hangup detected on controlling terminal or death of controlling process
	var SIGINT = 2;    // (Term) Interrupt from keyboard
	var SIGQUIT = 3;   // (Core) Quit from keyboard
	var SIGILL = 4;    // (Core) Illegal Instruction
	var SIGABRT = 6;   // (Core) Abort signal from abort(3)
	var SIGFPE = 8;    // (Core) Floating point exception
	var SIGSEGV = 11;  // (Core) Invalid memory reference
	var SIGPIPE = 13;  // (Term) Broken pipe: write to pipe with no readers
	var SIGALRM = 14;  // (Term) Timer signal from alarm(2)
	var SIGTERM = 15;  // (Term) Termination signal

	// signals that vary according to arch (using x86/x86-64/arm)
	// TODO use internal codes and map them to signals names in C code
	var SIGUSR1 = 10;  // (Term) User-defined signal 1
	var SIGUSR2 = 12;  // (Term) User-defined signal 2

	public function new(other) this = other;

	@:to public function toString():String
	{
		var name = switch this {
			case SIGHUP: "SIGUP";
			case SIGINT: "SIGINT";
			case SIGQUIT: "SIGQUIT";
			case SIGILL: "SIGILL";
			case SIGABRT: "SIGABRT";
			case SIGFPE: "SIGFPE";
			case SIGSEGV: "SIGSEGV";
			case SIGPIPE: "SIGPIPE";
			case SIGALRM: "SIGALRM";
			case SIGTERM: "SIGTERM";
			case SIGUSR1: "SIGUSR1";
			case SIGUSR2: "SIGUSR2";
			case _: null;
		}
		return name != null ? '$name ($this)' : '$this';
	}
}

typedef Handler = SignalNumber -> Void;

class Flare {
	static inline var FLARE = "flare";
	static var registry = new Map<SignalNumber,Handler>();

	static function __init__()
		neko.Lib.load(FLARE, FLARE + "_init", 1)(genericHandler);

	static var _notify:SignalNumber->Void = neko.Lib.load(FLARE, FLARE + "_notify", 1);
	static var _ignore:SignalNumber->Void = neko.Lib.load(FLARE, FLARE + "_ignore", 1);
	static var _restore:SignalNumber->Void = neko.Lib.load(FLARE, FLARE + "_restore", 1);

	static function genericHandler(flare)
	{
		var handler = registry[flare];
		if (handler == null) return;
		handler(flare);
	}

	/*
	  Set `signum` action to `handler`.
	*/
	public static function notify(signum, handler)
	{
		registry[signum] = handler;
		_notify(signum);
	}

	/*
	  Set `signum` action to ignore.
	*/
	public static function ignore(signum)
	{
		registry.remove(signum);
		_ignore(signum);
	}

	/*
	  Set `signum` action to its default (terminate, ignore or core).
	*/
	public static function restore(signum)
	{
		registry.remove(signum);
		_restore(signum);
	}
}

