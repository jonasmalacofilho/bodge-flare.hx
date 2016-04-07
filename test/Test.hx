import bodge.Flare;

class UnpauseException {
	var signal:SignalNumber;

	public function toString()
		return 'UnpauseException($signal)';

	public function new(signal)
		this.signal = signal;
}

class Test {
	static function pause()
	{
		trace("Pausing...");
		try {
			new neko.vm.Lock().wait();
		} catch (e:UnpauseException) {
			trace('Aborting infinite pause with $e');
		}
	}

	static function main()
	{
		trace("Ignoring SIGINT (keyboard interrupt)");
		Flare.ignore(SIGINT);

		trace("Setting SIGUSR1 to unpause");
		Flare.notify(SIGUSR1, function (num) throw new UnpauseException(num));
		pause();

		trace("Restoring SIGINT default behavior");
		Flare.restore(SIGINT);
		pause();
	}
}

