const input = await Bun.file(`${import.meta.dir}/input.txt`).text();
const lines = input.trim().split("\n");

function mod(n: number, m: number) {
	return ((n % m) + m) % m;
}

function part1() {
	let dial = 50;
	let zeros = 0;
	for (const line of lines) {
		const dir = line.at(0) === "R" ? 1 : -1;
		const dist = Number.parseInt(line.substring(1));
		dial = mod(dial + dir * dist, 100);
		if (dial === 0) zeros++;
	}

	return zeros;
}

function part2() {
	let dial = 50;
	let clicks = 0;
	for (const line of lines) {
		const dir = line.at(0) === "R" ? 1 : -1;
		const dist = Number.parseInt(line.substring(1));
		const firstZero = dial === 0 ? 100 : dir === 1 ? 100 - dial : dial;
		// console.log({ dial, spin: dir * dist, firstZero });
		if (firstZero <= dist) {
			clicks += Math.floor((dist - firstZero) / 100 + 1);
		}
		// console.log({ clicks });
		dial = mod(dial + dir * dist, 100);
	}

	return clicks;
}

console.log("Part 1:", part1());
console.log("Part 2:", part2());
