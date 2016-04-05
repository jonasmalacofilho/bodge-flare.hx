package bodge;

@:enum abstract SignalNumber(Int) to Int {
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
			case _: null;
		}
		return name != null ? '$name ($this)' : '$this';
	}
}

typedef Handler = SignalNumber -> Void;

class Flare {
	static var registry:Array<Handler> = [];

	static function __init__()
		neko.Lib.load("flare", "flare_init", 1)(genericHandler);

	static function genericHandler(flare)
	{
		for (h in registry)
			h(flare);
	}

	public static function register(handler)
		registry.push(handler);
}

