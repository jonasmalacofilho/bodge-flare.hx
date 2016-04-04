package bodge;

typedef SignalNumber = Int;
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

