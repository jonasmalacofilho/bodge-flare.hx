class Test {
	static function main()
	{
		bodge.Flare.register(function (num) throw num);
		try {
			new neko.vm.Lock().wait();
		} catch (e:Dynamic) {
			trace('Aborting infinite pause due to exception: $e');
		}
		trace('Bye');
	}
}

