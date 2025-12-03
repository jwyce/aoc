const input = await Bun.file(`${import.meta.dir}/input.txt`).text();
const ranges = input.trim().split(",");

// examples: 11, 22, 33, .., 99, 1010, 1111,. .
// always even number of digits
// start with the lowest number w/ even digits within range
// find source (i.e. number created from first 2 digits)
// iterate through possible ids until we go outside range

function nextEvenDigitNum(n: number) {
	const len = `${n}`.length;
	return len % 2 === 0 ? n : 10 ** (len + 1);
}

function lastEvenDigitNum(n: number) {
	const len = `${n}`.length;
	return len % 2 === 0 ? n : 10 ** (len - 1) - 1;
}

function halfDigits(n: number) {
	const nstr = `${n}`;
	return Number.parseInt(nstr.substring(0, nstr.length / 2));
}

function part1() {
	let sum = 0;
	for (const range of ranges) {
		const [start, end] = range.split("-").map((n) => Number.parseInt(n));
		const [probeStart, probeEnd] = [
			nextEvenDigitNum(start),
			lastEvenDigitNum(end),
		].map((n) => halfDigits(n));

		for (let x = probeStart; x <= probeEnd; x++) {
			const id = Number.parseInt(`${x}${x}`);
			if (id >= start && id <= end) sum += id;
		}
	}
	return sum;
}

function factors(n: number) {
	const factors: number[] = [];
	for (let i = 1; i <= Math.sqrt(n); i++) {
		if (n % i === 0) {
			factors.push(i);
			if (i !== n / i && n / i !== n) factors.push(n / i);
		}
	}
	return factors;
}

function part2() {
	let sum = 0;
	for (const range of ranges) {
		const [start, end] = range.split("-").map((n) => Number.parseInt(n));
		const [lenS, lenE] = [start, end].map((x) => `${x}`.length);

		const ids = new Set<number>();

    // look at all digit lens of start to end and their factors
		for (let len = lenS; len <= lenE; len++) {
			for (const factor of factors(len)) {
				const rFactor = len / factor;
				// digits need to repeat at least twice
				// need to avoid single digit nums being added
				if (rFactor < 2) continue;

				for (let i = 10 ** (factor - 1); `${i}`.length <= factor; i++) {
					const id = Number.parseInt(`${i}`.repeat(rFactor));
					if (id >= start && id <= end) {
						ids.add(id);
					}
				}
			}
		}

		sum += [...ids].reduce((a, b) => a + b, 0);
	}
	return sum;
}

console.log("Part 1:", part1());
console.log("Part 2:", part2());
